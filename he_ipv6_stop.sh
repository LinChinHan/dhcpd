#!/bin/sh

# uncomment for debug
set -x


# The primary internet-facing network interface
#WAN_IF maybe same as MY_IF if your IP is obtained from DHCP Server

WAN_IF=eno1
MY_IF=ppp0
Client_IF=enp2s0

# Given under "IPv6 Tunnel Endpoints" on the tunnel details page
#CLIENT_V6=2001:470:35:95f::2/64

# An address from your Routed /64 or /48 prefix for the local interface
#LOCAL_V6=2001:470:eeac::/48


#LOCAL_V4=`ifconfig ${MY_IF} | grep -E 'inet [\.0-9]*' | awk '{ print $2 }'`

echo "### Start to delete HE service. . ."
# Drop any existing tunnel
ip route del ::/0 dev he-ipv6
ip tunnel del he-ipv6
#ip addr del $LOCAL_V6 dev $MY_IF

#Delete client route if this PC is working as server
#ip route del $LOCAL_V6 dev $Client_IF

# Add back original routing if need.
# Mark it if your PC does not have ipv6 ip.
#ip route add ::/0 dev ${WAN_IF}

#service radvd stop
#service radvd status

# Uncomment or run the following separately to check your address configuration
# ip -f inet6 addr
