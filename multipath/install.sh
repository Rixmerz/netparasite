#!/bin/sh
# Install the system-wide ECMP default route. Run as root.
set -e
here=$(cd "$(dirname "$0")" && pwd)
install -m 755 "$here/90-multipath-default" /etc/NetworkManager/dispatcher.d/90-multipath-default
install -m 644 "$here/90-multipath.conf" /etc/sysctl.d/90-multipath.conf
sysctl -q -p /etc/sysctl.d/90-multipath.conf
/etc/NetworkManager/dispatcher.d/90-multipath-default x up
ip route show default
