#!/bin/bash

set -e

# Install Composer dependencies if vendor directory doesn't exist
if [ ! -d "vendor" ]; then
    echo "Installing Composer dependencies..."
    composer install --no-interaction --optimize-autoloader
fi

# Wait for database if using MySQL/PostgreSQL
# if [ "$DATABASE_URL" != "sqlite:///%kernel.project_dir%/data/database.sqlite" ]; then
#     echo "Waiting for database to be ready..."
#     until php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
#         sleep 1
#     done
# fi

# Create database directory if it doesn't exist
mkdir -p data

# Create database for SQLite
if [ "$DATABASE_URL" == "sqlite:///%kernel.project_dir%/data/database.sqlite" ]; then
    touch data/database.sqlite
    chmod 666 data/database.sqlite
fi

# Build assets
php bin/console assets:install public --no-interaction
php bin/console importmap:install --no-interaction
php bin/console sass:build --no-interaction || echo "sass:build not available, skipping..."

# Run database migrations
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction

# Load fixtures in development environment
if [ "$APP_ENV" == "dev" ]; then
    php bin/console doctrine:fixtures:load --no-interaction --append
fi

# Clear cache
php bin/console cache:clear --no-warmup --no-interaction
php bin/console cache:warmup --no-interaction

# Set proper permissions
chown -R www-data:www-data /var/www/html/var /var/www/html/data

# Execute the command
exec "$@"