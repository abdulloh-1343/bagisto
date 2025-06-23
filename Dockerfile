# Используем официальный образ composer с PHP
FROM composer:latest

# Устанавливаем рабочую директорию
WORKDIR /var/www/html

# Копируем весь проект в контейнер
COPY . .

# Устанавливаем зависимости PHP и Node.js
RUN apt-get update && \
    apt-get remove -y nodejs libnode-dev libnode72 || true && \
    rm -f /usr/share/systemtap/tapset/node.stp || true && \
    apt-get install -y \
        unzip \
        git \
        curl \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        zip \
        libzip-dev \
        php-mysql \
        php-sqlite3 \
        php-curl \
        php-mbstring \
        php-dom \
        php-bcmath \
        php-zip \
        php-gd \
        php-tokenizer \
        php-fileinfo \
        gnupg \
        ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install && \
    npm run build

# Устанавливаем зависимости Laravel через Composer
RUN composer install --no-dev --optimize-autoloader

# Кэшируем конфигурацию Laravel
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Создаём символическую ссылку для storage
RUN php artisan storage:link || true

# Применяем миграции БД
RUN php artisan migrate --force

# Открываем порт для сервера
EXPOSE 8000

# Запуск Laravel через встроенный PHP сервер (можно заменить на nginx/php-fpm)
CMD php artisan serve --host=0.0.0.0 --port=8000
