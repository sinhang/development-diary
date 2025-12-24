-- 导入所需模块
local core = require("apisix.core")
local ngx = ngx
local require = require
local json = require("apisix.core.json")
local redis = require("resty.redis")
local ffi = require("ffi")
local cjson = require("cjson")
local lrucache = require("resty.lrucache")

-- FFI 定义
ffi.cdef[[
    typedef struct evp_cipher_ctx_st EVP_CIPHER_CTX;
    typedef struct evp_cipher_st EVP_CIPHER;
    EVP_CIPHER_CTX *EVP_CIPHER_CTX_new(void);
    void EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *ctx);
    int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher, void *impl, const unsigned char *key, const unsigned char *iv);
    int EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
    int EVP_EncryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl);
    const EVP_CIPHER *EVP_aes_128_cbc(void);
]]

local plugin_name = "aes-response-encode"

-- 初始化本地一级缓存 (L1 Cache)
local app_info_cache, _ = lrucache.new(200)

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
    priority = 0,
    name = plugin_name,
    schema = schema
}

-- 获取 Redis 连接
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

-- 获取应用信息（含 L1 缓存）
local function get_app_info_from_redis(conf, app_id, app_version)
    local app_prefix = conf.app_prefix or aes_grpc_attrs.app_prefix
    local cache_key = app_prefix .. app_id .. ":" .. app_version

    -- 1. 查本地缓存
    if app_info_cache then
        local cached = app_info_cache:get(cache_key)
        if cached then return cached, nil end
    end

    -- 2. 查 Redis
    local red, err = get_redis_connection(conf)
    if not red then
        return nil, "Redis connection failed: " .. (err or "unknown")
    end

    local app_info_json, err = red:get(cache_key)
    red:set_keepalive(10000, 100)

    if not app_info_json or app_info_json == ngx.null then
        return nil, "App info not found"
    end

    local app_info, err = json.decode(app_info_json)
    if not app_info then
        return nil, "JSON decode failed"
    end

    if not app_info.crypt_key or not app_info.crypt_iv then
        return nil, "Missing key/iv"
    end

    -- 3. 写入本地缓存 (60秒过期)
    if app_info_cache then
        app_info_cache:set(cache_key, app_info, 60)
    end

    return app_info, nil
end

local function encrypt_with_specific_iv(plaintext, key, iv)
    local block_size = 16
    local ctx = ffi.C.EVP_CIPHER_CTX_new()
    if not ctx then return nil, "Failed to create context" end

    local cipher = ffi.C.EVP_aes_128_cbc()
    local ret = ffi.C.EVP_EncryptInit_ex(ctx, cipher, nil, ffi.cast("unsigned char*", key), ffi.cast("unsigned char*", iv))
    if ret ~= 1 then
        ffi.C.EVP_CIPHER_CTX_free(ctx)
        return nil, "Init failed"
    end

    local len = #plaintext
    local out_buf = ffi.new("unsigned char[?]", len + block_size)
    local out_len = ffi.new("int[1]")
    local final_len = ffi.new("int[1]")

    ffi.C.EVP_EncryptUpdate(ctx, out_buf, out_len, ffi.cast("const unsigned char*", plaintext), len)
    ffi.C.EVP_EncryptFinal_ex(ctx, out_buf + out_len[0], final_len)
    ffi.C.EVP_CIPHER_CTX_free(ctx)

    return ngx.encode_base64(ffi.string(out_buf, out_len[0] + final_len[0]))
end

local function mark_empty_arrays(tbl)
    if type(tbl) ~= "table" then return tbl end
    if next(tbl) == nil then return setmetatable({}, cjson.empty_array_mt) end
    for k, v in pairs(tbl) do
        if type(v) == "table" then tbl[k] = mark_empty_arrays(v) end
    end
    return tbl
end

-- 错误处理工具
local function return_encrypted_error(conf, ctx, code, message, key, iv)
    -- 这里我们只做标记，让 Header filter 和 Body filter 处理
    -- 但如果 rewrite 阶段直接出错，我们需要提前设置好 error_response
    ctx.error_response = { code = code, message = message }
    ctx.aes_key = key
    ctx.aes_iv = iv
    ctx.response_processed = true

    -- 直接退出 rewrite，进入响应阶段，status 设置为 code
    ngx.status = code
    ngx.exit(code)
end

-- Rewrite 阶段：初始化密钥和状态
function _M.rewrite(conf, ctx)
    -- 优化：如果 request-decode 插件已经运行并获取了密钥，直接复用
    if ctx.aes_key and ctx.aes_iv then
        ctx.response_processed = true
        return
    end

    -- 否则尝试自己获取
    local headers = ngx.req.get_headers()
    local app_id = headers["x-app-id"]
    local app_version = headers["x-app-version"]

    local error_key = conf.error_key or aes_grpc_attrs.error_key
    local error_iv = conf.error_iv or aes_grpc_attrs.error_iv

    if not app_id or not app_version then
        -- 如果连 Header 都没有，可能不是合法的加密请求，选择放行还是报错？
        -- 根据原有逻辑是报错。
        return return_encrypted_error(conf, ctx, 400, "Missing required headers", error_key, error_iv)
    end

    local app_info, err = get_app_info_from_redis(conf, app_id, app_version)
    if not app_info then
        return return_encrypted_error(conf, ctx, 400, "App info error: " .. (err or ""), error_key, error_iv)
    end

    ctx.aes_key = app_info.crypt_key
    ctx.aes_iv = app_info.crypt_iv
    ctx.response_processed = true
end

-- Header Filter：处理状态码和 Content-Length
function _M.header_filter(conf, ctx)
    if not ctx.response_processed then return end

    -- 如果有预设的错误响应，强制设置状态码
    if ctx.error_response and ctx.error_response.code then
        ngx.status = ctx.error_response.code
    end

    -- 总是清除 Content-Length，因为我们要修改 Body
    ngx.header.content_length = nil
    ngx.header.content_type = "application/json"
end

-- Body Filter：加密响应体
function _M.body_filter(conf, ctx)
    if not ctx.response_processed then return end

    local body = ngx.arg[1]
    local eof = ngx.arg[2]

    if not ctx.body_buffer then ctx.body_buffer = "" end
    if body and body ~= "" then ctx.body_buffer = ctx.body_buffer .. body end

    if not eof then
        ngx.arg[1] = nil
        return
    end

    local raw_body = ctx.body_buffer
    local aes_key = ctx.aes_key
    local aes_iv = ctx.aes_iv
    local status = ngx.status

    local final_response = {}

    -- 错误处理逻辑
    if ctx.error_response or status ~= 200 then
        local msg = "Unknown error"
        local code = status

        if ctx.error_response then
            msg = ctx.error_response.message or "Unknown response error"
            if msg == "Unknown response error" then
                core.log.error("Error response: " .. ctx.error_response.message)
            end
        else
            -- 尝试解析上游错误 JSON
            local ok, upstream_err = pcall(json.decode, raw_body)
            if ok and type(upstream_err) == "table" then
                msg = upstream_err.error.message or raw_body or "Unknown upstream error"
                if msg == "Unknown upstream error" then
                    core.log.error("Upstream error: " .. raw_body)
                end
            else
                if not raw_body or raw_body == "" then
                    msg = "Empty response from gRPC service"
                elseif raw_body and string.find(raw_body, "<title>400 Bad Request</title>") then
                    msg = "Request parameter validation failed: Type mismatch or invalid format"
                    core.log.error("Upstream elseif 1 error: " .. raw_body)
                elseif raw_body and string.find(raw_body, "<html>") then
                    local title_match = string.match(raw_body, "<title>([^<]+)</title>")
                    msg = title_match or "Bad Request"
                    if msg == "Bad Request" then
                        core.log.error("Upstream elseif 2 error: " .. raw_body)
                    end
                else
                    msg = raw_body or "Server Error"
                    if msg ~= "Server Error" then
                        core.log.error("Upstream else error: " .. raw_body)
                    end
                end
            end
        end

        -- 确保消息不为空
        if not msg or msg == "" then
            msg = "Server Error"
        end

        final_response = {
            code = code,
            message = msg,
            data = {}
        }
    else
        -- 成功响应处理
        local data, err = json.decode(raw_body)
        if not data then
            -- 如果上游返回的不是 JSON (比如 502/504 的 HTML)，这里会捕获
            final_response = { code = 500, message = "Invalid upstream response", data = {} }
        else
            local encrypted_data, enc_err = encrypt_with_specific_iv(json.encode(mark_empty_arrays(data)), aes_key, aes_iv)
            if enc_err then
                final_response = { code = 500, message = "Encrypt failed: " .. (enc_err or ""), data = {} }
            else
                final_response = {
                    code = 200,
                    message = "ok",
                    data = encrypted_data,
                    decode = data -- 调试用，生产可注释掉
                }
            end
        end
    end

    local json_str = json.encode(final_response)
    ngx.arg[1] = json_str
    ctx.body_buffer = nil
end

return _M