FROM php:8.1-fpm

# Установка системных зависимостей
RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        unzip \
        git \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        zip && \
    # Установка Node.js 18 (вместе с npm)
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    # Установка PHP-расширений
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip && \
    # Очистка кэша apt
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка зависимостей Laravel/Bagisto
WORKDIR /var/www/html
COPY . .

RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    npm install && \
    npm run build

EXPOSE 9000
CMD ["php-fpm"]
