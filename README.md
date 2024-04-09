# ReadME Document
Auther: Elliot Lin

## Defination
he_ipv6_start.sh : shell script for set up the HE tunnel and route for ipv6 (will also enable radvd)

he_ipv6_stop.sh : shell script for clear setting of HE tunnel and route for ipv6 ( will also disable radvd)

run.sh : shell script for dhcpv4 server

run_ipv6.sh : shell script for dhcpv6 server

interface.sh : Set up interface for subscriber network.


## Quick start:

Pre-requirement: to install docker and radvd by below command:
```
make install
```


1. ./interface.sh : to add interface :
	ex:
	./interface.sh add enp2s0 100 : Add interface enp2s0 with vlan 100
	./interface.sh add enp2s0 : Add interface enp2s0 with untag.

2. Add dhcp configuration to ./data/dhcpd.conf (follow interface IP range to add)
	(v6 config is in ./data_v6/dhcpd.conf)

3. ./run.sh : to start the DHCPv4 Server Daemon
	(v6 should use ./run_v6.sh)
	ex:
	./run.sh start enp2s0 100 : Add DHCP Server for enp2s0 with vlan 100
	./run.sh start enp2s0  : Add DHCP Server for enp2s0 with untag

4. Modify the /etc/sysctl.conf to support IPv4 / IPv6 forwarding
```
sysctl -p /etc/sysctl.conf
sysctl -p
```


## v6 RADVD:
Please copy ./radvd.conf to /etc/radvd.conf, note to set up subnet after executing "interface.sh add"

	

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


