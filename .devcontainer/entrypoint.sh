#!/bin/bash
set -e

# setup ros2 environment
. /root/esp/esp-idf/export.sh

#source "/opt/ros/$ROS_DISTRO/setup.bash" --

exec "$@"
