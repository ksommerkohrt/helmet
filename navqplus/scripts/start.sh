#!/bin/bash
sudo ethtool -s eth0 master-slave forced-slave
sudo ifconfig eth0 192.0.2.2 netmask 255.255.255.0
