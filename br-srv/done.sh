#!/bin/bash

LOG="/var/log/setup.log"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Только root!" | tee -a $LOG
  exit 1
fi

check_error () {
  if [ $? -ne 0 ]; then
    echo "❌ Ошибка!" | tee -a $LOG
    exit 1
  fi
}

echo "=== Импорт пользователей ===" | tee -a $LOG

CSV_FILE="/mnt/Users.csv"

while IFS=';' read -r fname lname role phone ou street zip city country password; do

if [[ "$fname" == "First Name" ]]; then
continue
fi

username=$(echo "${fname:0:1}${lname}" | tr '[:upper:]' '[:lower:]')

samba-tool ou create "OU=${ou},DC=AU-TEAM,DC=IRPO"
samba-tool user add "$username" "$password" \
--given-name="$fname" \
--surname="$lname" \
--userou="OU=$ou"

check_error

echo "Добавлен $username" | tee -a $LOG

done < "$CSV_FILE"

echo "Запуск node_exporter..." | tee -a $LOG
systemctl enable --now prometheus-node_exporter
check_error

echo "Настройка rsyslog клиента..."
echo "*.warn @@192.168.0.1:514" >> /etc/rsyslog.conf
systemctl restart rsyslog
check_error

echo "✅ BR-SRV настроен" | tee -a $LOG
