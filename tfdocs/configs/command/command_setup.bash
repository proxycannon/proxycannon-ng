#! /bin/bash
# proxycannon
#

###################
# install software
###################
# update and install deps
apt update
export DEBIAN_FRONTEND=noninteractive
apt -y upgrade

vpsID=$1

if ! type "openvpn" > /dev/null
then
    apt update
    apt -y upgrade
    apt -y install openvpn
fi

if ! type "make-cadir" > /dev/null
then
    apt update
    apt -y upgrade
    apt -y install easy-rsa
fi

################
# setup openvpn
################
# cp configs
cp /tmp/client-server.conf /etc/openvpn/client-server.conf
cp /tmp/proxycannon-client.conf ~/proxycannon-client.conf

# setup ca and certs
mkdir /etc/openvpn/ccd
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/
sed -i 's/\#set_var\sEASYRSA_BATCH\t\t\"\"/\set_var\ EASYRSA_BATCH\t\t\"yes\"/g' vars
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full server nopass
./easyrsa gen-dh
openvpn --genkey --secret /etc/openvpn/easy-rsa/pki/private/ta.key

# generate certs
for x in $(seq -f "%02g" 1 10);do ./easyrsa build-client-full client$x nopass;done

# start service
systemctl start openvpn@client-server.service

# modify client config with remote IP of this server
# this will need to become dynamic depending on what VPS platform is being used
# or sperate install scripts will need to be used
case $vpsID in
  1 )
  # cURL for Digital Ocean's metadata
  EIP=`curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address`
  ;;
  2 )
  # cURL for AWS' metadata
  EIP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
  ;;
esac

sed -i "s/REMOTE_PUB_IP/$EIP/" ~/proxycannon-client.conf

# prepare the connection pack for download
mkdir /tmp/connection-pack
cp /etc/openvpn/easy-rsa/pki/ca.crt /tmp/connection-pack/ca.crt
cp /etc/openvpn/easy-rsa/pki/private/ta.key /tmp/connection-pack/ta.key
cp /etc/openvpn/easy-rsa/pki/issued/client01.crt /tmp/connection-pack/client01.crt
cp /etc/openvpn/easy-rsa/pki/private/client01.key /tmp/connection-pack/client01.key
mv /root/proxycannon-client.conf /tmp/connection-pack/proxycannon-client.conf
cd /tmp/
tar -cf conpack.tar.gz connection-pack/

###################
# setup networking
###################
# setup routing and forwarding
sysctl -w net.ipv4.ip_forward=1

# use L4 (src ip, src dport, dest ip, dport) hashing for load balancing instead of L3 (src ip ,dst ip)
#echo 1 > /proc/sys/net/ipv4/fib_multipath_hash_policy
sysctl -w net.ipv4.fib_multipath_hash_policy=1

# setup a second routing table
echo "50        loadb" >> /etc/iproute2/rt_tables

# set rule for openvpn client source network to use the second routing table
ip rule add from 10.10.10.0/24 table loadb

# in AWS snat from eth0 but in DO do eth1 otherwise the traffic goes nowhere
case $vpsID in
  1 ) # for digitalocean
  iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
  ;;
  2 ) # for aws
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  ;;
esac
