# StyleSheet Bypass
#
# https://github.com/stylesheet-bypass/css
#
#
FROM        ubuntu:16.04
MAINTAINER  Stylesheet Bypass <stylesheet.bypass@gmail.com>

WORKDIR     /tmp/workdir

# https://openresty.org/download/openresty-1.11.2.1.tar.gz

ENV         OPENRESTY_VERSION=1.11.2.1 \
            SRC=/usr/local

COPY    index.php composer.json /tmp/php/
COPY    AdMediaEncoder.php /tmp/php/src/

RUN      buildDeps="build-essential \
                    libpcre3-dev \
                    libssl-dev \
                    libgeoip-dev \
                    python3 \
                    python3-requests \
                    python3-flask \
                    composer \
                    php \
                    unzip \
                    git \
                    curl" && \
        export MAKEFLAGS="-j$(($(nproc) + 1))" && \
        apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ${buildDeps} ca-certificates && \
        DIR=$(mktemp -d) && cd ${DIR} && \
## openresty http://openresty.org/en/download.html
        curl -sL https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --with-debug --with-http_geoip_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module && \
        make && \
        make install && \
        rm -rf ${DIR} && \
## composer install
        cd /tmp/php && \
        composer install

COPY    ads.lua css.lua adblock.lua nginx.conf /usr/local/openresty/nginx/conf/
COPY    dollar_300x250.jpg adblock_300x250.jpg 300x250.mp4 /tmp/htdocs/
COPY    resty /usr/local/openresty/nginx/conf/resty/
COPY    adblock.py css.py /tmp/python/
COPY    startup.sh /tmp/

ENTRYPOINT ["/tmp/startup.sh"]
CMD ["/bin/bash","/tmp/startup.sh"]
