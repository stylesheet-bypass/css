import requests, copy, json, base64, logging

config = {
    "logfile": "/tmp/css.log",
    "logformat": "%(asctime)-15s %(filename)s:%(lineno)-4s - %(funcName)-30s - %(message)s",
    "loglevel": logging.DEBUG,
    "logname": "adblock",
}

global log
logging.basicConfig(filename=config['logfile'], level=config['loglevel'], format=config['logformat'])
log = logging.getLogger(config['logname'])

def fetch_url(url):
    res = requests.get(url)
    if res.status_code != 200:
        log.debug("failed request: {}, code: {}".format(url,res.status_code))
        return 1
    if "mp4" in url or "jpg" in url:
        body = res.content
    else:
        body = res.text
    headers = res.headers
    return (body, headers)

def base64_json(body):
    image_keys = {
        "img_url":"img_data",
        "logo_img_url":"logo_img_data",
        "poster_url":"poster_url_data"
    }
    output = copy.deepcopy(body)
    for key,url in body.items():
        if key in image_keys:
            content_type_key = "img_type"
            if key == "logo_img_url":
                content_type_key = "logo_img_type"
            if key == "poster_url":
                content_type_key = "poster_img_type"
            output_key = image_keys[key]
            image_body, headers = fetch_url(url)
            output[output_key] = str(base64.b64encode(image_body),'utf-8')
            output[content_type_key] = headers['Content-Type']
            del output[key]
    if 'video_url' in body:
        body, headers = fetch_url(body['video_url'])
        output['video_data'] = base64.b64encode(body)
        output['video_type'] = headers['Content-Type']
        del output['video_url']

    output['media_encoding'] = 1
    return output

def process_spot(body):
    output = base64_json(body)
    output = json.dumps(str(output))
    return output

def process_ads_response(body, headers):
    print(body)
    json_body = json.loads(body)
    if json_body['type'] == "image" or json_body['type'] == "video":
        adblock_friendly_out = process_spot(json_body)
        return adblock_friendly_out
    else:
        log.debug("Unhandled ad type: {}".format(json_body['type']))
        return 1
