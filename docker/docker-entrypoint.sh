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

# Run database migrations (skip database creation for SQLite)
echo "Database URL: $DATABASE_URL"
if [[ "$DATABASE_URL" != sqlite:* ]]; then
    echo "Creating database for non-SQLite..."
    php bin/console doctrine:database:create --if-not-exists || echo "Database creation failed, continuing..."
else
    echo "Skipping database creation for SQLite..."
fi
php bin/console doctrine:migrations:migrate --no-interaction || echo "Migrations failed, continuing..."

# Load fixtures in development environment only if database is empty
if [ "$APP_ENV" == "dev" ]; then
    # Check if users table exists and has data
    USER_COUNT=$(php bin/console dbal:run-sql "SELECT COUNT(*) FROM symfony_demo_user" 2>/dev/null | tail -1 || echo "0")
    if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then
        echo "Loading fixtures for empty database..."
        php bin/console doctrine:fixtures:load --no-interaction
    else
        echo "Database already has data, skipping fixtures..."
    fi
fi

# Clear cache
php bin/console cache:clear --no-warmup --no-interaction
php bin/console cache:warmup --no-interaction

# Set proper permissions (ignore volume mount permission errors)
chown -R www-data:www-data /var/www/html/var || echo "Cannot change var permissions, continuing..."
chown -R www-data:www-data /var/www/html/data || echo "Cannot change data permissions, continuing..."

# Execute the command
exec "$@"