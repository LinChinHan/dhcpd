#!/bin/bash

#Debug flag
set -x

# $1: operation [ commit, expiry, release ] 
# $2: IANA
# $3: IAPD
# $4: PD Prefix


if [ ! -e /usr/sbin/ip ]; then
	apt-get update && apt-get install -y iproute2
fi
case $1 in
	"commit")
		ip route del ${3}/${4}
		ip route add ${3}/${4} via $2

	;;
	"expiry")
		ip route del ${3}/${4} via $2
	;;
	"release")
		ip route del ${3}/${4} via $2
	;;
	*)
	echo "- Warnning:"
	echo "  This Script is only used for dhcpd daemon!"
esac
