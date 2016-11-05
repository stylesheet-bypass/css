function zones(ad_zone)
    local ad_zones = {}
    ad_zones[0] = {}
    ad_zones[0]['video_url'] = 'http://127.0.0.1/300x250.mp4'
    ad_zones[0]['type'] = 'video'
    ad_zones[0]['width'] = 300
    ad_zones[0]['height'] = 250
    ad_zones[1] = {}
    ad_zones[1]['img_url'] = 'http://127.0.0.1/adblock_300x250.jpg'
    ad_zones[1]['type'] = 'image'
    ad_zones[1]['width'] = 300
    ad_zones[1]['height'] = 250
    ad_zones[2] = {}
    ad_zones[2]['img_url'] = 'http://127.0.0.1/dollar_300x250.jpg'
    ad_zones[2]['type'] = 'image'
    ad_zones[2]['width'] = 300
    ad_zones[2]['height'] = 250

    local out = ad_zones[tonumber(ad_zone)] or ad_zones[0]
    out['ad_zone'] = tonumber(ad_zone)

    return out
end

function build_html(ad)
    local template = ''
    if ad['type'] == 'video' then
        template = "<html><body><video src='%s' autoplay loop width='%s' height='%s'></video></body></html>"
    else
        template = "<html><body><img src='%spx' width='%spx' height='%s' />"
    end
    local out = string.format(template, ad['url'], ad['width'], ad['height'])
    return out
end

function main()
    cjson = require "cjson"
    -- if ?/& clientip is not specified, use remote_addr
    ngx.ctx['real_client_ip'] = ngx.var.arg_clientip or ngx.var.remote_addr
    -- get an ad based on ad_zone input, or return the default video ad
    -- encode the output as json and return
    local out = ''
    if tonumber(ngx.var.output_format) == 0 then
        out = cjson.encode(zones(ngx.var.ad_zone))
    else
        out = build_html(zones(ngx.var.ad_zone))
    end
    ngx.say(out)
    ngx.exit(200)
end

main()
