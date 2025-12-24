local plugin_name = "rs256-jwt-auth"
local jwt = require("resty.jwt")

local _M = {
    version = 0.1,
    priority = 1000,
    name = plugin_name,
    schema = {
        type = "object",
        properties = {
            token_header = { type = "string", default = "Authorization" },
            user_id_header = { type = "string", default = "X-User-ID" },
            public_key_path = { type = "string" },
            public_key = { type = "string" },
            algorithm = { type = "string", default = "RS256" }
        }
    }
}

local function extract_token(req, header_name)
    local auth_header = req.get_headers()[header_name]
    if not auth_header then return nil end
    if type(auth_header) == "table" then auth_header = auth_header[1] end

    local token = string.match(auth_header, "[Bb]earer%s+(.+)")
    return token
end

function _M.rewrite(conf, ctx)
    -- 加载公钥
    local public_key = conf.public_key
    if not public_key and conf.public_key_path then
        local f = io.open(conf.public_key_path, "r")
        if f then
            public_key = f:read("*a")
            f:close()
        end
    end

    if not public_key then
        ngx.log(ngx.ERR, "Missing public key configuration")
        return 500
    end

    local token = extract_token(ngx.req, conf.token_header)
    if not token then
        ngx.status = 401
        ngx.say('{"code":401,"message":"Authorization required"}')
        return ngx.exit(401)
    end

    local jwt_obj = jwt:verify(public_key, token)
    if not jwt_obj or not jwt_obj.verified then
        ngx.status = 401
        ngx.say('{"code":401,"message":"Invalid token: ' .. (jwt_obj.reason or "unknown") .. '"}')
        return ngx.exit(401)
    end

    local payload = jwt_obj.payload
    if not payload.user_id then
        ngx.status = 401
        ngx.say('{"code":401,"message":"Token missing user_id"}')
        return ngx.exit(401)
    end

    -- 传递用户信息到后端
    ngx.req.set_header(conf.user_id_header, tostring(payload.user_id))
    if payload.username then
        ngx.req.set_header("X-User-Name", tostring(payload.username))
    end
end

return _M