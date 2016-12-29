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
	ifdown $IPDEV --force
	exit 0
fi

for IP in $IPS
do
	# if > 0, we have netmask also
	NETMASK="${IP//[^\/]}"
	# if > 0, we have ipv6 notation
	IPV6="${IP//[^\:]}"

	echo "> Removing $IP on $IPDEV"

	if (( ${#IPV6} > 0 )); then
		# adding ipv6 addr here
		BITS=64
		if (( ${#NETMASK} > 0 )); then
			ip -6 addr del $IP dev $IPDEV
		else
			ip -6 addr del $IP/$BITS dev $IPDEV
		fi
	else
		# adding ipv6 addr here
		BITS=32
		if (( ${#NETMASK} > 0 )); then
			ip addr del $IP dev $IPDEV
		else
			ip addr del $IP/$BITS dev $IPDEV
		fi
	fi
done

echo "> Bringing down interface link $IPDEV"
ip link set $IPDEV down