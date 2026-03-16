#!/bin/bash
set -e

mkdir -p /var/run/wireguard

echo "[INFO] Запуск интерфейса amneziawg-go wg0..."
amneziawg-go wg0

sleep 2

echo "[INFO] Инициализация конфигов и файрвола (jwg)..."
jwg

echo "[INFO] AmneziaWG готов к работе!"

tail -f /dev/null
