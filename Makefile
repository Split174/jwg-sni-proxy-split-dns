# --- Настройки ---
# IP или домен сервера
SERVER ?= root@IP
# Порт SSH
PORT ?= 22
# Папка на удаленном сервере
TARGET_DIR ?= /root/kvn-stack/
# Имя сервиса VPN в docker-compose.yml
VPN_SERVICE ?= amnezia-wg

# Исключаем локальные данные VPN и git, чтобы не затереть ключи сервера
EXCLUDE = --exclude='.git' --exclude='data-jwg'

.PHONY: help deploy sync down up restart logs status add del show check-peer

help:
	@echo "📦 Управление стеком:"
	@echo "  make deploy  - Копирование файлов и полный перезапуск (down -> up -d --build)"
	@echo "  make sync    - Только скопировать файлы"
	@echo "  make restart - Только перезапустить контейнеры (down -> up -d)"
	@echo "  make logs    - Посмотреть логи на сервере"
	@echo ""
	@echo "🔑 Управление VPN пирами (AmneziaWG):"
	@echo "  make status          - Показать статус сервера и список пиров"
	@echo "  make add PEER=name   - Добавить нового пира (выведет конфиг и QR)"
	@echo "  make show PEER=name  - Показать конфиг и QR код существующего пира"
	@echo "  make del PEER=name   - Удалить пира"

# ==========================================
# УПРАВЛЕНИЕ СТЕКОМ
# ==========================================
deploy: sync
	@echo "🚀 Перезапуск стека на $(SERVER)..."
	ssh -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose down && docker compose up -d --build"
	@echo "✅ Стек успешно обновлен и запущен!"

sync:
	@echo "🛠 Проверка зависимостей (rsync) на сервере..."
	ssh -p $(PORT) $(SERVER) "command -v rsync >/dev/null 2>&1 || (apt-get update && apt-get install -y rsync)"
	@echo "📦 Копирование файлов в $(TARGET_DIR)..."
	ssh -p $(PORT) $(SERVER) "mkdir -p $(TARGET_DIR)"
	rsync -avz --delete $(EXCLUDE) -e "ssh -p $(PORT)" ./ $(SERVER):$(TARGET_DIR)

down:
	@echo "🛑 Остановка стека..."
	ssh -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose down"

up:
	@echo "▶️ Запуск стека..."
	ssh -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose up -d --build"

restart: down up

logs:
	ssh -t -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose logs -f"


# ==========================================
# УПРАВЛЕНИЕ AMNEZIA WG (JWG)
# ==========================================

status:
	@echo "📊 Статус VPN сервера..."
	ssh -t -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose exec $(VPN_SERVICE) jwg"

add: check-peer
	@echo "➕ Добавление пира $(PEER)..."
	ssh -t -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose exec $(VPN_SERVICE) jwg add $(PEER)"

del: check-peer
	@echo "🗑 Удаление пира $(PEER)..."
	ssh -t -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose exec $(VPN_SERVICE) jwg del $(PEER)"

show: check-peer
	@echo "👁 Конфиг и QR-код для $(PEER)..."
	ssh -t -p $(PORT) $(SERVER) "cd $(TARGET_DIR) && docker compose exec $(VPN_SERVICE) jwg show $(PEER)"

check-peer:
	@if [ -z "$(PEER)" ]; then \
		echo "❌ Ошибка: Не указано имя пира (параметр PEER)."; \
		echo "👉 Пример: make $(MAKECMDGOALS) PEER=iphone"; \
		exit 1; \
	fi
