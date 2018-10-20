#!/bin/bash

sudo -s
cd /etc/openvpn/easy-rsa/
source ./vars
/etc/openvpn/easy-rsa/pkitool --initca 
/etc/openvpn/easy-rsa/pkitool --server server
/usr/bin/openssl dhparam -out /etc/openvpn/easy-rsa/keys/dh2048.pem 2048
openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key
systemctl start openvpn@node-server.service
systemctl start openvpn@client-server.service
sysctl -w net.ipv4.ip_forward=1
