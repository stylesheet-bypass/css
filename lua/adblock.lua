-- simple function to fetch URL and return body/headers
function fetch_url(url)
    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri(url)
    if not res then
        ngx.log(ngx.ERR, "failed request: ", url, "err: ", err)
        return ngx.exit(500)
    end
    return res.body, res.headers
end

-- function to read ads response and encode media as base64
function base64_json(body)
    local image_keys = {}
    image_keys['img_url'] = 'img_data'
    image_keys['logo_img_url'] = 'logo_img_data'
    image_keys['poster_url'] = 'poster_img_data'
    local output = body
    for key,url in pairs(body) do
        if image_keys[key] then
            local content_type_key = "img_type"
            if key == "logo_img_url" then content_type_key = "logo_img_type" end
            if key == "poster_url" then content_type_key = "poster_img_type" end
            local output_key = image_keys[key]
            -- add in your image caching layer here
            local body, headers = fetch_url(url)
            output[output_key] = ngx.encode_base64(body)
            output[content_type_key] = headers['Content-Type']
            output[key] = nil
        end
    end
    if body['video_url'] then
        -- add in your video caching layer here
        local body, headers = fetch_url(body['video_url'])
        output['video_data'] = ngx.encode_base64(body)
        output['video_type'] = headers['Content-Type']
        output['video_url'] = nil
    end
    output['media_encoding'] = 1
    output['ad_zone'] = ngx.ctx['ad_zone']
    ngx.log(ngx.ERR, "output: ", cjson.encode(output))
    return output
end

-- function to handle the response from ads service
function process_spot(body)
    if tonumber(ngx.ctx['output_format']) == 1 then
        local out = base64_json(body)
        return cjson.encode(base64_json(body))
    end
    -- else
        -- process your routine to generate adblock friendly HTML here
    -- end
end

-- function to check if the response is an iframe or media
function process_ads_response(body, headers)
    local json_body = cjson.decode(body)
    if json_body['type'] == "video" or json_body['type'] == "image" then
        local adblock_friendly_out = process_spot(cjson.decode(body))
        return adblock_friendly_out
    else
        ngx.log(ngx.ERR, "Unhandled ad type: ", json_body['type'])
        ngx.exit(503)
    end
end
