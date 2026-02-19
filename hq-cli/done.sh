#!/bin/bash

LOG="/var/log/setup.log"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Только root!"
  exit 1
fi

cp /mnt/nfs/ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust

if [ $? -eq 0 ]; then
  echo "✅ Сертификат установлен"
else
  echo "❌ Ошибка установки сертификата"
  exit 1
fi
