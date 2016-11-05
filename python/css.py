import logging, adblock, base64, json
from flask import Flask, Response, request

app = Flask(__name__)

config = {
    "logfile": "/tmp/css.log",
    "logformat": "%(asctime)-15s %(filename)s:%(lineno)-4s - %(funcName)-30s - %(message)s",
    "loglevel": logging.DEBUG,
    "logname": "css_bypass",
    "host": "0.0.0.0",
    "port": 8001,
    "css_template": '#{}{{content:"{}"}}',
    "ad_url": "http://127.0.0.1/ads/{}",
    "adblock": {
        "encode_images": True,
        "encode_videos": True
    }
}

global log
logging.basicConfig(filename=config['logfile'], level=config['loglevel'], format=config['logformat'])
log = logging.getLogger(config['logname'])

@app.route('/css/<int:ad_zone>/<css_callback>')
def handle_css(ad_zone,css_callback):
    log.debug("Received ad_zone: {} and CSS callback: {}".format( ad_zone, css_callback ))
    ad_url = config['ad_url'].format( ad_zone, request.remote_addr )
    # log.debug("Generated AD URL: {}".format(ad_url))
    (body, headers) = adblock.fetch_url( ad_url )
    # log.debug("Remote ad response body: {}".format(body))
    json_ad = adblock.process_ads_response( body, headers )
    out = config['css_template'].format( css_callback, base64.b64encode(json_ad.encode()).decode() )
    # log.debug("CSS output: {}".format(out))

    return Response(response=out, status=200, mimetype="text/css")

if __name__ == '__main__':
    log.debug("Starting up from CLI")
    app.run(host=config['host'], port=config['port'], debug=True)
else:
    log.debug("Starting up from UWSGI")
