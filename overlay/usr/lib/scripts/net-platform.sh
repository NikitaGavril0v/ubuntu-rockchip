#!/bin/bash

#Получаем имена сетевых интерфейсов и записываем в ports
names=$(lshw -class network -businfo | grep -o "[0-9]:[0-9][0-9]")
ps=$(echo $names | grep -o "[0-9]:")
ps=$(echo $ps | grep -o "[0-9]")
ps=($ps)
names=$(echo $names | grep -o ":[0-9][0-9]")
names=$(echo $names | grep -o "[0-9][0-9]")
names=($names)
for i in $(seq 1 ${#ps[@]})
do
    :
    ports=("${ports[@]}" "enP${ps[$(($i-1))]}p$((16#${names[$(($i-1))]}))s0")
done

#Конфигурация портов
#rfkill unblock all
touch /etc/dhcpcd.conf
echo denyinterfaces ${ports[1]} > /etc/dhcpcd.conf
touch /etc/netplan/99_config.yaml
echo "network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ${ports[1]}:
      addresses:
        - 192.168.11.1/24" > /etc/netplan/99_config.yaml
#Установка PiHole
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
bash basic-install.sh
pihole setpassword
sed -i 's/etc_dnsmasq_d = false/etc_dnsmasq_d = true/' /etc/pihole/pihole.toml
touch /etc/dnsmasq.d/99-pts-lan.conf
echo "# DHCP server setting
dhcp-authoritative
dhcp-leasefile=/etc/pihole/dhcp.leases
dhcp-range=192.168.11.50,192.168.11.254,255.255.255.0
dhcp-option=option:router,192.168.11.1

# Add NTP server to DHCP
dhcp-option=option:ntp-server,0.0.0.0" > /etc/dnsmasq.d/99-pts-lan.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
#Настроим правила для LAN.
iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#Настроим MASQUERADE.
iptables -t nat -A POSTROUTING -o ${ports[0]} -j MASQUERADE
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables-save > /etc/iptables.rules
touch /etc/network/if-pre-up.d/iptables
echo "#!/bin/sh

set -e

iptables-restore < /etc/iptables.rules
exit 0" > /etc/network/if-pre-up.d/iptables
chmod a+x /etc/network/if-pre-up.d/iptables
netplan apply
