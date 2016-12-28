#!/bin/sh
DEV=$1
VIP=$2
IPDEV=$3
shift

if [ -z "$VIP" ]
then
	echo "$0 interface vip [additional ips...]"
fi

for i in $VIP $IPS
do
	echo "- add $i on $IPDEV"
	ip addr add $i dev $IPDEV
done
ip link set $IPDEV up