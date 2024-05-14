help:
	@cat README.md


#Now platform is Ubuntu 
install: prepare docker_dhcp
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
	"deb [arch=$(shell dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(shell . /etc/os-release && echo "$$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
	sudo apt-get update
	
	apt-get install -y docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin \
		radvd
	
	docker run hello-world

docker_dhcp:
	docker build -t mydhcp:v1 ./dhcpd/

prepare:
	#This prepare is to enable forwarding for ipv4 and ipv6
	@$(shell sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf)
	@$(shell sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf)
	sysctl -p /etc/sysctl.conf
	sysctl -p

dns_up:
	systemctl stop systemd-resolved
	docker compose up -d

dns_down:
	docker compose down
	#Do not restart it to avoid dns disappear,
	#solution is :
	#mv /etc/resolve.conf /etc/resolve.conf.bk
	#sed -i 's'DNS=''DNS= 8.8.8.8 168.95.1.1'/g
	#ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

	#systemctl restart systemd-resolved
	
