#!/bin/bash

set -e

IDF_VER=v5.4.1

docker build \
  --build-arg IDF_VER=$IDF_VER \
  -t esp-idf-ubuntu20:$IDF_VER \
  -f esp20.04.dockerfile .

docker build \
  --build-arg IDF_VER=$IDF_VER \
  --build-arg IDF_TARGET=esp32 \
  --build-arg USER_ID=espidf \
  --build-arg TZ_ARG=Asia/Tokyo \
  -t micro-ros-docker \
  -f micro-ros.dockerfile .
