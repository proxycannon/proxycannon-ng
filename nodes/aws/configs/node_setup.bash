#! /bin/bash
sudo sysctl -w net.ipv4.ip_forward=1
DEFAULTETH=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`
sudo iptables -t nat -A POSTROUTING -o $DEFAULTETH -j MASQUERADE
