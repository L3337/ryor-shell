#!/bin/sh -xe

# Usage: $0 enable|disable [random_sleep_sec]

export CONFIG=${CONFIG:-/etc/ryor/config.yaml}
DISABLE_FILE=/etc/ryor/disable-wifi

if [ ! -z "$2" ]; then
	sleep=$[RANDOM%$2]
	echo "Sleeping for $sleep"
	sleep $sleep
fi

AP_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wireless']['ap_iface'])
EOF
)
ALL_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print('\n'.join(config['wireless']['all_iface']))
EOF
)

if [ "$1" == "start" ]; then
    if [ -e "$DISABLE_FILE" ]; then
        echo "Wireless AP disabled by configuration, not enabling"
        exit 0
    fi
    if [ -e /etc/ryor/wifi-mac ]; then
        ip link set dev "$AP_IFACE" down
        ip link set dev "$AP_IFACE" address $(cat /etc/ryor/wifi-mac)
        ip link set dev "$AP_IFACE" up
    else
        echo "WARNING: No mac address config for interface, not changing"
    fi
    systemctl start hostapd
    sleep 1
    for iface in $ALL_IFACE; do
        ip link set $iface master br0
        bridge link set dev $iface isolated on
        firewall-cmd --zone=00-trusted --change-interface=$iface
    done
elif [ "$1" == "stop" ]; then
    systemctl stop hostapd
elif [ "$1" == "enable" ]; then
    rm -f "$DISABLE_FILE"
elif [ "$1" == "disable" ]; then
    touch "$DISABLE_FILE"
elif [ "$1" == "status" ]; then
    systemctl status hostapd
else
    echo "Usage: $0 start|stop|enable|disable|status [random_sleep_sec]"
    exit 1
fi

echo "Finished"
