#!/bin/sh -xe

#if [ "$EUID" != "0" ]; then
#	echo "Must be root"
#	exit 1
#fi

export CONFIG=${CONFIG:-/etc/ryor/config.yaml}

if [ ! -e "$CONFIG" ]; then
	echo "$CONFIG does not exist, cannot load network"
	exit 1
fi

WAN_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config['wan_iface'])
EOF
)
LAN_IFACE=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print('\n'.join(config['lan_iface']))
EOF
)

CPU_FREQ=$(python3 - << EOF
import os
import yaml
with open(os.environ['CONFIG']) as f:
    config = yaml.safe_load(f)
print(config.get('cpu_freq', ''))
EOF
)


sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

if [ ! -z "$CPU_FREQ" ]; then
    cpupower frequency-set --freq "$CPU_FREQ"
fi

ip link add name br0 type bridge

ip link set dev enp1s0f0 master br0
ip link set dev enp1s0f1 master br0
ip link set dev enp1s0f2 master br0
ip link set dev enp1s0f3 master br0

bridge link set dev enp1s0f0 isolated on
bridge link set dev enp1s0f1 isolated on
bridge link set dev enp1s0f2 isolated on
bridge link set dev enp1s0f3 isolated on


ip addr add 192.168.10.1/24 dev br0
ip link set dev br0 up
firewall-cmd --zone=00-trusted --change-interface=br0

for iface in $LAN_IFACE; do
    #sysctl -w net.ipv6.conf.${iface}.disable_ipv6=1
    ip link set $iface up
    firewall-cmd --zone=00-trusted --change-interface=${iface}
done

firewall-cmd --zone=50-internet --change-interface=$WAN_IFACE
#sysctl -w net.ipv6.conf.$WAN_IFACE.disable_ipv6=0

chattr -i /etc/resolv.conf

dhclient $WAN_IFACE

# Override dhclient to use dnsmasq
cat << EOF > /etc/resolv.conf
# Written by RYOR, use dnsmasq to resolve DNS queries
nameserver 127.0.0.1
options edns0 trust-ad
search .
EOF

# Prevent over-writing by other processes
chattr +i /etc/resolv.conf

# Force DNS redirection to dnsmasq
firewall-cmd \
    --zone=00-trusted \
    --add-forward-port=port=53:proto=udp:toport=53:toaddr=192.168.10.1

# In case it is in a blocked state from something else
rfkill unblock wlan

