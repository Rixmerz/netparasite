#!/bin/sh
# Remove the system-wide ECMP default route. Run as root.
rm -f /etc/NetworkManager/dispatcher.d/90-multipath-default /etc/sysctl.d/90-multipath.conf
sysctl -q -w net.ipv4.fib_multipath_hash_policy=0
ip -4 route del default metric 50 2>/dev/null
ip route show default
