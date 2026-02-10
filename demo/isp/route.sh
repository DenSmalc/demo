#!/bin/bash
hostnamectl set-hostname isp; exec bash
echo ‘172.16.1.14/28’ > /etc/net/ifaces/ens20/ipv4address
echo ‘172.16.2.14/28’ > /etc/net/ifaces/ens21/ipv4address
systemctl restart network
apt-get update
apt-get install nano nftables -y
nano /etc/nftables/nftables.nf