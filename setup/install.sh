#! /bin/sh
# install deps
apt install unzip git-core openvpn easy-rsa

# install terraform
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
cp terraform /usr/bin/

# get proxycannon-ng
git clone https://github.com/proxycannon/proxycannon-ng

# create directory for our aws credentials
mkdir ~/.aws
touch ~/.aws/credentials

echo "copy your aws ssh private key to ~/.ssh/proxycannon.pem and chmod 600"

echo "place your aws api id and key in ~/.aws/credentials"
