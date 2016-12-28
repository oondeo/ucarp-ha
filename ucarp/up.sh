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

for IP in $VIP $IPS
do
	# if > 0, we have netmask also
	NETMASK="${IP//[^\/]}"
	# if > 0, we have ipv6 notation
	IPV6="${IP//[^\:]}"

	echo "> Adding $IP on $IPDEV"

	if (( ${#IPV6} > 0 )); then
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
			ip addr add $IP dev $IPDEV
		else
			ip addr add $IP/$BITS dev $IPDEV
		fi
	fi
done

echo "> Bringing up interface link $IPDEV"
ip link set $IPDEV up