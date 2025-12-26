-- 导入所需模块
local core = require("apisix.core")
local ngx = ngx
local string = string
local require = require
local json = require("apisix.core.json")
local redis = require("resty.redis")
local md5 = require("resty.md5")
local ffi = require("ffi")
-- 移除 dkjson，使用 cjson 配合自定义排序逻辑，性能更好且可控
local cjson = require("cjson.safe")
local lrucache = require("resty.lrucache")

-- FFI 定义
ffi.cdef[[
    typedef struct evp_cipher_ctx_st EVP_CIPHER_CTX;
    typedef struct evp_cipher_st EVP_CIPHER;

    EVP_CIPHER_CTX *EVP_CIPHER_CTX_new(void);
    void EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *ctx);
    int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher,
                          void *impl, const unsigned char *key, const unsigned char *iv);
    int EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher,
                          void *impl, const unsigned char *key, const unsigned char *iv);
    int EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
                         const unsigned char *in, int inl);
    int EVP_DecryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl);

    const EVP_CIPHER *EVP_aes_128_cbc(void);
]]

local plugin_name = "aes-request-decode"

-- 获取全局插件属性配置
local plugin_attr = core.config.local_conf().plugin_attr or {}
local aes_grpc_attrs = plugin_attr[plugin_name] or {}

local schema = {
    type = "object",
    properties = {
        redis_host = {type = "string", default = aes_grpc_attrs.redis_host or "192.168.1.28"},
        redis_port = {type = "integer", default = aes_grpc_attrs.redis_port or 6379},
        redis_timeout = {type = "integer", default = aes_grpc_attrs.redis_timeout or 1000},
        redis_password = {type = "string", default = aes_grpc_attrs.redis_password or "123456"},
        redis_database = {type = "integer", default = aes_grpc_attrs.redis_database or 6},
        app_prefix = {type = "string", default = aes_grpc_attrs.app_prefix or "app:"},
        error_key = {type = "string", default = aes_grpc_attrs.error_key or "0123456789012345"},
        error_iv = {type = "string", default = aes_grpc_attrs.error_iv or "0123456789012345"},
    },
    required = {"redis_host"}
}

local _M = {
    version = 0.1,
    priority = 1000, -- 调高优先级，确保在 Encode 之前执行
    name = plugin_name,
    schema = schema
}

-- 获取Redis连接
local function get_redis_connection(conf)
    local red = redis:new()
    local host = conf.redis_host or aes_grpc_attrs.redis_host or "127.0.0.1"
    local port = conf.redis_port or aes_grpc_attrs.redis_port or 6379
    local timeout = conf.redis_timeout or aes_grpc_attrs.redis_timeout or 1000
    local password = conf.redis_password or aes_grpc_attrs.redis_password or ""
    local database = conf.redis_database or aes_grpc_attrs.redis_database or 0

    red:set_timeout(timeout)
    local ok, err = red:connect(host, port)
    if not ok then
        core.log.error("Failed to connect to Redis: ", err)
        return nil, err
    end

    if password and password ~= "" then
        local auth_ok, auth_err = red:auth(password)
        if not auth_ok then
            red:close()
            return nil, auth_err
        end
    end

    if database and database ~= 0 then
        local sel_ok, sel_err = red:select(database)
        if not sel_ok then
            red:close()
            return nil, sel_err
        end
    end
    return red
end

local app_info_cache, err = lrucache.new(1000)
if not app_info_cache then
    core.log.error("failed to create the cache: " .. (err or "unknown"))
end

-- 从Redis获取应用信息
local function get_app_info_from_redis(conf, app_id, app_version)
    local app_prefix = conf.app_prefix or aes_grpc_attrs.app_prefix
    local cache_key = app_prefix .. app_id .. ":" .. app_version

    -- [优化点 A] 第一层：先查本地内存缓存
    if app_info_cache then
        local cached_info = app_info_cache:get(cache_key)
        if cached_info then
            core.log.info("Hit local cache for: ", cache_key)
            return cached_info, nil
        end
    end

    -- [原有逻辑] 缓存未命中，连接 Redis
    local red, err = get_redis_connection(conf)
    if not red then
        return nil, "Failed to connect to Redis: " .. (err or "unknown error")
    end

    local app_info_json, err = red:get(cache_key)

    -- 放回连接池
    local ok, keepalive_err = red:set_keepalive(10000, 100)
    if not ok then
        core.log.warn("Failed to set Redis keepalive: ", keepalive_err)
        red:close()
    end

    if not app_info_json or app_info_json == ngx.null then
        return nil, "App info not found for app_id: " .. app_id
    end

    local app_info, err = json.decode(app_info_json)
    if not app_info then
        return nil, "Failed to decode app info JSON"
    end

    -- 验证必要字段
    if not app_info.app_secret or not app_info.crypt_key or not app_info.crypt_iv then
        return nil, "Missing required fields in app info"
    end

    -- [优化点 B] 将结果写入本地缓存
    -- 最后一个参数是过期时间（秒），这里设为 60 秒
    -- 意味着修改 Redis 后，最长需要 60 秒才能在网关生效
    if app_info_cache then
        app_info_cache:set(cache_key, app_info, 60)
        core.log.info("Set local cache for: ", cache_key)
    end

    return app_info, nil
end

-- 递归对 Table 进行 Key 排序并序列化，确保与前端 JSON.stringify 一致
local function deterministic_json_encode(val)
    local t = type(val)
    if t == "table" then
        if val == ngx.null then return "null" end
        
        -- 判断是否为数组
        local is_array = false
        if #val > 0 then is_array = true end
        if #val == 0 and next(val) == nil then is_array = true end 

        -- 检查是否真的是 Array
        local keys = {}
        local is_real_array = true
        for k, _ in pairs(val) do
            if type(k) ~= "number" then
                is_real_array = false
            end
            table.insert(keys, k)
        end
        if #keys == 0 then is_real_array = false end

        if is_real_array then
            -- 数组：对每个元素递归
            local parts = {}
            for i, elem in ipairs(val) do
                table.insert(parts, deterministic_json_encode(elem))
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            -- 对象：按 Key 排序
            table.sort(keys)
            local parts = {}
            for _, k in ipairs(keys) do
                local v = val[k]
                table.insert(parts, '"' .. k .. '":' .. deterministic_json_encode(v))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    elseif t == "string" then
        -- [修改点]：使用 cjson.encode 自动处理字符串的转义（如 \ -> \\, " -> \"）
        -- cjson.encode("a\b") 会返回 "a\\b"，自带双引号
        return cjson.encode(val)
    elseif t == "boolean" then
        return val and "true" or "false"
    elseif t == "number" then
        return tostring(val)
    elseif val == ngx.null then
        return "null"
    else
        -- 对于其他类型，兜底使用 cjson 转换，最稳妥
        return cjson.encode(val)
    end
end

-- 处理签名中值的字符串转换
local function serialize_value_for_sign(value)
    if value == ngx.null or value == nil then
        return "null" -- 修复：明确返回字符串 "null"
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    elseif type(value) == "table" then
        -- 使用确定性编码
        return deterministic_json_encode(value)
    else
        return tostring(value)
    end
end

-- 生成签名
local function generate_sign(params, app_secret)
    local keys = {}
    for k in pairs(params) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local sign_str = ""
    for _, key in ipairs(keys) do
        if key ~= "sign" then
            local value = params[key]
            -- 使用修复后的序列化函数
            local str_val = serialize_value_for_sign(value)
            sign_str = sign_str .. key .. "=" .. str_val .. "&"
        end
    end
    sign_str = sign_str .. "secret_key=" .. app_secret

    local md5_obj = md5:new()
    md5_obj:update(sign_str)
    local digest = md5_obj:final()

    local hex_digest = string.gsub(digest, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)

    -- 打印调试日志，方便对比
    --core.log.warn("Lua Sign Str: [", sign_str, "]")
    --core.log.warn("Lua Sign Result: ", string.lower(hex_digest))

    return string.lower(hex_digest), sign_str
end

-- 验证签名
local function verify_signature(params, app_secret, expected_sign)
    local actual_sign, sign_str = generate_sign(params, app_secret)
    local flag = actual_sign == string.lower(expected_sign)

    if not flag then
        core.log.warn("Signature verification failed: ", "Sign str: [ ", sign_str, " ] server: [ ", actual_sign, " ] client: [ ", expected_sign, " ]")
    end

    return flag
end

-- 解密数据
local function decrypt_with_specific_iv(encrypted_data, key, iv)
    -- 替换空格为 +
    local url_safe_data = encrypted_data:gsub(' ', '+')
    -- 添加 base64 解码
    local b64_decoded = ngx.decode_base64(url_safe_data)
    if not b64_decoded then
        return nil, "Failed to decode base64 data"
    end

    local ctx = ffi.C.EVP_CIPHER_CTX_new()
    if not ctx then
        return nil, "Failed to create cipher context"
    end

    local cipher = ffi.C.EVP_aes_128_cbc()
    local key_bytes = ffi.cast("unsigned char*", key)
    local iv_bytes = ffi.cast("unsigned char*", iv)

    local ret = ffi.C.EVP_DecryptInit_ex(ctx, cipher, nil, key_bytes, iv_bytes)
    if ret ~= 1 then
        ffi.C.EVP_CIPHER_CTX_free(ctx)
        return nil, "Failed to initialize decryption"
    end

    -- 使用解码后的数据
    local encrypted_bytes = ffi.cast("const unsigned char*", b64_decoded)
    local encrypted_len = #b64_decoded
    local max_output_len = encrypted_len + 16
    local output_buffer = ffi.new("unsigned char[?]", max_output_len)
    local output_len = ffi.new("int[1]")
    local final_len = ffi.new("int[1]")

    ret = ffi.C.EVP_DecryptUpdate(ctx, output_buffer, output_len, encrypted_bytes, encrypted_len)
    if ret ~= 1 then
        ffi.C.EVP_CIPHER_CTX_free(ctx)
        return nil, "Failed to decrypt update"
    end

    ret = ffi.C.EVP_DecryptFinal_ex(ctx, output_buffer + output_len[0], final_len)
    ffi.C.EVP_CIPHER_CTX_free(ctx)

    if ret ~= 1 then
        return nil, "Failed to decrypt final"
    end

    local total_len = output_len[0] + final_len[0]
    local result = ffi.string(output_buffer, total_len)

    -- 移除 PKCS7 填充
    if total_len > 0 then
        local pad_len = string.byte(result, total_len)
        if pad_len <= 16 and pad_len <= total_len then
            result = string.sub(result, 1, total_len - pad_len)
        end
    end

    return result
end

-- 错误处理辅助函数
local function return_encrypted_error(conf, ctx, code, message, key, iv)
    ctx.aes_key = key
    ctx.aes_iv = iv
    ctx.response_processed = true
    -- 确保 error_response 结构正确
    ctx.error_response = { code = code, message = message }

    -- 打印日志
    core.log.warn("Request Decode Error: ", message, " Code: ", code)

    ngx.status = code
    ngx.exit(code)
end

function _M.rewrite(conf, ctx)
    local headers = ngx.req.get_headers()
    local app_id = headers["x-app-id"]
    local app_version = headers["x-app-version"]
    local sign_header = headers["x-sign"]

    local error_key = conf.error_key or aes_grpc_attrs.error_key
    local error_iv = conf.error_iv or aes_grpc_attrs.error_iv

    if not app_id or not app_version or not sign_header then
        return return_encrypted_error(conf, ctx, 400, "Missing required headers", error_key, error_iv)
    end

    local app_info, err = get_app_info_from_redis(conf, app_id, app_version)
    if not app_info then
        return return_encrypted_error(conf, ctx, 400, "App info error: " .. (err or ""), error_key, error_iv)
    end

    local aes_key = app_info.crypt_key
    local aes_iv = app_info.crypt_iv
    local app_secret = app_info.app_secret

    ctx.aes_key = aes_key
    ctx.aes_iv = aes_iv

    local method = ngx.req.get_method()
    local decrypted_str

    if method == "GET" then
        local args = ngx.req.get_uri_args()
        if args.data then
            decrypted_str, err = decrypt_with_specific_iv(args.data, aes_key, aes_iv)
        end
    elseif method == "POST" then
        local body = core.request.get_body()
        if body then
            decrypted_str, err = decrypt_with_specific_iv(body, aes_key, aes_iv)
        end
    else
        return return_encrypted_error(conf, ctx, 405, "Method not supported", aes_key, aes_iv)
    end

    if err or not decrypted_str then
        core.log.warn("Decryption failed: ", tostring(err))
        return return_encrypted_error(conf, ctx, 400, "Decryption failed: " .. (err or ""), aes_key, aes_iv)
    end

    local req_data, json_err = json.decode(decrypted_str)
    if json_err or not req_data then
        return return_encrypted_error(conf, ctx, 400, "Invalid JSON", aes_key, aes_iv)
    end

    -- 验证时间戳
    local ts = tonumber(req_data.timestamp)
    if not ts then
        return return_encrypted_error(conf, ctx, 400, "Missing timestamp", aes_key, aes_iv)
    end
    -- 注意前端传的是毫秒，这里转秒
    local diff = ngx.time() - (ts / 1000)
    if math.abs(diff) > 60 then
        return return_encrypted_error(conf, ctx, 400, "Request expired or invalid time", aes_key, aes_iv)
    end

    -- 验证签名
    if not verify_signature(req_data, app_secret, sign_header) then
        return return_encrypted_error(conf, ctx, 400, "Sign verify failed", aes_key, aes_iv)
    end

    -- 覆写请求数据传给后端
    if method == "GET" then
        ngx.req.set_uri_args(req_data)
    else
        ngx.req.read_body()
        ngx.req.set_body_data(decrypted_str)
        ngx.req.set_header("Content-Type", "application/json")
        ngx.req.set_header("Content-Length", #decrypted_str)
    end
end

return _M