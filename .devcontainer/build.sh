#!/bin/bash

docker build \
  --build-arg ROS_DIST=humble \
  --build-arg IDF_VER=v5.4.1 \
  --build-arg IDF_TARGET=esp32,esp32s3 \
  --debug \
  -t buildcontainer-micro-ros-mruby .
