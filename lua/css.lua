-- css.lua
--
-- simple openresty handler to generate adblock-friendly CSS
--
-- calls a remote ad service, parses through your existing Adblock Lua code, returns in CSS template
--
-- nginx configuration
--
-- location "^/css/(.+)/(.+)$" {
--     set $ad_zone $1;
--     set $css_callback $2
--     lua_code_cache off; # fast reloading but less performant
--     content_by_lua_file /path/to/css.lua;
--     expires -1;
--     default_type text/css;
-- }
--
function main()
    -- tell adblock.lua to encode images/videos as base64
    package.path = package.path .. ';/usr/local/openresty/nginx/conf/?.lua'
    ngx.ctx['encode_video'] = 1
    ngx.ctx['encode_images'] = 1
    ngx.ctx['output_format'] = 1
    local css_template = '#%s{content:"%s"}'
    cjson = require "cjson"
    require "adblock"
    local ad_zone = ngx.var.ad_zone or 32
    local css_callback = ngx.var.css_callback or "x_000000"
    local client_ip = ngx.var.remote_addr
    local ad_url = string.format( "http://127.0.0.1/ads/%s?format=json&clientip=%s", ad_zone, client_ip)
    --ngx.log(ngx.ERR, "calling URL: ", ad_url)
    -- get the data from the ad provider
    local body, headers = fetch_url( ad_url )
    --ngx.log(ngx.ERR, "response body: ", body)
    -- process the ad: encode images/video as base64, massage domain names to be adblock friendly, etc
    local json_ad = process_ads_response( body, headers, ad_zone )
    --ngx.log(ngx.ERR, "json_ad: ", json_ad)
    local out = string.format( css_template, css_callback, ngx.encode_base64(json_ad) )
    ngx.say(out)
    ngx.exit(200)
end

main()
