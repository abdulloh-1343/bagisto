# Используем официальный PHP-образ с поддержкой Composer
FROM php:8.1-fpm

# Установка системных пакетов и Node.js
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev libzip-dev zip \
    gnupg2 ca-certificates lsb-release \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs npm \
    && docker-php-ext-install pdo_mysql mbstring zip gd

# Устанавливаем Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка зависимостей Laravel
WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader && \
    npm install && npm run build

# Настройка прав
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
