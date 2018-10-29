#! /bin/bash
IP=$1
# random sleep to avoid race condition
sleep $[ ( $RANDOM % 5 )  + 1 ]s

for pid in $(pidof -x "del_route.bash"); do
        if [ $pid != $$ ]; then
                echo "[!] ROUTE DELETE: another addition process is running. Waiting our turn..."
                sleep 2
        else
                break
        fi
done

# grab last ran route cmd
ROUTECMD=$(cat .routecmd)

# is there a last used route cmd
if [ -z "$ROUTECMD" ];then
	echo "[!] ROUTE DELETE: cannot find last route cmd used. Will not delete $IP from routing table"
	exit 0
else
	if [[ $(ip route show table loadb | grep -o $IP) ]];then
		# delete existing route
		#echo "[-] deleting existing route"
		#ROUTECMDDEL=`echo $ROUTECMD | sed 's/ip route add/ip route del/'`
		#echo $ROUTECMDDEL
		#eval $ROUTECMDDEL
		
		# add route statement without specific IP (delete route)
		ROUTECMD=`echo $ROUTECMD | sed "s/nexthop via $IP weight 100//"`
		
		# check if we are delete the very last route. if so, change route cmd to a delete cmd
		if [[ $(echo $ROUTECMD | grep -o nexthop) ]]; then
			echo "[-] ROUTE DELETE: deleting $IP from routing table"
			echo "[-] ROUTE DELETE CMD: $ROUTECMD"
			eval $ROUTECMD

			# save last ran route to file
			echo $ROUTECMD > .routecmd

		else
			echo "[!] ROUTE DELETE: removing last route"
			ROUTECMD=`echo $ROUTECMD | sed 's/ip route replace/ip route del/'`
			eval $ROUTECMD
			echo "[-] ROUTE DELETE CMD: $ROUTECMD"
			# last route deleted, no need to save last route statement
			rm -f .routecmd
		fi

	else
		echo "[!] ROUTE DELETE: IP $IP is not in the route table"
		exit 0
	fi
fi

