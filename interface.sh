#!/bin/bash

#Debug flag
#set -x

#Defination
ISP_PrefixV6=2001:470:eeac

#Only support 48 currently
ISP_NetmaskV6=48

#Domain name
domain=eit

function dns_add(){
	#$1: vlan
	#$2: ipv4
	#$3: ipv6
	
	domain_name=${domain}$1.com


	echo "zone \"${domain_name}\" {" >> dns/named.conf
	echo "        type master;" >> dns/named.conf
	echo "        file \"/etc/bind/${1}_zone\";" >> dns/named.conf
	echo "};" >> dns/named.conf
	echo "" >> dns/named.conf

	echo "\$ORIGIN ${domain_name}." >> dns/${1}_zone
	echo "\$TTL 1W" >> dns/${vlan}_zone
	echo "@                       1D IN SOA       ${domain_name}. root.${domain_name}. (" >> dns/${1}_zone
	echo "                                        1               ; serial" >> dns/${1}_zone
	echo "                                        3H              ; refresh" >> dns/${1}_zone
	echo "                                        15M             ; retry" >> dns/${1}_zone
	echo "                                        1W              ; expiry" >> dns/${1}_zone
	echo "                                        1D )            ; minimum" >> dns/${1}_zone
	echo "" >> dns/${1}_zone
	echo "                        1D IN NS        ns" >> dns/${1}_zone
	echo "ns                      1D IN A         ${2}" >> dns/${1}_zone
	echo "ns                      1D IN AAAA      ${3}" >> dns/${1}_zone
	echo "" >> dns/${1}_zone
	echo "www                     1D IN A         ${2}" >> dns/${1}_zone
	echo "www                     1D IN AAAA      ${3}" >> dns/${1}_zone
	
	
}

function dns_del(){
	#$1: vlan
	domain_name=${domain}$1

	ret=`cat dns/named.conf | grep ${domain_name}`
	line=`cat dns/named.conf | grep -n ${domain_name} | awk -F ":" '{print $1}'`

        echo "ret = $ret"
        echo "line = $line"
        if [ -z $ret ]; then
                echo "[DNS DELETE] No need to delete, Cannot find interface "$ret" in dns.conf. . ."
        else
                echo "[DNS DELETE] deleted from line ${line} : `sed -n ${line}p dns/named.conf`!!!!"
                #delete interface xxxxx
                sed -i ${line}d dns/named.conf
                #delete first "{"
                echo "[DNS DELETE] line to delete line $line : `sed -n ${line}p dns/named.conf`"
                sed -i ${line}d dns/named.conf
                top=1
                while [ ${top} -ne 0 ]; do
                        if [ ! -z `sed -n ${line}p dns/named.conf | awk '{print $1}'` ] && [ `sed -n ${line}p dns/named.conf | awk '{print $1}'` = '{' ]; then
                                top=`expr $top + 1`
                        elif [ ! -z `sed -n ${line}p dns/named.conf | awk '{print $1}'` ] && [ `sed -n ${line}p dns/named.conf | awk '{print $1}'` = '};' ]; then
                                top=`expr $top - 1`
                        fi
                        echo "[DNS DELETE] line to delete line $line : `sed -n ${line}p dns/named.conf`"
                        sed -i ${line}d dns/named.conf
                done

                #delete space:
                sed -i ${line}d dns/named.conf
                #while read p; do
                #       echo $p
                #done < radvd.conf

                #endl=`expr $line + 18`
                #sed -i ${line},${endl}d radvd.conf
        fi


	rm -rf dns/${1}_zone
}

function radvd_add(){
	# $1 : interface
	# $2 : Vlan
	# $3 : prefixV6
	# $4 : maskv6

	echo "[RADVD ADD] Modfiying radvd.conf ...."
	if [ $2 = 'untag' ]; then
		ret=`awk  '{print $2}' radvd.conf | grep $1 | egrep -v '\.[0-9]'`
		target=$1
	else
		ret=`awk  '{print $2}' radvd.conf | grep $1 | grep $2`
		target=$1.$2
	fi
	if [ -z $ret ]; then
		# Need to add example
		echo "interface ${target}" >> radvd.conf
		echo "{" >> radvd.conf
		echo "   AdvSendAdvert on;" >> radvd.conf
		echo "   MaxRtrAdvInterval 60;" >> radvd.conf
		echo "   MinDelayBetweenRAs  60;" >> radvd.conf
		echo "   AdvManagedFlag  on;" >> radvd.conf
		echo "   AdvOtherConfigFlag on;" >> radvd.conf
		echo "   prefix ${3}::/${4}" >> radvd.conf
		echo "   {" >> radvd.conf
		echo "     AdvOnLink on;" >> radvd.conf
		echo "     AdvAutonomous on;" >> radvd.conf
		echo "     AdvRouterAddr on;" >> radvd.conf
		echo "   };" >> radvd.conf
		echo "   RDNSS ${3}::1 2001:4860:4860::8888" >> radvd.conf
		echo "    {" >> radvd.conf
		echo "      AdvRDNSSLifetime 30;" >> radvd.conf
		echo "    };" >> radvd.conf
		echo "};" >> radvd.conf
		echo "" >> radvd.conf

	else
		echo "[RADVD ADD] No need to add configuration to radvd.conf, interface "$ret" exist already, skipped."
	fi
}

function radvd_del(){
	echo "[RADVD DELETE] Deleting radvd.conf ...."
        if [ $2 = 'untag' ]; then
                ret=`awk  '{print $2}' radvd.conf | grep $1 | egrep -v '\.[0-9]'`
		line=`cat radvd.conf | grep -n $1 | egrep -v '\.[0-9]' | awk -F ':' '{print $1}'`
        else
                ret=`awk  '{print $2}' radvd.conf | grep $1 | grep $2`
		line=`cat radvd.conf | grep -n $1 | grep $2 | awk -F ':' '{print $1}'`
		
        fi
	#echo "ret = $ret"
	#echo "line = $line"
        if [ -z $ret ]; then
                echo "[RADVD DELETE] No need to delete, Cannot find interface "$ret" in radvd.conf. . ."
        else
		echo "[RADVD DELETE] deleted from line ${line} : `sed -n ${line}p radvd.conf`!!!!"
		#delete interface xxxxx
		sed -i ${line}d radvd.conf
		#delete first "{"
		echo "[RADVD DELETE] line to delete line $line : `sed -n ${line}p radvd.conf`"
		sed -i ${line}d radvd.conf
		top=1
		while [ ${top} -ne 0 ]; do
			if [ ! -z `sed -n ${line}p radvd.conf | awk '{print $1}'` ] && [ `sed -n ${line}p radvd.conf | awk '{print $1}'` = '{' ]; then
				top=`expr $top + 1`
			elif [ ! -z `sed -n ${line}p radvd.conf | awk '{print $1}'` ] && [ `sed -n ${line}p radvd.conf | awk '{print $1}'` = '};' ]; then
				top=`expr $top - 1`
			fi
			echo "[RADVD DELETE] line to delete line $line : `sed -n ${line}p radvd.conf`"
			sed -i ${line}d radvd.conf
		done

		#delete space:
		sed -i ${line}d radvd.conf
		#while read p; do
		#	echo $p
		#done < radvd.conf

		#endl=`expr $line + 18`
		#sed -i ${line},${endl}d radvd.conf
        fi
	
}

function dhcpd_add(){
	# $1 : interface (not use)
	# $2 : Vlan  (not use )
        # $3 : prefixv4 ex 192.168.1.
	# $4 : maskv4 ex:24 

	domain_name=${domain}$2.com

        echo "[DHCPDv4 ADD] Modfiying data/dhcpd.conf ...."
	ret=`grep -i ${3}0 data/dhcpd.conf | awk '{print $2}'`
        if [ -z $ret ]; then
		echo "subnet ${3}0 netmask 255.255.255.0 {" >> data/dhcpd.conf
		echo "  range ${3}101 ${3}254;" >> data/dhcpd.conf
		echo "  option routers ${3}1;" >> data/dhcpd.conf
		echo "  option domain-name \"${domain_name}\";" >> data/dhcpd.conf
		echo "  option domain-name-servers ${3}1, 8.8.8.8;" >> data/dhcpd.conf
		echo "}" >> data/dhcpd.conf
		echo "" >> data/dhcpd.conf
        else
                echo "[DHCPDv4 ADD] Interface $interface $vlan subnet ${3}0/${4} configuration exist, no need to add, skipped."	
        fi
	

}

function dhcpd_del(){
	# $1 : interface (not use)
        # $2 : Vlan  (not use )
        # $3 : prefixv4 ex 192.168.1.
        # $4 : maskv4 ex:24
        echo "[DHCPDv4 DELETE] Deleting data/dhcpd.conf ...."
	ret=`grep -i ${3}0 data/dhcpd.conf | awk '{print $2}'`
        if [ -z $ret ]; then
                echo "[DHCPDv4 DELETE] Interface $interface with vlan $vlan subnet ${3}0/${4} configuration is notexist, no need to delete, skipped."
        else
        	echo "[DHCPDv4 DELETE] Start to delete interface $interface with vlan $vlan subnet ${3}0/${4} ...."
		line=`cat data/dhcpd.conf | grep -n ${3}0 | awk -F ':' '{print $1}'`
		#delete first "{"
                echo "[DHCPDv4 DELETE] line to delete line $line : `sed -n ${line}p data/dhcpd.conf`"
                sed -i ${line}d data/dhcpd.conf
                top=1
                while [ ${top} -ne 0 ]; do
                        if [ ! -z  `sed -n ${line}p data/dhcpd.conf | awk '{print $NF}'` ] && [ `sed -n ${line}p data/dhcpd.conf | awk '{print $NF}'` = '{' ]; then
                                top=`expr $top + 1`
                        elif [ ! -z  `sed -n ${line}p data/dhcpd.conf | awk '{print $NF}'` ] && [ `sed -n ${line}p data/dhcpd.conf | awk '{print $NF}'` = '}' ]; then
                                top=`expr $top - 1`
                        fi
                        echo "[DHCPDv4 DELETE] line to delete line $line : `sed -n ${line}p data/dhcpd.conf`"
                        sed -i ${line}d data/dhcpd.conf
                done

                #delete space:
                sed -i ${line}d data/dhcpd.conf

        fi
}



function dhcpdV6_add(){
	# $1 : interface (not use)
	# $2 : Vlan  (not use )
        # $3 : prefixv6 ex : 2001:470:eeac:
	# $4 : maskv6 ex:65

	domain_name=${domain}$2.com
        
	echo "[DHCPDv6 ADD] Modfiying data_v6/dhcpd.conf ...."
	ret=`grep -i "${3}::/${4} {" data_v6/dhcpd.conf | awk '{print $2}'`
        if [ -z $ret ]; then
		if [ $2 = "untag" ]; then
			echo "subnet6 ${3}::/$4 {" >> data_v6/dhcpd.conf
			echo "  range6 ${3}::101 ${3}::100:254;" >> data_v6/dhcpd.conf
			echo "  range6 ${3}::/${4} temporary;" >> data_v6/dhcpd.conf
			echo "  option dhcp6.name-servers ${3}::1, 2001:4860:4860::8888;" >> data_v6/dhcpd.conf
			echo "  option dhcp6.domain-search \"${domain_name}\";" >> data_v6/dhcpd.conf
			echo "  prefix6 ${3}:6666:: ${3}:7777:: /64;" >> data_v6/dhcpd.conf
			echo "}" >>  data_v6/dhcpd.conf
			echo "" >> data_v6/dhcpd.conf
		else
			echo "subnet6 ${3}::/$4 {" >> data_v6/dhcpd.conf
			echo "  range6 ${3}::101 ${3}::100:254;" >> data_v6/dhcpd.conf
			echo "  range6 ${3}::/${4} temporary;" >> data_v6/dhcpd.conf
			echo "  option dhcp6.name-servers ${3}::1, 2001:4860:4860::8888;" >> data_v6/dhcpd.conf
			echo "  option dhcp6.domain-search \"${domain_name}\";" >> data_v6/dhcpd.conf
			echo "  prefix6 ${3}:8000:: ${3}:f000:: /68;" >> data_v6/dhcpd.conf
			echo "}" >>  data_v6/dhcpd.conf
			echo "" >> data_v6/dhcpd.conf
		fi

        else
                echo "[DHCPDv6 ADD] Interface $interface $vlan subnet ${3}::/${4} configuration exist, no need to add, skipped."	
        fi
	
}

function dhcpdV6_del(){
        # $1 : interface (not use)
        # $2 : Vlan  (not use )
        # $3 : prefixv6 ex : 2001:470:eeac:9999
        # $4 : maskv6 ex:24
        echo "[DHCPDv6 DELETE] Deleting data_v6/dhcpd.conf ...."
	ret=`grep -i "${3}::/${4} {" data_v6/dhcpd.conf | awk '{print $2}'`
        if [ -z $ret ]; then
                echo "[DHCPDv6 DELETE] Interface $interface with vlan $vlan subnet ${3}::/${4} configuration is notexist, no need to delete, skipped."
        else
        	echo "[DHCPDv6 DELETE] Start to delete interface $interface with vlan $vlan subnet ${3}::/${4} ...."
		line=`cat data_v6/dhcpd.conf | grep -n "${3}::/${4} {" | awk -F ':' '{print $1}'`
		#delete first "{"
                echo "[DHCPDv6 DELETE] line to delete line $line : `sed -n ${line}p data_v6/dhcpd.conf`"
                sed -i ${line}d data_v6/dhcpd.conf
                top=1
                while [ ${top} -ne 0 ]; do
                        if [ ! -z `sed -n ${line}p data_v6/dhcpd.conf | awk '{print $NF}'` ] && [ `sed -n ${line}p data_v6/dhcpd.conf | awk '{print $NF}'` = '{' ]; then
                                top=`expr $top + 1`
                        elif [ ! -z `sed -n ${line}p data_v6/dhcpd.conf| awk '{print $NF}'` ] && [ `sed -n ${line}p data_v6/dhcpd.conf | awk '{print $NF}'` = '}' ]; then
                                top=`expr $top - 1`
                        fi
                        echo "[DHCPDv6 DELETE] line to delete line $line : `sed -n ${line}p data_v6/dhcpd.conf`"
                        sed -i ${line}d data_v6/dhcpd.conf
                done

                #delete space:
                sed -i ${line}d data_v6/dhcpd.conf

        fi
}

# Main
#No interface
if [ ! $2 ] || [ ! $1 ] ; then
	op='help'
elif [ ! -z $2 ]; then
	ifconfig $2 > /dev/null
	if [ $? -ne 0 ]; then
		echo "Incorrect interface. . . "
		exit 1
	else
		op=$1
	fi
else
	op=$1
fi

if [ ! $3 ]; then
	vlan=untag
	address=172.16.1.1
	prefixV4=172.16.1.
	netmask=24
	
	# HE gave : 2001:470:eeac::48
	#untag interface ip allocation
	#2001:470:eeac:0::/64 for IANA of untag interface
	#2001:470:eeac:6666::/64 to 2001:470:eeac:7777:: for PD of untag interface

	#vlan id should be 2 to 4095, will not affect the prefix of untag interface

	#tag interface ip allocation
	#2001:470:eeac:[vlan ID]::/65 for IANA
	#2001:470:eeac:[vlan ID]:8000::/65 for IANA
	#::1 will always to be used in server side.
	addressV6=${ISP_PrefixV6}:0::1
	prefixV6=${ISP_PrefixV6}
	netmaskV6=64
else
	vlan=$3

	#for vlan interface, prefix 65
	#2001:470:eeac:[vlanID]:0000~7fff::/65 for IANA. ( 1 bit to allocate to IANA) 
	#2001:470:eeac:[vlanID]:8000~f000::/68 for PD use ( 3 bits allocate to  8 DUTs (PD))
	
	netmask=24
	netmaskV6=65
	
        re='^[0-9]+$'
        if ! [[ ${vlan} =~ $re ]] ; then
                echo "Error: Not a number" >&2; exit 1
        fi

        if [ "${vlan}" -lt 2 ] || [ "${vlan}" -gt 4094 ]; then
                echo "Error: The Vlan must be 2 ~ 4094" >&2; exit 1
        fi

	#v4 ip is 10.[vlan(3:2)].[vlan(1:0)].x
	#ex: vlan 3001 = 10.30.01.x

	if [ $3 -lt 100 ]; then
		address=10.0.${vlan}.1
		prefixV4=10.0.${vlan}.
	else
		address=10.`expr ${vlan} / 100`.`expr ${vlan} % 100`.1
		prefixV4=10.`expr ${vlan} / 100`.`expr ${vlan} % 100`.
	fi

	#::1 will always to be used in server side.
	prefixV6=${ISP_PrefixV6}:${vlan}
	addressV6=${ISP_PrefixV6}:${vlan}::1
fi




case ${op} in
        "add")
		#interface part ( ip / bring up)
		interface=$2
		echo "======================================================="
		echo "[ADD] Start to set up ${interface}.${vlan}"
		echo "[ADD] AddressV4 ${address}/${netmask}"
		echo "[ADD] AdresssV6 ${addressV6}/${netmaskV6}"
		echo "======================================================="
		if [ ! $3 ]; then
			#ifconfig ${interface} ${address}/${netmask} up
			ip addr add ${addressV6}/${netmaskV6} dev ${interface}
		else
			echo "[ADD] Adding VLAN interface ${interface}.${vlan}"
			vconfig add ${interface} ${vlan}
			#if [ $? != 0 ]; then
			#	echo "[ADD] Add Vlan for interface failed. "
			#	echo "    Interface may exist already."
			#	exit 1
			#fi
			echo "[ADD] Bring up ineterface and set up ipv4 address. . ."
			ifconfig ${interface}.${vlan} ${address}/${netmask} up
			echo "[ADD] Adding ipv6 address. . ."
			ip addr add ${addressV6}/${netmaskV6} dev ${interface}.${vlan}
		fi
		
		#iptables part
		echo "[IPTABLES ADD] Adding NAT forwarding in iptables. . ."
		if [ -z `iptables -nvxL -t nat | grep ${prefixV4} | awk  '{print $8}'` ]; then
			iptables -t nat -A POSTROUTING -s ${address}/${netmask} -o ppp0 -j MASQUERADE
			if [ $? -eq 0 ]; then
				echo "[IPTABLES ADD] Adding iptables successfully. . ."
			else
				echo "[IPTABLES ADD] Adding iptables failed. . . Please check the reason"
			fi

		else
			echo "[IPTABLES ADD] iptables rule is exist already. skip..."
		fi

		#Configuration produce
		radvd_add ${interface} ${vlan} ${prefixV6} ${netmaskV6}
		dhcpd_add ${interface} ${vlan} ${prefixV4} ${netmask}
		dhcpdV6_add ${interface} ${vlan} ${prefixV6} ${netmaskV6}
		dns_add ${vlan} ${address} ${addressV6}
        ;;
        "del")
		interface=$2
		echo "[DELETE] Start to delete ${interface}.${vlan}"

		#Configuration produce
		radvd_del ${interface} ${vlan} ${prefixV6} ${netmaskV6}
		dhcpd_del ${interface} ${vlan} ${prefixV4} ${netmask}
		dhcpdV6_del ${interface} ${vlan} ${prefixV6} ${netmaskV6}
		dns_del ${vlan}

		#iptables part
		echo "[IPTABLES DELETE] Remove NAT forwarding in iptables. . ."
		if [ ! -z `iptables -nvxL -t nat | grep ${prefixV4}0 | awk  '{print $8}'` ]; then
			iptables -t nat -D POSTROUTING -s ${address}/${netmask} -o ppp0 -j MASQUERADE
			if [ $? -eq 0 ]; then
				echo "[IPTABLES DELETE] Remove iptables successfully. . ."
			else
				echo "[IPTABLES DELETE] Remove iptables failed. . . Please check the reason"
			fi
		else
			echo "[IPTABLES DELETE] There is no nat forwarding rule in iptables, skipped. . ."
		fi

		#interface part ( shutdown interface and remove interface )
		if [ ! $3 ]; then
                        echo "[DELETE] Default untag interface is unable to delete! skipped deleting interface part."
                else
			echo "[DELETE] Remove ipv6 address. . ."
			ip addr del ${addressV6}/${netmaskV6} dev ${interface}.${vlan} 2> /dev/null
			#if [ $? != 0 ]; then
			#	echo "[DELETE] Remove ip failed, please check if interface \"${interface}.${vlan}\" is exist."
			#	exit 1
			#fi
			echo "[DELETE] Shutdown interface. . ."
                        ifconfig ${interface}.${vlan} down
			echo "[DELETE] Remove vlan interface. . ."
                        vconfig rem ${interface}.${vlan}
                fi
        ;;
        *)
	#help message
        echo "-Usage:"
        echo "  $0 [options] [interface] [Vlan]"
        echo "    If untag, keep empty."
        echo "  - options:"
        echo "      add"
        echo "          Add Interface."
        echo "      del"
        echo "          Delete Interface."
        echo "   - interface:"
        echo "          Network interface name"
        echo "   - vlan: [2~4094]"
	echo ""


esac
