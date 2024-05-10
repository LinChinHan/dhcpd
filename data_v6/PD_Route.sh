#!/bin/bash

#Debug flag
set -x

# $1: operation [ commit, expiry, release ] 
# $2: IANA
# $3: IAPD
# $4: PD Prefix


case $1 in
	"commit")
		echo $2
		echo $3
		echo $4

		#ip route add ${3}/${4} via $2

	;;
	"expiry")
		echo $4
		#ip route del ${3}/${4} via $2
	;;
	"release")
		echo $4
		#ip route del ${3}/${4} via $2
	;;
	*)
	echo "- Warnning:"
	echo "  This Script is only used for dhcpd daemon!"
esac
