%global modname ryor
%global completions_dir %( pkg-config --variable=completionsdir bash-completions )

Name:           %{modname}
Version:        0.0.1
Release:        1%{?dist}
Summary:        TODO
License:        MIT
URL:            https://pypi.io/project/%{modname}
Source0:        https://pypi.io/packages/source/d/%{modname}/%{modname}-%{version}.tar.gz

#wireguard-tools
Requires:       cronie, ddclient, dnsmasq, hostapd, nmap, dhcp-client, python3-pyyaml
BuildArch:      noarch

%description
Highly advanced DIY home networking for the discerning computing enthusiast

%prep
%autosetup -n %{modname}-%{version}

%build

%install
%make_install

%post
set -x
rm -f /etc/hostapd/hostapd.conf
cp -f /etc/ryor/hostapd.conf /etc/hostapd/
rm -f /etc/ssh/sshd_config
cp -f /etc/ryor/sshd_config /etc/ssh/sshd_config
if [ ! -e /etc/ryor/wan-mac ]; then
    change-wan-mac.sh
fi
if [ ! -e /etc/ryor/wifi-mac ]; then
    change-wifi-mac.sh
fi
if [ ! -e /etc/ddclient.conf.bkp ]; then
    mv /etc/ddclient.conf /etc/ddclent.conf.bkp
fi
cp -f /etc/ryor/ddclient.conf /etc/ddclient.conf

systemctl disable --now systemd-resolved
systemctl disable --now NetworkManager
systemctl enable --now ryor
systemctl enable --now ryor-wifi
systemctl enable --now dnsmasq
systemctl enable --now crond
systemctl enable --now firewalld
systemctl enable --now ddclient

systemctl daemon-reload

firewall-cmd --new-zone=00-trusted --permanent
firewall-cmd --zone=00-trusted --set-target=ACCEPT --permanent
firewall-cmd --zone=00-trusted --add-forward --permanent
firewall-cmd --zone=00-trusted --add-source=192.168.0.0/16 --permanent
firewall-cmd --zone=00-trusted --add-source=10.0.0.0/8 --permanent

firewall-cmd --new-zone=50-internet --permanent
firewall-cmd --zone=50-internet --add-forward --permanent
firewall-cmd --zone=50-internet --add-masquerade --permanent

firewall-cmd --new-policy=router-egress --permanent
firewall-cmd --policy=router-egress --permanent --add-ingress-zone=00-trusted
firewall-cmd --policy=router-egress --permanent --add-egress-zone=50-internet
firewall-cmd --policy=router-egress --permanent --set-target=ACCEPT
firewall-cmd --permanent --policy=router-egress \
	--add-rich-rule='rule tcp-mss-clamp value=pmtu'

firewall-cmd --new-policy=router-ingress --permanent
firewall-cmd --policy=router-ingress --permanent --add-ingress-zone=50-internet
firewall-cmd --policy=router-ingress --permanent --add-egress-zone=00-trusted
firewall-cmd --policy=router-ingress --permanent --set-target=ACCEPT
firewall-cmd --permanent --policy=router-ingress \
	--add-rich-rule='rule tcp-mss-clamp value=pmtu'
firewall-cmd --reload

dconf update
if [ ! -e /etc/dconf/db/gdm ]; then
    cat << EOF
WARNING: /etc/dconf/db/gdm not created, leaving computer at the login screen
may cause the computer to suspend, and the network to stop working.
EOF
fi

%preun
set -x

systemctl disable --now ddclient
systemctl disable --now dnsmasq
systemctl disable --now hostapd
systemctl disable --now ryor-wifi
systemctl disable --now ryor

firewall-cmd --delete-policy=router-egress --permanent || true
firewall-cmd --delete-policy=router-ingress --permanent || true
firewall-cmd --delete-zone=00-trusted --permanent || true
firewall-cmd --delete-zone=50-internet --permanent || true

hostnamectl hostname rollyourownrouter

%postun
dconf update

systemctl daemon-reload

%check

%files
%license LICENSE
%attr(755, root, root) /usr/local/bin/*
/etc/NetworkManager/conf.d/ryor.conf
/etc/cron.d/ryor
/etc/dconf/db/gdm.d/01-local-power
/etc/dconf/profile/gdm
/etc/dnsmasq.d/01-ryor.conf
/etc/profile.d/custom-shell-prompt.sh
/etc/ryor
/etc/sysctl.d/99-ryor.conf
/etc/systemd/system/dnsmasq.service
/etc/systemd/system/ryor-wifi.service
/etc/systemd/system/ryor.service

%changelog
