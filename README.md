# DHCPD Docker

## ReadME Document
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

For configuration file, you can edit it after executing interface.sh. The script will auto detect how to modify/delete configuration.


## Quick start:

0. Pre-requirement: to install docker and radvd by below command:
```
#Will install docker and set up ip forwarding
make install
```

1. ./interface.sh : to add interface and set up ip for v4 and v6:
```
	#example:
	./interface.sh add enp2s0 100 : Add interface enp2s0 with vlan 100
	./interface.sh add enp2s0 : Add interface enp2s0 with untag.
```
2. ./run.sh : to start the DHCPv4 Server Daemon
```
	(v6 should use ./run_v6.sh)
	ex:
	./run.sh start enp2s0 100 : Add DHCP Server for enp2s0 with vlan 100
	./run.sh start enp2s0  : Add DHCP Server for enp2s0 with untag
	
	./run.sh stop enp2s0  : Stop DHCP Server for enp2s0 with untag
	./run.sh stop enp2s0 100 : Stop DHCP Server for enp2s0 with vlan 100
```



## RADVD for IPv6:
run_v6.sh will auto copy ./radvd.conf to /etc/radvd.conf, note to set up subnet after executing "interface.sh add"


	

## Stop NM forever:
```
sudo systemctl stop NetworkManager-wait-online.service
sudo systemctl disable NetworkManager-wait-online.service

sudo systemctl stop NetworkManager-dispatcher.service
sudo systemctl disable NetworkManager-dispatcher.service

sudo systemctl stop network-manager.service
sudo systemctl disable network-manager.service
```


## iptables for NAT
```
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o ppp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o ppp0 -j MASQUERADE
```


## ip forwarding:
```
sysctl -p /etc/sysctl.conf
//should enable both ipv4 and ipv6
```


