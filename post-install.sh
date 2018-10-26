#!/bin/bash

sudo cd /etc/openvpn/easy-rsa/
sudo source ./vars
sudo /etc/openvpn/easy-rsa/pkitool --initca 
sudo /etc/openvpn/easy-rsa/pkitool --server server
sudo /usr/bin/openssl dhparam -out /etc/openvpn/easy-rsa/keys/dh2048.pem 2048
sudo openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key
sudo /etc/openvpn/easy-rsa/pkitool client01
sudo /etc/openvpn/easy-rsa/pkitool node01
sudo systemctl start openvpn@node-server.service
sudo systemctl start openvpn@client-server.service
sudo sysctl -w net.ipv4.ip_forward=1
