ARG ROS_DIST=humble
FROM ros:$ROS_DIST

ARG IDF_VER
ARG IDF_TARGET

#install esp-idf
RUN apt-get update && apt-get install -y \
  git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

WORKDIR /root/esp
RUN git clone -b $IDF_VER --recursive https://github.com/espressif/esp-idf.git

RUN cd esp-idf && ./install.sh $IDF_TARGET

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /project
RUN git config --global --add safe.directory /project
RUN pip3 install catkin_pkg lark-parser colcon-common-extensions

