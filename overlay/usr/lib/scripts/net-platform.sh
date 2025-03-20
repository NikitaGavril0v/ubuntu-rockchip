#!/bin/bash

# Установка wiringOp-Python для переключения режимов свитч/роутер
apt install -y python3 python3-pip swig python3-dev python3-setuptools
git clone --recursive https://github.com/orangepi-xunlong/wiringOP-Python -b next
cd wiringOP-Python
git submodule update --init --remote
python3 generate-bindings.py > bindings.i
sudo python3 setup.py install
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
touch /etc/netplan/99-router-config.yaml
echo "network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ${ports[1]}:
      addresses:
        - 192.168.11.1/24" > /etc/netplan/99-router-config.yaml
touch /etc/netplan/99-switch-config.saved
echo "network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enP4p65s0:
      dhcp4: yes
    enP3p49s0:
      dhcp4: yes" > /etc/netplan/99-switch-config.saved
#Установка PiHole
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
bash basic-install.sh
pihole setpassword
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/etc_dnsmasq_d = false/etc_dnsmasq_d = true/' /etc/pihole/pihole.toml
#Настроим правила для LAN.
iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#Настроим MASQUERADE.
iptables -t nat -A POSTROUTING -o ${ports[0]} -j MASQUERADE
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
#apt install -y iptables-persistent
#/etc/init.d/netfilter-persistent save
netplan apply
# Создадим скрипты для переключения режимов свитч/роутер
touch /usr/lib/scripts/router.sh
touch /usr/lib/scripts/switch.sh
chmod +x /usr/lib/scripts/router.sh
chmod +x /usr/lib/scripts/switch.sh
echo "#!/bin/bash

iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o ${ports[0]} -j MASQUERADE
systemctl start pihole-FTL.service
mv /etc/netplan/99-router-config.saved /etc/netplan/99-router-config.yaml
mv /etc/netplan/99-switch-config.yaml /etc/netplan/99-switch-config.saved
netplan apply" > /usr/lib/scripts/router.sh
echo "#!/bin/bash
iptables -t nat -F
iptables -F
systemctl stop pihole-FTL.service
mv /etc/netplan/99-router-config.yaml /etc/netplan/99-router-config.saved
mv /etc/netplan/99-switch-config.saved /etc/netplan/99-switch-config.yaml
netplan apply" > /usr/lib/scripts/switch.sh
# Создадим юнит systemd
touch /etc/systemd/system/net-mode-switcher.service
echo "[Unit]
Description=Network Mode Switcher Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/lib/scripts
ExecStart=/usr/bin/python3 /usr/lib/scripts/net-mode-switcher.py
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/net-mode-switcher.service
systemctl daemon-reload
sudo systemctl enable net-mode-switcher.service
