#!/bin/bash
set -e

mkdir -p /var/run/wireguard

# Clean up a stale interface left over from a previous container run.
ip link delete wg0 2>/dev/null || true

echo "[INFO] Инициализация VPN интерфейса wg0..."

# Prefer the kernel AmneziaWG/WireGuard module when the host provides it.
# amneziawg-go refuses to start (and userspace is slower) when a kernel
# module is loaded, so fall back to it only if no kernel device is available.
if ip link add dev wg0 type amneziawg 2>/dev/null; then
    echo "[INFO] 🚀 Успех: Создан ЯДЕРНЫЙ AmneziaWG интерфейс!"
elif ip link add dev wg0 type wireguard 2>/dev/null; then
    echo "[INFO] ⚡ Успех: Создан стандартный ЯДЕРНЫЙ WireGuard!"
else
    echo "[WARN] Ядерные интерфейсы недоступны. Запускаю amneziawg-go (userspace)..."
    amneziawg-go wg0
    sleep 2
fi

echo "[INFO] Инициализация конфигов и файрвола (jwg)..."
jwg

echo "[INFO] AmneziaWG готов к работе!"
tail -f /dev/null
