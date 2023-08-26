#!/bin/sh -xe

export CONFIG=${CONFIG:-/etc/ryor/config.yaml}
#PATH="$(realpath $(dirname $0)):$PATH"

if [ ! -e "$CONFIG" ]; then
	echo "$CONFIG does not exist, cannot load network"
	exit 1
fi

AP_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wireless']['ap_iface'])
EOF
)

START_TIME=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wireless']['start_time'])
EOF
)

END_TIME=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wireless']['end_time'])
EOF
)

firewall-cmd --zone=trusted --change-interface=$AP_IFACE

if [ "$(date +%H%M)" \> "$START_TIME" ] && [ "$(date +%H%M)" \< "$END_TIME" ]; then
	wifi.sh start
else
	wifi.sh stop
fi

