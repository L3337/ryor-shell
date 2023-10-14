#!/bin/sh

if [ "${USER}" == "root" ]; then
    PS1="[${USER}@${HOSTNAME}] \w \n\$ "
else
    PS1="[${USER}@${HOSTNAME}] \w \n\# "
fi
