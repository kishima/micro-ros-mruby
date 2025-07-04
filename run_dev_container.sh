#!/bin/bash

docker run -it --rm --group-add=dialout --privileged -v $PWD:/project micro-ros-docker:v5.4.1 bash
