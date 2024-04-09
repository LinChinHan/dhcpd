#!/bin/sh

# uncomment for debug
# set -x

# Hurricane Electric IPv6 Tunnel Broker script for Slackware
# You can run it from 
# /etc/rc.d/rc.local

# Modify by Johannes P. Lobel (http://www.lobel.cl) <jolobel@lobel.cl>
# Written by Jesse B. Hannah (http://jbhannah.net) <jesse@jbhannah.net>
# Based on instructions provided by Hurricane Electric (http://tunnelbroker.net)

###
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###

# This script does all of the necessary configuration to enable direct IPv6
# connectivity via a Hurricane Electric IPv6 tunnel from http://tunnelbroker.net
# on an Ubuntu or other Linux system when radvd is unavailable on the network,
# or for setting up radvd on the system.

# To use this script, put it in /etc/network/if-up.d and make it executable,
# then run it by itself or restart the networking services.

# Load the kernel IPv6 module. This isn't necessary on Linode.
modprobe ipv6

# The primary internet-facing network interface
WAN_IF=eno1
MY_IF=ppp0
Client_If=enps20
# Given under "IPv6 Tunnel Endpoints" on the tunnel details page
SERVER_V4=216.218.221.42
CLIENT_V6=2001:470:35:95f::2/64

# An address from your Routed /64 or /48 prefix for the local interface
LOCAL_V6=2001:470:eeac::/52

# If you have a static IP address (such as on Linode), you can comment these out.
# Otherwise, set them to your tunnelbroker.net username and password, and your tunnel ID.
HE_USER=ElliotLin
HE_PASS=VEdBtiYgYJFrTuvh
HE_TUNNEL=907239

LOCAL_V4=`ifconfig ${MY_IF} | grep -E 'inet [\.0-9]*' | awk '{ print $2 }'`

#You need to install LWP perl package

HE_USER_ENC=`perl -MURI::Escape -e "print uri_escape('$HE_USER')"`
HE_PASS_ENC=`perl -MURI::Escape -e "print uri_escape('$HE_PASS')"`

#curl -k -s "https://$HE_USER_ENC:$HE_PASS_ENC@ipv4.tunnelbroker.net/nic/update?hostname=$HE_TUNNEL&myip=$LOCAL_V4"

# Drop any existing tunnel
ip route del ::/0 dev he-ipv6
ip tunnel del he-ipv6
#ip addr del $LOCAL_V6 dev $MY_IF

#Delete client route if this PC is working as server
ip route del $LOCAL_V6 dev ${Client_IF}

# Add back original routing if need.
# Mark it if your PC does not have ipv6 ip.
ip route add ::/0 dev ${WAN_IF}

#service radvd stop
#service radvd status

# Uncomment or run the following separately to check your address configuration
# ip -f inet6 addr
