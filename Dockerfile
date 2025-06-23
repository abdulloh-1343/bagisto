# Используем PHP с Apache и возможностью устанавливать пакеты
FROM php:8.2-apache

# Устанавливаем рабочую директорию
WORKDIR /var/www/html

# Устанавливаем системные зависимости и Node.js 18
RUN apt-get update && \
    apt-get install -y curl gnupg2 ca-certificates lsb-release && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y \
        nodejs \
        unzip \
        git \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        zip \
        npm && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Устанавливаем Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Копируем проект
COPY . .

# Устанавливаем PHP и Node зависимости
RUN composer install --no-dev --optimize-autoloader && \
    npm install && \
    npm run build

RUN npm install && npm run build

# Laravel config cache
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    php artisan storage:link || true

# Открываем порт
EXPOSE 80

# Apache уже слушает 80 порт
CMD ["apache2-foreground"]
