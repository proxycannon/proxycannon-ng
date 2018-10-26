#! /bin/bash
IP=$1
# grab last ran route cmd
ROUTECMD=$(cat .routecmd)

# is there a last used route cmd
if [ -z "$ROUTECMD" ];then
	echo "[!] first time adding a route"
	ROUTECMD="ip route add default proto static scope global table loadb nexthop via $IP weight 100"
	eval $ROUTECMD
else
	# delete existing route 
	echo "[-] deleting existing routes"
	ROUTECMDDEL=`echo $ROUTECMD | sed 's/ip route add/ip route del/'`
	eval $ROUTECMDDEL
	echo "[+] adding $IP to route table"
	ROUTECMD="$ROUTECMD nexthop via $IP weight 100 "
	eval $ROUTECMD
fi

# save last ran route to file
echo $ROUTECMD > .routecmd
