#! /bin/sh
# proxycannon-ng
#

###################
# install software
###################
# update and install deps
apt update
apt -y upgrade
apt -y install unzip git openvpn easy-rsa

# install terraform
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
cp terraform /usr/bin/
rm -f terraform_0.11.10_linux_amd64.zip
rm -rf terraform

# create directory for our aws credentials
mkdir ~/.aws
touch ~/.aws/credentials

################
# setup openvpn
################
# cp configs
cp configs/node-server.conf /etc/openvpn/node-server.conf
cp configs/client-server.conf /etc/openvpn/client-server.conf
cp configs/proxycannon-client.conf ~/proxycannon-client.conf

# setup ca and certs
mkdir /etc/openvpn/ccd
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/
ln -s openssl-1.0.0.cnf openssl.cnf
mkdir keys
. /etc/openvpn/easy-rsa/vars
./clean-all
/etc/openvpn/easy-rsa/pkitool --initca
/etc/openvpn/easy-rsa/pkitool --server server
/usr/bin/openssl dhparam -out /etc/openvpn/easy-rsa/keys/dh2048.pem 2048
openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key

# generate certs
for x in $(seq -f "%02g" 1 10);do /etc/openvpn/easy-rsa/pkitool client$x;done
/etc/openvpn/easy-rsa/pkitool node01

# start services
systemctl start openvpn@node-server.service
systemctl start openvpn@client-server.service

# modify client config with remote IP of this server
EIP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
sed -i "s/REMOTE_PUB_IP/$EIP/" ~/proxycannon-client.conf

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

# always snat from eth0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

############################
# post install instructions
############################

echo "Copy /etc/openvpn/easy-rsa/keys/ta.key, /etc/openvpn/easy-rsa/keys/ca.crt, /etc/openvpn/easy-rsa/keys/client01.crt, /etc/openvpn/easy-rsa/keys/client01.key, and ~/proxycannon-client.conf to your workstation."

echo "####################### OpenVPN client config [proxycannon-client.conf] ################################"
cat ~/proxycannon-client.conf

echo "####################### Be sure to add your AWS API keys and SSH keys to the following locations ###################"
echo "copy your aws ssh private key to ~/.ssh/proxycannon.pem and chmod 600"
echo "place your aws api id and key in ~/.aws/credentials"

echo "[!] remember to run 'terraform init' in the nodes/aws on first use"
