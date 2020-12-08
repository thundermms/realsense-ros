FROM ros:melodic-perception-bionic

ENV ROS_DISTRO melodic

RUN apt-get -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  software-properties-common \
  wget \
  python-rosinstall \
  python-catkin-tools \
  ros-melodic-jsk-tools \
  ros-melodic-image-transport-plugins \
  ros-melodic-image-transport \
  ros-melodic-ddynamic-reconfigure \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /home/3rdparty
RUN git clone https://github.com/IntelRealSense/librealsense.git 
RUN apt-get -q -qq update && apt-get install -y libusb-1.0-0-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev
WORKDIR /home/3rdparty/librealsense
RUN ./scripts/patch-realsense-ubuntu-lts.sh
RUN cd librealsense/ && git checkout v2.39.0 && mkdir build && cd build && \
    cmake -DBUILD_EXAMPLES=false -DBUILD_GRAPHICAL_EXAMPLES=false .. && \
    make -j6 && \
    make install

WORKDIR /home/catkin_ws

COPY realsense2_camera src/realsense2_camera
COPY realsense2_description src/realsense2_description
RUN /ros_entrypoint.sh catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release && \
    sed -i '$isource "/home/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]