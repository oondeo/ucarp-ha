#!/bin/sh
DEV=$1
VIP=$2
IPDEV=$3
shift;

if [ -z "$VIP" ]
then
  echo "$0 interface vip [additional ips...]"
fi

for i in $@
do
  ip addr del $i/32 dev $IPDEV
done
ip link set $IPDEV down