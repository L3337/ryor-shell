#!/bin/sh

WAN_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wan_iface'])
EOF
)

ip addr show dev enp6s0
