#!/bin/sh -xe

disable_file=${2:-/etc/ryor/disable-upgrade}

if [ "$1" == "run" ]; then
	if [ ! -e "$disable_file" ]; then
		dnf upgrade -y --refresh
	else
		echo "${disable_file} exists, not upgrading software"
	fi
	systemctl reboot
elif [ "$1" == "disable" ]; then
	touch "$disable_file"
elif [ "$1" == "enable" ]; then
	rm -f "$disable_file"
else
	echo "Usage: $0 run|disable|enable"
	exit 1
fi
