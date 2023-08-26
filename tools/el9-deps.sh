#!/bin/sh -xe

#sudo dnf upgrade -y --refresh
sudo dnf install -y \
	epel-next-release \
	epel-release \
	htop \
	git \
	jq \
	make \
	rpm-build \
	vim \
	tmux

