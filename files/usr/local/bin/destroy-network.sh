#!/bin/sh -xe

#if [ "$EUID" != "0" ]; then
#	echo "Must be root"
#	exit 1
#fi

ip link set dev enp1s0f0 nomaster
ip link set dev enp1s0f1 nomaster
ip link set dev enp1s0f2 nomaster
ip link set dev enp1s0f3 nomaster

ip link set dev wlp4s0 nomaster || true
ip link set dev wlan1a nomaster || true
ip link set dev wlan1b nomaster || true

ip link del br0

#/bin/sh -c 'nft flush table nat || true'

