#! /bin/bash
# proxycannon-ng redux - the referb

# GetOPTS
provider_id=""
p_set=false
server_count=""
c_set=false
tf_del=false

usage() {
    echo "[!!] First edit/uncomment ./proxycannon.tfvars for authentication then run"
    echo "[!!] Please run as root"
    echo " "
    echo "To provision infrastructure and use ProxyCannon:"
    echo "proxycannon.sh -p <PROVIDER ID> -c <EXIT NODE COUNT>"
    echo "  Provider IDs:"
    echo "    1 == Digital Ocean"
    echo "    2 == AWS"
    echo "    3 == Azure"
    echo " "
    echo "To destroy infrastructure:"
    echo "proxycannon.sh -p <PROVIER ID> -d"
    echo " "
}

while getopts ":p:c:dh" opt; do
    case ${opt} in
        p ) provider_id=$OPTARG;p_set=true;;
        c ) server_count=$OPTARG;c_set=true;;
        d ) tf_del=true;;
        h ) usage; exit;;
        \? ) echo "Invalid Option: -$OPTARG" >&2; exit 1;;
        : ) echo "Invalid Option: -$OPTARG requires an argument" >&2; exit 1;;
        esac
    done
    shift $((OPTIND -1))

# Check running as root
if [[ "$EUID" -ne 0 ]]
then
    echo "[!!!] Please run as root"
    exit
fi

# install terraform from hashicorp
# current support is for Terraform v0.13.5
if ! type "terraform" > /dev/null
then
    wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
    unzip terraform_0.13.5_linux_amd64.zip
    sudo cp terraform /usr/bin/
    rm -f terraform_0.13.5_linux_amd64.zip
    rm -rf terraform
fi

if ! $p_set
then
    echo "[!!] PROVIDER ID needs to be set."
    echo " "
    usage
    exit 1
fi

if $tf_del
then
    echo "Destroying Proxycannon Setup"
    case $provider_id in
      1) cd tfdocs/providers/digitalOcean ;;
      2) cd tfdocs/providers/aws ;;
      3) cd tfdocs/providers/azure ;;
    esac
    terraform destroy -var-file='proxycannon.tfvars' -auto-approve
    rm -rf proxycannon.tfvars
    rm -rf ./configs/
    cd ../../../
    rm -rf connection-pack/
    exit 0
fi

if ! $c_set
then
    echo "[!!] EXIT NODE COUNT needs to be set."
    echo " "
    usage
    exit 1
fi

case $provider_id in
    1 )
    provider="isDO"
    cp -r tfdocs/configs tfdocs/providers/digitalOcean
    cp proxycannon.tfvars tfdocs/providers/digitalOcean
    cd tfdocs/providers/digitalOcean
    ;;
    2 )
    provider="isAWS"
    cp -r tfdocs/configs tfdocs/providers/aws
    cp proxycannon.tfvars tfdocs/providers/aws
    cd tfdocs/providers/aws
    ;;
    3 ) provider="isAZURE";;
    * ) echo "Please select an actual provider ID."; usage; exit 1;;
esac

terraform init -input=false
terraform apply -var $provider='true' -var 'server_count='$server_count -var-file="proxycannon.tfvars" -auto-approve

mv conpack.tar.gz ../../../
cd ../../../
tar -xvf conpack.tar.gz &>/dev/null
rm conpack.tar.gz

############################
# post install instructions
############################
echo " "
echo "#########################################"
echo "Proxycannon infrastructure setup complete"
echo " "
echo "#########################################"
echo "Do the following:"
echo "cd connection-pack/ && sudo openvpn --config proxycannon-client.conf"
echo " "
echo "#########################################"
echo "If you want to test that your connection is working run:"
echo "while true;do curl ifocnfig.co;done"
echo " "
echo "#########################################"
echo "Don't forget to clean-up when you're finished:"
echo "sudo ${0} -p ${provider_id} -d"
