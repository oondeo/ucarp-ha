#!/bin/bash
set -e

[ -z "$VHID" ] && VHID=`printf '%d' 0x$(echo $VIP | md5sum |cut -b1-2)`

NET=`ip addr show dev $DEV|awk '/inet[^6]/ {print $2}'`
RIP=`echo $NET|cut -d/ -f1`

echo "Startung UCARP ID $VHID IP $RIP OPTS $OPTS"

exec ucarp -i "$DEV" -s "$RIP" -v "$VHID" -p "$PASS" -a "$VIP" -x "$IPS" -x "$IPDEV" -u /ucarp/up.sh -d /ucarp/down.sh $OPTS -z --deadratio=5
