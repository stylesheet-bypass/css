# Adblock - Stylesheet Bypass

### Why

The internet is not free.

Website publishers face an uphill battle against browser-based Adblock extensions.

Ad-supported sites face adoption rates of 2-30% depending on the country that the traffic originates from.

[Adblock Plus] has released a new version of their extension in Chrome which begins to break your browser.
  - Previously, they [overwrote window.WebSocket()] with their own code.
  - Now, they blindly inject [Content Security Policy] HTTP headers to the browser ([ABP Commit]).
  - Any website requiring HTTPS-only connections is now open to simple MITM attacks via ABP allowing cleartext connections.
  - data: and blob: URIs are now forbidden for any site caught in [Easylist]'s $websocket rule
  - This breaks basic web functionality - iframe, WebSocket(), Worker().

Adblock Plus charges website publishers a percentage of the earned revenue to allow Ads to pass through their extension.
  - The natural evolution for Adblock Plus is to charge website owners to use browser functionality.
  - Adblock Plus is positioning themselves to profit from a website trying to use basic JavaScript functionality.

[EyeO] is the corporate entity behind Adblock Plus.
  - Their website says they want to "make the internet better", but in reality, by reducing the security imposed by websites, they are making it worse.
  - They try to make the appearance that Easylist and Adblock Plus are separate.
  - EyeO employee [Arthur Kawa, a.k.a MonztA], is an [Easylist author].
  - EyeO is positioned to create the rules which break your website, and then offer you a method to fix it - for a percentage of your revenue.
  - The initial reaction from EyeO to [Facebook's] adblock bypass effort was to instruct MonztA to [break facebook].

Website publishers will have limited options available to them to generate revenue from their content going forward.

### What
We have come up with a new method for monetizing your web traffic using Stylsheets.  In this repository, you will find a basic JavaScript sample which will run in the web browser.  It loads a given URL as a stylesheet and decodes the content property to a JS Object.  Once this is complete, your usual ad rendering process can complete.

There are two samples for the backend process, which calls a third party ad service, encodes the data in to a CSS and returns to the browser.

For simplicity, we created a mock ad service which will offer 3 ad zones with a 300x250 media -- either a video or an image.

### Getting started
There is a simple to use docker container here.  Here's how you can get started:

Build the new container
~~~~
bash ./build-docker.sh 
~~~~

Run the container, forward local port 8000 to container port 80
~~~~
docker run -d -p 8000:80 stylesheet-bypass
~~~~

This will compile openresty and set up a simple nginx server.  To simulate the flow, you can call it via

#### Mock Ad Service
~~~~
curl 127.0.0.1:8000/ads/1
~~~~

#### LUA Backend
~~~~
curl 127.0.0.1:8000/css_lua/1/css_callback1 
~~~~

#### Python Backend
~~~~
curl 127.0.0.1:8000/css_python/1/css_callback1
~~~~

#### PHP Backend
~~~~
curl 127.0.0.1:8000/css_php/1/css_callback1
~~~~

These samples aren't configured to be production ready, but should get you off to the right start.

Finally, once the data is encoded in to the stylesheet, simply have a look at our sample javascript for how to call it inside of the browser.

### Donations

  - Want to say thanks?  Send BTC to: 1CtsoiBnBHecxLUKAyV2HmCqJHxQi2eg95

### Contact

  - stylesheet.bypass@gmail.com

### License
MIT


   [Adblock Plus]: <https://adblockplus.org/>
   [Easylist]: <https://github.com/easylist/easylist>
   [Content Security Policy]: <https://www.w3.org/TR/CSP2/>
   [ABP Commit]: <https://hg.adblockplus.org/adblockpluschrome/rev/92bb84339f70>
   [overwrote window.WebSocket()]: <https://hg.adblockplus.org/adblockpluschrome/rev/20c6e8db2f5c>
   [Arthur Kawa, a.k.a MonztA]: <http://www.gesetze-bayern.de/(X(1)S(30d1ofgbgotxjbzqk1xtiwgj))/Content/Document/Y-300-Z-BECKRS-B-2015-N-09562?hl=true&AspxAutoDetectCookieSupport=1>
   [Easylist author]: <https://github.com/easylist/easylist/commits/master?author=monzta>
   [break facebook]: <https://github.com/easylist/easylist/commit/1fb0590737b4fc834eaf23c665591d68cb28600d>
   [EyeO]: <https://eyeo.com/>
   [Facebook's]: <https://newsroom.fb.com/news/2016/08/a-new-way-to-control-the-ads-you-see-on-facebook-and-an-update-on-ad-blocking/>
