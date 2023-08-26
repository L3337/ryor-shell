#!/bin/sh -xe

# Upgrade packages without upgrading the kernel
sudo dnf upgrade --exclude=kernel* --exclude=kmod*
