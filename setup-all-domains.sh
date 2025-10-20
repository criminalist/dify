#!/bin/bash

# Скрипт для настройки всех поддоменов ai.telemetrio.pro
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🚀 Настройка поддоменов ai.telemetrio.pro..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверяем что мы root
if [ "$EUID" -ne 0 ]; then
    log_error "Запустите скрипт с правами root: sudo $0"
    exit 1
fi

# Массив доменов
DOMAINS=(
    "ai.telemetrio.pro"
    "console.ai.telemetrio.pro"
    "app.ai.telemetrio.pro"
    "api.app.ai.telemetrio.pro"
    "files.ai.telemetrio.pro"
)

# Создаем директорию для конфигов если не существует
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

log_info "Копируем конфиги nginx..."

# Копируем все конфиги
for domain in "${DOMAINS[@]}"; do
    config_file="docker/${domain}.conf"
    if [ -f "$config_file" ]; then
        cp "$config_file" "/etc/nginx/sites-available/"
        ln -sf "/etc/nginx/sites-available/${domain}.conf" "/etc/nginx/sites-enabled/"
        log_info "✅ Скопирован конфиг для $domain"
    else
        log_warn "⚠️  Конфиг $config_file не найден"
    fi
done

# Проверяем конфигурацию nginx
log_info "Проверяем конфигурацию nginx..."
if nginx -t; then
    log_info "✅ Конфигурация nginx корректна"
else
    log_error "❌ Ошибка в конфигурации nginx"
    exit 1
fi

# Перезапускаем nginx
log_info "Перезапускаем nginx..."
systemctl reload nginx
log_info "✅ Nginx перезапущен"

# Получаем SSL сертификаты
log_info "Получаем SSL сертификаты..."
for domain in "${DOMAINS[@]}"; do
    log_info "Получаем сертификат для $domain..."
    if certbot --nginx -d "$domain" --non-interactive --agree-tos --email admin@telemetrio.pro; then
        log_info "✅ SSL сертификат получен для $domain"
    else
        log_warn "⚠️  Не удалось получить SSL сертификат для $domain"
    fi
done

# Проверяем статус сертификатов
log_info "Проверяем статус SSL сертификатов..."
certbot certificates

# Обновляем .env файл
ENV_FILE="docker/.env"
if [ -f "$ENV_FILE" ]; then
    log_info "Обновляем .env файл..."
    
    # Создаем резервную копию
    cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Обновляем URL в .env
    sed -i 's|CONSOLE_WEB_URL=.*|CONSOLE_WEB_URL=https://console.ai.telemetrio.pro|' "$ENV_FILE"
    sed -i 's|APP_WEB_URL=.*|APP_WEB_URL=https://app.ai.telemetrio.pro|' "$ENV_FILE"
    sed -i 's|CONSOLE_API_URL=.*|CONSOLE_API_URL=https://console.ai.telemetrio.pro/console/api|' "$ENV_FILE"
    sed -i 's|SERVICE_API_URL=.*|SERVICE_API_URL=https://api.app.ai.telemetrio.pro/api|' "$ENV_FILE"
    sed -i 's|APP_API_URL=.*|APP_API_URL=https://api.app.ai.telemetrio.pro/api|' "$ENV_FILE"
    sed -i 's|FILES_URL=.*|FILES_URL=https://files.ai.telemetrio.pro|' "$ENV_FILE"
    
    log_info "✅ .env файл обновлен"
else
    log_warn "⚠️  .env файл не найден: $ENV_FILE"
fi

# Перезапускаем Docker контейнеры
log_info "Перезапускаем Docker контейнеры..."
cd docker
docker-compose down
docker-compose up -d
log_info "✅ Docker контейнеры перезапущены"

# Проверяем статус контейнеров
log_info "Проверяем статус Docker контейнеров..."
docker-compose ps

# Финальная проверка
log_info "Проверяем доступность доменов..."
for domain in "${DOMAINS[@]}"; do
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain" | grep -q "200\|301\|302"; then
        log_info "✅ $domain доступен"
    else
        log_warn "⚠️  $domain недоступен"
    fi
done

echo ""
log_info "🎉 Настройка завершена!"
echo ""
log_info "Доступные домены:"
for domain in "${DOMAINS[@]}"; do
    echo "  - https://$domain"
done
echo ""
log_info "Не забудьте:"
echo "  1. Настроить DNS записи для всех поддоменов"
echo "  2. Проверить работу всех сервисов"
echo "  3. Настроить автообновление SSL сертификатов: certbot renew --dry-run"
