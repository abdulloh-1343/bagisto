# Установка базового PHP-окружения на основе Ubuntu
FROM ubuntu:22.04

# Обновление системы и установка зависимостей
RUN apt-get update && apt-get install -y \
    php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-mysql php-sqlite3 php-gd php-tokenizer \
    unzip curl git zip nodejs npm nginx supervisor sqlite3

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Установка Node 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Создание рабочей директории
WORKDIR /var/www/html

# Копирование всех файлов
COPY . .

# Установка зависимостей Laravel
RUN composer install --no-dev --optimize-autoloader

# Сборка фронтенда
RUN npm install && npm run build

# Генерация ключа приложения
RUN php artisan config:clear && php artisan key:generate

# Создание базы SQLite
RUN mkdir -p database && touch database/database.sqlite

# Миграции и ссылка на storage
RUN php artisan migrate --force && php artisan storage:link

# Открытие порта
EXPOSE 8000

# Запуск Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
