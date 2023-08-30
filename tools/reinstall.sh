#!/bin/sh -xe

# Reinstall from the latest sources
# You should reboot after this

script_dir=$(dirname $0)
cd "$(realpath $script_dir)/.."

make clean
make rpm
sudo dnf remove --noautoremove ryor
sudo dnf install -y ./ryor-*.el9.noarch.rpm

