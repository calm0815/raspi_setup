#!/bin/bash

pwd_dir=$(pwd)

if [ "$2" = "--auto" ]; then
	auto_flg=1
else
	auto_flg=0
fi

echo "
    ██████╗  ██████╗ ███████╗      
    ██╔══██╗██╔═══██╗██╔════╝      
    ██████╔╝██║   ██║███████╗      
    ██╔══██╗██║   ██║╚════██║      
    ██║  ██║╚██████╔╝███████║      
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝      
                                                                          
    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝"

echo "Link ROS repository to Raspbian"
sudo apt update
sudo apt upgrade -yV
sudo apt install dirmngr -yV
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt update

echo "Install related program"
sudo apt install -yV python-rosdep python-rosinstall-generator python-wstool python-rosinstall python-empy build-essential cmake

echo "Create workspace"
sudo rosdep init
rosdep update
mkdir ~/ros_catkin_ws

echo "Place source code (desktop)"
cd ~/ros_catkin_ws/
rosinstall_generator desktop --rosdistro melodic --deps --tar > melodic-desktop.rosinstall
wstool init -j2 src_isolated melodic-desktop.rosinstall

echo "Install dependent program"
cd ~/ros_catkin_ws/
rosdep install --from-paths src_isolated --ignore-src --rosdistro melodic -y

echo "Update problematic dependent programs"
cd ~/ros_catkin_ws/src_isolated/
rm -r ros_comm
git clone https://github.com/ros/ros_comm.git

echo "Install the latest version of tinyxml2"
mkdir ~/gitprojects
cd ~/gitprojects
git clone https://github.com/leethomason/tinyxml2.git
cd tinyxml2
mkdir build
cd build
cmake ..
make
sudo make install
cd /usr/lib/arm-linux-gnueabihf/
sudo rm libtinyxml2.so
sudo ln -s /usr/local/lib/libtinyxml2.so libtinyxml2.so

echo "Build"
cd ~/ros_catkin_ws
./src_isolated/catkin/bin/catkin_make_isolated -j1 --install --source src_isolated -DCMAKE_BUILD_TYPE=Release

echo "Load ROS"
echo "source ~/ros_catkin_ws/devel_isolated/setup.bash" >> ~/.bashrc
source ~/.bashrc

echo "ROS(melodic) Install finished !!"
