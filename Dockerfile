FROM composer:latest AS composer

WORKDIR /var/www/html

COPY . .

RUN apt-get update && apt-get install -y \
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
    php-fileinfo

RUN composer install --no-dev --optimize-autoloader
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN npm install && npm run build

RUN php artisan key:generate
RUN php artisan migrate --force
RUN php artisan storage:link

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
