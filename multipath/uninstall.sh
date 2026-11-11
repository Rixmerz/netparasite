#!/bin/sh
# Remove the multipath route and pinned routes. Run as root. Keeps the rules
# in /etc/netparasite/routes.
systemctl disable --now netparasite-routes.path netparasite-routes.timer 2>/dev/null
rm -f /etc/systemd/system/netparasite-routes.service /etc/systemd/system/netparasite-routes.path \
  /etc/systemd/system/netparasite-routes.timer \
  /etc/NetworkManager/dispatcher.d/90-multipath-default \
  /etc/NetworkManager/dispatcher.d/91-netparasite-routes \
  /etc/sysctl.d/90-multipath.conf
rm -rf /usr/local/lib/netparasite
systemctl daemon-reload
sysctl -q -w net.ipv4.fib_multipath_hash_policy=0
ip -4 route del default metric 50 2>/dev/null
ip -4 route flush proto 222 2>/dev/null
ip route show default
