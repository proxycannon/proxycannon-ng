#! /bin/sh
# enable ip forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# use L4 (src ip, src dport, dest ip, dport) hashing for load balancing instead of L3 (src ip ,dst ip)
echo 1 > /proc/sys/net/ipv4/fib_multipath_hash_policy

# setup a second routing table
echo "50	loadb" >> /etc/iproute2/rt_tables

# set rule for openvpn client source network to use the second routing table
ip rule add from 10.10.10.0/24 table loadb

# always snat from eth0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# setup load balanced default gws for second routing table
# TODO these gw ips need to be dynamic. they are the far end of the 
#ip route add default proto static scope global table loadb nexthop via 172.31.41.121 weight 100 nexthop via 172.31.46.51 weight 100
