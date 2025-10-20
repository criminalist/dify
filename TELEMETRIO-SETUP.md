# Настройка ai.telemetrio.pro для Dify

## 🎯 Настройка поддомена для Dify

### 1. DNS настройка
Добавьте в DNS записи для домена `telemetrio.pro`:

```
A    ai.telemetrio.pro    → 192.168.0.2
A    www.ai.telemetrio.pro → 192.168.0.2
```

### 2. Быстрая настройка nginx
```bash
# Скопируйте конфигурацию
sudo cp ai.telemetrio.pro.conf /etc/nginx/sites-available/ai.telemetrio.pro

# Создайте символическую ссылку
sudo ln -sf /etc/nginx/sites-available/ai.telemetrio.pro /etc/nginx/sites-enabled/

# Проверьте конфигурацию
sudo nginx -t

# Перезапустите nginx
sudo systemctl reload nginx
```

### 3. Настройка HTTPS с Let's Encrypt
```bash
# Установите certbot
sudo apt install certbot python3-certbot-nginx

# Получите SSL сертификат
sudo certbot --nginx -d ai.telemetrio.pro

# Автоматическое обновление сертификатов
sudo crontab -e
# Добавьте строку:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

### 4. Обновление переменных окружения Docker
Обновите файл `docker/.env`:

```bash
# Замените IP адреса на ваш поддомен
CONSOLE_WEB_URL=https://ai.telemetrio.pro
APP_WEB_URL=https://ai.telemetrio.pro
CONSOLE_API_URL=https://ai.telemetrio.pro/console/api
SERVICE_API_URL=https://ai.telemetrio.pro/api
APP_API_URL=https://ai.telemetrio.pro/api
FILES_URL=https://ai.telemetrio.pro/files
INTERNAL_FILES_URL=http://api:5001/files
```

### 5. Перезапуск Docker контейнеров
```bash
cd /path/to/dify/docker
docker-compose down
docker-compose up -d
```

## 🔧 Дополнительные поддомены

### Для продакшена:
```bash
# Основной поддомен
sudo ./setup-domain-proxy.sh dify.telemetrio.pro

# Чат поддомен
sudo ./setup-domain-proxy.sh chat.telemetrio.pro

# Платформа поддомен
sudo ./setup-domain-proxy.sh platform.telemetrio.pro
```

### Для разработки:
```bash
# Тестовый поддомен
sudo ./setup-domain-proxy.sh test.telemetrio.pro

# Поддомен для разработки
sudo ./setup-domain-proxy.sh dev.telemetrio.pro

# Поддомен для стейджинга
sudo ./setup-domain-proxy.sh staging.telemetrio.pro
```

## 🛡️ Безопасность

### Firewall настройки
```bash
# Блокируйте прямой доступ к Docker портам
sudo ufw deny 8000
sudo ufw deny 4433
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### Fail2ban для защиты от брутфорса
```bash
# Установите fail2ban
sudo apt install fail2ban

# Создайте конфигурацию для nginx
sudo nano /etc/fail2ban/jail.local
```

Добавьте в файл:
```ini
[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/ai.telemetrio.pro.error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/ai.telemetrio.pro.access.log
maxretry = 10
```

## 📊 Мониторинг

### Логи nginx
```bash
# Просмотр логов доступа
sudo tail -f /var/log/nginx/ai.telemetrio.pro.access.log

# Просмотр логов ошибок
sudo tail -f /var/log/nginx/ai.telemetrio.pro.error.log

# Статистика по IP адресам
sudo awk '{print $1}' /var/log/nginx/ai.telemetrio.pro.access.log | sort | uniq -c | sort -nr | head -10
```

### Мониторинг Docker
```bash
# Статус контейнеров
docker-compose ps

# Логи всех сервисов
docker-compose logs

# Использование ресурсов
docker stats
```

## 🚀 Проверка работы

### Тестирование HTTP
```bash
curl -I http://ai.telemetrio.pro
```

### Тестирование HTTPS
```bash
curl -I https://ai.telemetrio.pro
```

### Тестирование API
```bash
curl -I https://ai.telemetrio.pro/console/api/system-features
```

### Тестирование файлов
```bash
curl -I https://ai.telemetrio.pro/files/
```

## 🔄 Обновление конфигурации

### После изменений в nginx
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### После изменений в Docker
```bash
cd /path/to/dify/docker
docker-compose down
docker-compose up -d
```

## 📝 Резервное копирование

### Конфигурация nginx
```bash
sudo tar -czf nginx-config-backup.tar.gz /etc/nginx/sites-available/ai.telemetrio.pro /etc/nginx/sites-enabled/ai.telemetrio.pro
```

### SSL сертификаты
```bash
sudo tar -czf ssl-certs-backup.tar.gz /etc/letsencrypt/live/ai.telemetrio.pro/
```

## 🆘 Устранение проблем

### Проблема: 502 Bad Gateway
```bash
# Проверьте статус Docker
docker-compose ps

# Проверьте доступность порта
netstat -tlnp | grep 8000

# Проверьте логи nginx
sudo tail -f /var/log/nginx/ai.telemetrio.pro.error.log
```

### Проблема: SSL ошибки
```bash
# Проверьте сертификаты
sudo certbot certificates

# Обновите сертификаты
sudo certbot renew --dry-run
```

### Проблема: CORS ошибки
Убедитесь что в конфигурации nginx есть CORS заголовки для API endpoints.

## 🎉 Результат

После настройки у вас будет:
- ✅ Красивый URL: `https://ai.telemetrio.pro`
- ✅ SSL сертификат от Let's Encrypt
- ✅ Правильное проксирование без дублирования путей
- ✅ Безопасность и мониторинг
- ✅ Возможность легко добавить дополнительные поддомены
