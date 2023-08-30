#!/bin/sh -xe

#if [ "$EUID" != "0" ]; then
#	echo "Must be root"
#	exit 1
#fi

export CONFIG=${CONFIG:-/etc/ryor/config.yaml}

if [ ! -e "$CONFIG" ]; then
	echo "$CONFIG does not exist, cannot unload network"
	exit 1
fi

LAN_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print('\n'.join(config['lan_iface']))
EOF
)
WIRELESS_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print('\n'.join(config['wireless']['all_iface']))
EOF
)

for iface in $LAN_IFACE; do
    ip link set dev $iface nomaster
done

for iface in $WIRELESS_IFACE; do
    ip link set dev $iface nomaster || true
done

ip link del br0

