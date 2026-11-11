#!/bin/sh
# Install the system-wide multipath route and pinned routes. Run as root
# (sudo or pkexec); the rules file is handed to the user who ran it.
set -e
here=$(cd "$(dirname "$0")" && pwd)
owner=${SUDO_UID:-${PKEXEC_UID:-0}}
install -m 755 "$here/90-multipath-default" /etc/NetworkManager/dispatcher.d/90-multipath-default
install -m 644 "$here/90-multipath.conf" /etc/sysctl.d/90-multipath.conf
install -D -m 755 "$here/netparasite-routes" /usr/local/lib/netparasite/netparasite-routes
ln -sf /usr/local/lib/netparasite/netparasite-routes /etc/NetworkManager/dispatcher.d/91-netparasite-routes
install -d -m 755 /etc/netparasite
[ -e /etc/netparasite/routes ] || printf '# DESTINATION  LINK    (see: netparasite pin --help)\n' > /etc/netparasite/routes
chown "$owner" /etc/netparasite/routes
chmod 644 /etc/netparasite/routes
install -m 644 "$here"/netparasite-routes.service "$here"/netparasite-routes.path \
  "$here"/netparasite-routes.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now netparasite-routes.path netparasite-routes.timer
sysctl -q -p /etc/sysctl.d/90-multipath.conf
/etc/NetworkManager/dispatcher.d/90-multipath-default x up
/usr/local/lib/netparasite/netparasite-routes
ip route show default
