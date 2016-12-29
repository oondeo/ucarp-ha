#!/bin/bash
DEV=$1
VIP=$2
IPDEV=$3
shift 3

if [ ! -z "$1" ]; then
	IPS="$@"
fi

if [ -z "$VIP" ]; then
	echo "$0 interface vip [additional ips...]"
fi

if [ -f "/etc/network/interfaces" ]; then
	echo "> Running ifup $IPDEV"
	ifup $IPDEV -v
	for IP in $IPS
	do
		# if > 0, we have ipv6 notation
		IPV6="${IP//[^\:]}"
		if (( ${#IPV6} < 0 )); then
			REALIP=$(echo $IP | awk -F'/' '{print $1}')
			echo "> running arping for $REALIP"
			nohup arping -c 2 -A -S $REALIP -i $IPDEV $REALIP &
		fi
	done
	echo "> Done with interface, state:"
	ip addr show dev $IPDEV
	echo "> Route state:"
	route -n
	exit 0
fi

if [ ! -z "$BROADCAST" ]; then
	BROADCAST="broadcast $BROADCAST"
fi

for IP in $IPS
do
	# if > 0, we have netmask also
	NETMASK="${IP//[^\/]}"
	# if > 0, we have ipv6 notation
	IPV6="${IP//[^\:]}"

	echo "> Adding $IP on $IPDEV"

	if (( ${#IPV6} > 0 )); then
		# handle dadfailed, needs `--privileged`
		# more info https://github.com/docker/docker/issues/4717
		echo 0 > /proc/sys/net/ipv6/conf/$IPDEV/accept_dad
		# adding ipv6 addr here
		BITS=64
		if (( ${#NETMASK} > 0 )); then
			ip -6 addr add $IP dev $IPDEV
		else
			ip -6 addr add $IP/$BITS dev $IPDEV
		fi
	else
		# adding ipv6 addr here
		BITS=32
		if (( ${#NETMASK} > 0 )); then
			ip addr add $IP $BROADCAST dev $IPDEV
		else
			ip addr add $IP/$BITS $BROADCAST dev $IPDEV
		fi
		# only the first IP in list should have a broadcast ADDR
		BROADCAST=""
	fi
done

echo "> Bringing up interface link $IPDEV"
ip link set $IPDEV up