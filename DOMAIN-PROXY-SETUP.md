# Настройка nginx как прокси для домена Dify

## Обзор
Этот подход позволяет использовать домен вместо IP-адреса для доступа к Dify, при этом nginx на хосте проксирует запросы на Docker контейнеры.

## Схема работы
```
Пользователь → Домен (example.com) → Внешний nginx (192.168.0.2) → Docker nginx (порт 8000) → Dify сервисы
```

## Шаги настройки

### 1. Подготовка
```bash
# Убедитесь что Docker контейнеры запущены
cd /path/to/dify/docker
docker-compose up -d

# Проверьте что порт 8000 доступен
curl -I http://127.0.0.1:8000
```

### 2. Настройка DNS
Настройте DNS запись для вашего домена:
```
A    dify.example.com    → 192.168.0.2
A    www.dify.example.com → 192.168.0.2
```

### 3. Установка nginx (если не установлен)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx
# или
sudo dnf install nginx
```

### 4. Настройка прокси
```bash
# Сделайте скрипт исполняемым
chmod +x setup-domain-proxy.sh

# Запустите настройку
sudo ./setup-domain-proxy.sh dify.example.com
```

### 5. Настройка HTTPS (опционально)
```bash
# Установите certbot
sudo apt install certbot python3-certbot-nginx

# Получите SSL сертификат
sudo certbot --nginx -d dify.example.com -d www.dify.example.com
```

### 6. Обновление переменных окружения Docker
Обновите файл `.env` в папке `docker/`:

```bash
# Замените IP адреса на домен
CONSOLE_WEB_URL=https://dify.example.com
APP_WEB_URL=https://dify.example.com
CONSOLE_API_URL=https://dify.example.com/console/api
SERVICE_API_URL=https://dify.example.com/api
APP_API_URL=https://dify.example.com/api
FILES_URL=https://dify.example.com/files
INTERNAL_FILES_URL=http://api:5001/files
```

### 7. Перезапуск Docker контейнеров
```bash
cd /path/to/dify/docker
docker-compose down
docker-compose up -d
```

## Проверка работы

### Проверка прокси
```bash
# Проверьте что домен отвечает
curl -I https://dify.example.com

# Проверьте API
curl -I https://dify.example.com/console/api/system-features
```

### Проверка логов
```bash
# Логи внешнего nginx
sudo tail -f /var/log/nginx/dify.example.com.access.log
sudo tail -f /var/log/nginx/dify.example.com.error.log

# Логи Docker nginx
docker-compose logs nginx
```

## Преимущества этого подхода

1. **Красивые URL**: `https://dify.example.com` вместо `http://192.168.0.2:8000`
2. **SSL/TLS**: Легко настроить HTTPS с Let's Encrypt
3. **Гибкость**: Можно добавить дополнительные домены или поддомены
4. **Безопасность**: Можно настроить firewall для блокировки прямого доступа к портам
5. **Масштабируемость**: Легко добавить load balancing или дополнительные сервисы

## Дополнительные настройки

### Firewall
```bash
# Блокируйте прямой доступ к портам Docker
sudo ufw deny 8000
sudo ufw deny 4433
sudo ufw allow 80
sudo ufw allow 443
```

### Мониторинг
```bash
# Установите мониторинг nginx
sudo apt install nginx-module-njs
```

## Устранение проблем

### Проблема: 502 Bad Gateway
```bash
# Проверьте что Docker контейнеры запущены
docker-compose ps

# Проверьте что порт 8000 доступен
netstat -tlnp | grep 8000
```

### Проблема: Дублирование путей
Убедитесь что в конфигурации nginx используются правильные пути:
```nginx
location /console/api/ {
    proxy_pass http://127.0.0.1:8000/console/api/;
}
```

### Проблема: SSL ошибки
```bash
# Проверьте сертификаты
sudo certbot certificates

# Обновите сертификаты
sudo certbot renew
```
