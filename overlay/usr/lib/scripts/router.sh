#!/bin/bash

iptables -A FORWARD -i ${ports[1]} -o ${ports[0]} -j ACCEPT
iptables -A FORWARD -i ${ports[0]} -o ${ports[1]} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o ${ports[0]} -j MASQUERADE
systemctl start pihole-FTL.service
mv /etc/netplan/99-router-config.saved /etc/netplan/99_config.yaml
mv /etc/netplan/99-switch-config.yaml /etc/netplan/99-switch-config.saved
netplan apply