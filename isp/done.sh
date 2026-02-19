#!/bin/bash

LOG="/var/log/setup.log"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Только root!"
  exit 1
fi

mkdir -p /etc/nginx/ssl/private

control openssl-gost all

systemctl restart nginx

if [ $? -eq 0 ]; then
  echo "✅ nginx запущен с SSL"
else
  echo "❌ Ошибка nginx"
  exit 1
fi
