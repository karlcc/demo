FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libsqlite3-dev \
    libonig-dev \
    nodejs \
    npm \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_sqlite \
        zip \
        intl \
        gd \
        opcache \
    && docker-php-ext-enable opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
# Install with dev dependencies since docker-compose sets APP_ENV=dev
RUN composer install --no-interaction --no-scripts --optimize-autoloader

# Copy application files (excluding vendor due to .dockerignore)
COPY . .

# Copy entrypoint script
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create directories and set proper permissions
RUN mkdir -p var/cache var/log data \
    && chown -R www-data:www-data . \
    && chmod -R 755 . \
    && chmod -R 775 var data

# Run composer scripts to generate autoload_runtime.php
RUN composer dump-autoload --optimize \
    && composer run-script post-install-cmd || true

# Install frontend assets after copying application files
RUN php bin/console importmap:install \
    && php bin/console assets:install public || true

# Install npm dependencies if they exist
RUN if [ -f "package.json" ]; then npm ci; fi

# Configure PHP
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Configure opcache
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Create supervisor config for Symfony server
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor
COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Expose port
EXPOSE 8100

# Supervisor needs root, but apps run as www-data (configured in supervisor.conf)
# Start supervisor via docker-compose