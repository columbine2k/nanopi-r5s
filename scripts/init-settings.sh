#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/kucat'
uci commit luci

# Disable IPV6 ula prefix
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Check file system during boot
# uci set fstab.@global[0].check_fs=1
# uci commit fstab


# Configure NanoPi R5S as a side router
uci set network.lan.ipaddr='192.168.0.100'
uci set network.lan.proto='static'
uci set network.lan.type='bridge'
uci set network.lan.ifname='eth1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.0.1'
uci set network.lan.dns='192.168.0.1'
uci commit network

exit 0
