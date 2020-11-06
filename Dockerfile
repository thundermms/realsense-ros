FROM ros:melodic-ros-core

ENV ROS_DISTRO melodic

RUN apt-get -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  software-properties-common \
  wget \
  python-rosinstall \
  python-catkin-tools \
  ros-${ROS_DISTRO}-jsk-tools \
  ros-${ROS_DISTRO}-rgbd-launch \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-image-transport \
  ros-melodic-ddynamic-reconfigure



RUN echo 'deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main' || tee /etc/apt/sources.list.d/realsense-public.list && \ 
    apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keys.gnupg.net:80 --recv-key C8B3A55A6F3EFCDE && \
    add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" && \
    apt-get update -qq && \
    apt-get install librealsense2-dkms --allow-unauthenticated -y && \
    apt-get install librealsense2-dev --allow-unauthenticated -y

WORKDIR /home/catkin_ws

COPY realsense2_camera src/realsense2_camera
COPY realsense2_description src/realsense2_description
RUN /ros_entrypoint.sh catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release && \
    sed -i '$isource "/home/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]