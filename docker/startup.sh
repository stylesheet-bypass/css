#!/bin/bash
cd /tmp/python 
python3 css.py &
cd /tmp/php
php -S 0.0.0.0:8002 index.php &
/usr/local/openresty/nginx/sbin/nginx
