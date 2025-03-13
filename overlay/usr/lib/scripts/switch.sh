#!/bin/bash
iptables -t nat -F
iptables -F
systemctl stop pihole-FTL.service
mv /etc/netplan/99-router-config.yaml /etc/netplan/99_config.saved
mv /etc/netplan/99-switch-config.saved /etc/netplan/99-switch-config.yaml
netplan apply