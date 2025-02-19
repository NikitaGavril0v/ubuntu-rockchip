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
rfkill unblock all
touch /etc/dhcpcd.conf
echo denyinterfaces ${ports[1]} > /etc/dhcpcd.conf
touch /etc/netplan/99_config.yaml
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    ${ports[1]}:
      addresses:
        - 192.168.11.1/24
      routes:
        - to: default
          via: 192.168.11.1
      nameservers:
          search: [google, googleAlt]
          addresses: [8.8.8.8, 8.8.4.4]" > /etc/netplan/99_config.yaml
#Установка PiHole
curl -sSL https://install.pi-hole.net | bash
pihole setpassword
pihole -a enabledhcp "192.168.11.50" "192.168.11.200" "192.168.11.1" "24" "local"
touch /etc/dnsmasq.d/99-pts-lan.conf
echo "dhcp-range=${ports[1]},192.168.11.50,192.168.11.254
dhcp-option=${ports[1]},3,192.168.11.1
dhcp-option=${ports[1]},6,192.168.11.1" > /etc/dnsmasq.d/99-pts-lan.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
#Настроим правила для LAN.
iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#Настроим правила для WLAN.
#iptables -A FORWARD -i wlan0 -o ${ports[0]} -j ACCEPT
#iptables -A FORWARD -i ${ports[0]} -o wlan0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#Прогоним трафик между ethernet интерфейсами
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -j ACCEPT
iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
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