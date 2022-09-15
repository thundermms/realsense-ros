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
  libusb-1.0-0-dev \
  libglfw3-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libssl-dev \
  libusb-1.0-0-dev \
  pkg-config \
  libgtk-3-dev \
  && \
  apt-get install -y ros-melodic-rgbd-launch && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*



WORKDIR /home/3rdparty/librealsense
RUN git clone https://github.com/IntelRealSense/librealsense.git . && \
    git checkout v2.40.0 && mkdir build && cd build && \
    cmake ../ -DBUILD_EXAMPLES=false -DFORCE_LIBUVC=true -DBUILD_WITH_CUDA=false -DCMAKE_BUILD_TYPE=release -DBUILD_PYTHON_BINDINGS=bool:true && \
    make -j8 && \
    make install && \
    rm -rf /home/3rdparty/librealsense

WORKDIR /home/catkin_ws

COPY realsense2_camera src/realsense2_camera
COPY realsense2_description src/realsense2_description
COPY preset.json /root/preset.json
RUN /ros_entrypoint.sh catkin_make install -DCMAKE_INSTALL_PREFIX="/usr/local/realsense"  -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release && \
    sed -i '$isource "/usr/local/realsense/setup.bash"' /ros_entrypoint.sh && \
    rm -rf /home/catkin_ws

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
