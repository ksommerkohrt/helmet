#!/bin/bash
./scripts/base.sh
./scripts/zephyr.sh
./scripts/ros.sh
./scripts/gazebo.sh
./scripts/user_setup.sh native

# install scripts
cp ./resources/build_mrbuggy3_sitl ~/bin
cp ./resources/cyecca ~/bin
cp ./resources/docs ~/bin
