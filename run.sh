#!/bin/bash

#Debug flag
#set -x

#docker run -it --rm --init --net host -v "$(pwd)/data":/data mydhcp:v1 enp2s0

if [ ! $1 ]; then
	op="help"
else
	op=$1
fi


if [ ! $2 ]; then
	op="help"
else
	ret=`ifconfig $2`
	if [ $? = 0 ]; then
		interface=$2
	else
		echo "Cannot find interface $2 !!!!"
		exit 1
	fi
fi


if [ ! $3 ]; then
	interface=$2
	vlan=untag
	name=DHCPv4_Server_${interface}_${vlan}
else
	vlan=$3
	re='^[0-9]+$'
	if ! [[ ${vlan} =~ $re ]] ; then
   		echo "Error: Not a number" >&2; exit 1
	fi

	if [ "${vlan}" -lt 2 ] || [ "${vlan}" -gt 4094 ]; then
		echo "Error: The Vlan must be 2 ~ 4094" >&2; exit 1
	fi
	interface=${interface}.${vlan}
	name=DHCPv4_Server_${interface}
fi

running=`docker ps -a | grep "${interface}" | grep "${vlan}" | grep "v4"`
echo ${running}
echo ${interface}

case ${op} in
	"start")
		if [ "${running}" = "" ]; then
			docker run -it -d --net host --name ${name} -v "$(pwd)/data":/data mydhcp:v1 ${interface}
		else
			echo "It's running!"	
		fi
		
	;;
	"stop")
		if [ "${running}" != "" ]; then
			docker stop ${name}
			docker rm ${name}
		else
			echo "${name} is not running."
		fi
	;;
	"restart")
		if [ "${running}" != "" ]; then
			docker stop ${name}
			docker rm ${name}
		fi
		docker run -it -d --net host --name ${name} -v "$(pwd)/data":/data mydhcp:v1 ${interface}
	;;
	"logs")
		docker logs ${name}
	;;
	*)
	echo "-Usage:"
	echo "  $0 [options] [Interface] [Vlan]"
	echo "    If untag, keep empty."
	echo "  - options:"
	echo "      start"
	echo "          Start the DHCP daemon."
	echo "      stop"
	echo "          Stop the DHCP daemon."
	echo "      Restart"
	echo "          Restart the DHCP daemon."
	echo "      logs"
	echo "          Dump logs."
	echo "   - vlan: [2~4094]"
esac
