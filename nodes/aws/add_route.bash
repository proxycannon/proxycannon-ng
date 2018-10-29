#! /bin/bash
IP=$1
# random sleep to avoid race condition
sleep $[ ( $RANDOM % 10 )  + 1 ]s

for pid in $(pidof -x "add_route.bash"); do
	if [ $pid != $$ ]; then
		echo "[!] ROUTE ADD: another addition process is running. Waiting our turn..."
		sleep 2
	else
		break
	fi
done

# grab last ran route cmd
ROUTECMD=$(cat .routecmd)

# is there a last used route cmd
if [ -z "$ROUTECMD" ];then
	echo "[!] ROUTE ADD: fiirst time adding a route"
	ROUTECMD="ip route add default proto static scope global table loadb nexthop via $IP weight 100"
	eval $ROUTECMD
	echo "[+] ROUTE ADD CMD: $ROUTECMD"

	# save route as a replace command
	ROUTECMD=`echo $ROUTECMD | sed 's/ip route add/ip route replace/'`

else
	echo "[+] ROUTE ADD: adding $IP to route table"
	ROUTECMD="$ROUTECMD nexthop via $IP weight 100 "
	eval $ROUTECMD
	echo "[+] ROUTE ADD CMD: $ROUTECMD"
fi

# save last ran route to file
echo $ROUTECMD > .routecmd
