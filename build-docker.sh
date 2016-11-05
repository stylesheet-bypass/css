#!/bin/bash

cp lua/*.lua docker/
cp nginx/*.conf docker/
cp files/* docker/
cp python/*.py docker/
cp php/*.php docker/
cp php/src/*.php docker/
cp php/composer.json docker/
cp -a lua/resty docker/
docker build docker -t stylesheet-bypass

