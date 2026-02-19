#!/bin/bash

LOG="/var/log/setup.log"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Только root!"
  exit 1
fi

check_error () {
  if [ $? -ne 0 ]; then
    echo "❌ Ошибка!"
    exit 1
  fi
}

echo "Настройка IPsec..."

cat >> /etc/strongswan/ipsec.conf <<EOF

conn gre
 type=tunnel
 authby=secret
 left=%defaultroute
 right=10.5.5.2
 leftprotoport=gre
 rightprotoport=gre
 auto=start
 pfs=no
EOF

echo "10.5.5.1 10.5.5.2 : PSK \"P@ssw0rd\"" >> /etc/strongswan/ipsec.secrets

systemctl enable --now strongswan-starter
check_error

echo "Настройка nftables..."

systemctl enable --now nftables
check_error

echo "✅ Роутер настроен"
