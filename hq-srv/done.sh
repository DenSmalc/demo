#!/bin/bash

LOG="/var/log/setup.log"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Запустите скрипт от root!" | tee -a $LOG
  exit 1
fi

echo "=== НАСТРОЙКА HQ-SRV ===" | tee -a $LOG

check_error () {
  if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения!" | tee -a $LOG
    exit 1
  fi
}

# 0. Установка openssl-gost
echo "Установка openssl-gost..." | tee -a $LOG
if ! rpm -q openssl-gost &>/dev/null; then
    dnf install -y openssl-gost
    check_error
fi

# 1. Создание центра сертификации
echo "Создание CA..." | tee -a $LOG

mkdir -p /etc/pki/CA/{private,certs,newcerts,crl}
touch /etc/pki/CA/index.txt
echo 1000 > /etc/pki/CA/serial
chmod 700 /etc/pki/CA/private
check_error

# Проверка наличия ГОСТ-провайдера
if ! openssl list -public-key-algorithms | grep -q gost; then
  echo "❌ Провайдер ГОСТ не найден!" | tee -a $LOG
  exit 1
fi

# Генерация ключа ГОСТ
openssl genpkey -algorithm gost2012_256 -pkeyopt paramset:TCB \
  -out /etc/pki/CA/private/ca.key
check_error

# Создание самоподписанного сертификата
openssl req -x509 -new -md_gost12_256 \
  -key /etc/pki/CA/private/ca.key \
  -out /etc/pki/CA/certs/ca.crt \
  -days 3650 \
  -subj "/CN=AU-TEAM Root CA"
check_error

echo "✅ CA создан" | tee -a $LOG

# 2. CUPS
echo "Настройка CUPS..." | tee -a $LOG
sed -i 's/Listen localhost/Listen hq-srv.au-team.irpo:631/' /etc/cups/cupsd.conf
systemctl restart cups
check_error

# 3. Rsyslog сервер
echo "Настройка rsyslog..." | tee -a $LOG
systemctl enable --now rsyslog
check_error

# 4. Prometheus + Grafana
echo "Запуск мониторинга..." | tee -a $LOG
systemctl enable --now prometheus
systemctl enable --now grafana-server
systemctl enable --now prometheus-node_exporter
check_error

# 5. Fail2ban
echo "Настройка fail2ban..." | tee -a $LOG
systemctl enable --now fail2ban
check_error

echo "✅ HQ-SRV полностью настроен" | tee -a $LOG
