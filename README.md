# DHCPD Server in Docker

## README Document
Auther: Elliot Lin <elliot_lin@arcadyan.com.tw>

## Defination
- he_ipv6_start.sh : shell script for set up the HE tunnel and route for ipv6 (will also enable radvd)

- he_ipv6_stop.sh : shell script for clear setting of HE tunnel and route for ipv6 ( will also disable radvd)

- run.sh : shell script for dhcpv4 server

- run_ipv6.sh : shell script for dhcpv6 server

- interface.sh :
	1. Set up interface for subscriber network.
	2. Set up radvd.conf
	3. set up data/dhcpd.conf
	4. set up data_v6/dhcpd.conf

- data/dhcpd.conf : dhcpdv4 configuration file. Auto produce by interface.sh

- data_v6/dhcpd.conf : dhcpdv6 configuration file. Auto produce by interface.sh

- radvd.conf : radvd daemon configuration file. Auto produce by interface.sh

> For configuration file, you can edit it after executing interface.sh. The script will auto detect how to modify/delete configuration.


## Quick start:

* Pre-requirement: to install docker and radvd by below command:
```bash
#Will install docker and set up ip forwarding
make install
```

* If you need ipv6 service, please run he_ipv6_start.sh to set up the tunnel and route.
    * Modify HE information to he_ipv6_start.sh, you could get those HE information from your HE page side
    ```
    WAN_IF=eno1
    MY_IF=ppp0
    ...
    SERVER_V4=216.218.221.42 #(not important, will auto obtain from "MY_IF")
    CLIENT_V6=2001:470:35:8a7::2/64
    ...
    HE_USER="jerryricelin"
    HE_PASS="Wn6ZsgdQcWExSlC9"
    HE_TUNNEL="907275"

    ```

    * Execute the command to bring up tunnel
    ```
    ./he_ipv6_start.sh
    ```

    * You can remove tunnel and route by below command:
    ```
    ./he_ipv6_stop.sh
    ```


* ./interface.sh : To add interface and set up ip for v4 and v6:
```
	#Please set up your ISP Prefix in "ISP_PrefixV6", ISP or "HE" could provide you the prefix of IPv6 for clients.
	#For Example:
	ISP_PrefixV6=2001:470:eeac

	#example: Add interface enp2s0 with vlan 100
	./interface.sh add enp2s0 100
	#example: Add interface enp2s0 without vlan tag
	./interface.sh add enp2s0

	#example: Delete interface enp2s0 with vlan 100
	./interface.sh del enp2s0 100
	#example: del interface enp2s0 without vlan tag ( Will only remove Server configurations and iptables. will not remove interface for untag.)
	./interface.sh del enp2s0
	
```

* ./run.sh : to start the DHCPv4 Server Daemon
```
	(v6 should use ./run_v6.sh)
	#ex: Start DHCP Server for enp2s0 with vlan 100
	./run.sh start enp2s0 100
	#ex: Start DHCP Server for enp2s0 without vlan tag
	./run.sh start enp2s0 
	
	#Stop DHCP Server for enp2s0 with untag
	./run.sh stop enp2s0
	#Stop DHCP Server for enp2s0 with vlan 100
	./run.sh stop enp2s0 100
```


## RADVD for IPv6:
run_v6.sh will auto copy ./radvd.conf to /etc/radvd.conf, note to set up subnet after executing "interface.sh add"
> Please note that you have already install radvd by "make install"
> If you don't need radvd (ipv6 service), please disable it everytime:
```
service radvd stop
```
	

## Stop NM forever:
```
#This is the command to stop network manager if you don't really rennd it
sudo systemctl stop NetworkManager-wait-online.service
sudo systemctl disable NetworkManager-wait-online.service

sudo systemctl stop NetworkManager-dispatcher.service
sudo systemctl disable NetworkManager-dispatcher.service

sudo systemctl stop network-manager.service
sudo systemctl disable network-manager.service
```


## iptables for NAT
```
#This is the command to set up iptables, the interface.sh will auto add/delete it.
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o ppp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o ppp0 -j MASQUERADE
```


## ip forwarding:
```
#This is the command to enable forwading feature of Server. "make install" will auto enable it if it's disable.
sysctl -p /etc/sysctl.conf
//should enable both ipv4 and ipv6
```

#DNS
```
# Enable dns server
make dns_up

# Disable dns server
make dns_down
```
