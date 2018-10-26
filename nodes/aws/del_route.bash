#! /bin/bash
IP=$1
# grab last ran route cmd
ROUTECMD=$(cat .routecmd)
echo $ROUTECMD

# is there a last used route cmd
if [ -z "$ROUTECMD" ];then
	echo "[!] cannot find last route cmd used. Will not delete $IP from routing table"
	exit 0
else
	if [[ $(ip route show table loadb | grep -o $IP) ]];then
		# delete existing route
		echo "[-] deleting existing route"
		ROUTECMDDEL=`echo $ROUTECMD | sed 's/ip route add/ip route del/'`
		echo $ROUTECMDDEL
		eval $ROUTECMDDEL
		
		# add route statement without specific IP
		echo "[+]  deleting $IP from routing table"
		ROUTECMD=`echo $ROUTECMD | sed "s/nexthop via $IP weight 100//"`
		echo $ROUTECMD
		eval $ROUTECMD

		# save last ran route to file (but always save as a 'add' statement)
		ROUTECMD=`echo $ROUTECMD | sed 's/ip route del/ip route add/'`
		echo $ROUTECMD > .routecmd

	else
		echo "[!] IP is not in the route table"
		exit 0
	fi
fi

