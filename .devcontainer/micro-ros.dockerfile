FROM esp-idf-ubuntu20:v5.4.1
#FROM espressif/idf:v5.4.1

ENV DEBIAN_FRONTEND noninteractive

RUN echo "Set disable_coredump false" >> /etc/sudo.conf
RUN apt update -q && \
    apt install -yq sudo lsb-release gosu nano && \
    rm -rf /var/lib/apt/lists/*

ARG TZ_ARG=UTC
ENV TZ=$TZ_ARG
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#install esp-idf
#ENV IDF_PATH=/opt/esp/idf
#ENV IDF_TOOLS_PATH=/opt/esp
#ENV IDF_PYTHON_CHECK_CONSTRAINTS=no
#ENV IDF_CCACHE_ENABLE=1

#ARG IDF_VER v5.4.1
#ARG IDF_TARGET all

#RUN apt-get update && apt-get install -y \
#  git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

#WORKDIR /opt/esp
#RUN git clone -b $IDF_VER --recursive https://github.com/espressif/esp-idf.git idf
#WORKDIR /opt/esp/idf
#RUN IDF_TOOLS_PATH="/opt/esp/tools" ./install.sh all
#COPY ./entrypoint.sh /opt/esp/entrypoint.sh

COPY ./install_micro_ros_deps_script.sh /install_micro_ros_deps_script.sh

RUN mkdir -p /tmp/install_micro_ros_deps_script && mv /install_micro_ros_deps_script.sh /tmp/install_micro_ros_deps_script/ && \
    IDF_EXPORT_QUIET=1 /tmp/install_micro_ros_deps_script/install_micro_ros_deps_script.sh && \
    rm -rf /var/lib/apt/lists/*

#RUN /usr/bin/pip3 --no-cache-dir install catkin_pkg lark-parser colcon-common-extensions importlib-resources
RUN python3.12 -m pip install --upgrade pip setuptools && \
    python3.12 -m pip install --no-cache-dir \
        catkin_pkg lark-parser colcon-common-extensions importlib-resources
ARG USER_ID=espidf

RUN useradd --create-home --home-dir /home/$USER_ID --shell /bin/bash --user-group --groups adm,sudo $USER_ID && \
    echo $USER_ID:$USER_ID | chpasswd && \
    echo "$USER_ID ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ARG USER_ID
USER $USER_ID

WORKDIR /project
ENTRYPOINT ["/opt/esp/entrypoint.sh"]
CMD ["/bin/bash"]

