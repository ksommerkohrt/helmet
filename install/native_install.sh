#!/bin/bash
set -e
set -x

pushd ~/cognipilot/helmet/install

./scripts/base.sh
./scripts/zephyr.sh
./scripts/ros.sh
./scripts/gazebo.sh
./scripts/user_setup.sh native

# install zeth config
sudo mkdir -p /opt/zeth

if ! [ -f  /opt/zeth/zeth.conf ]
then
  sudo cp ./resources/zeth.conf /opt/zeth
fi

if ! [ -f  /opt/zeth/net-setup.sh ]
then
  sudo cp ./resources/net-setup.sh /opt/zeth
fi

# install scripts
cp ./resources/build_mrbuggy3_sitl ~/bin
cp ./resources/cyecca ~/bin
cp ./resources/docs ~/bin

popd
