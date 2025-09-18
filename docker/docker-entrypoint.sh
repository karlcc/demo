#!/bin/bash

set -e

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
php bin/console assets:install public
php bin/console importmap:install
php bin/console sass:build

# Run database migrations
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction

# Load fixtures in development environment
if [ "$APP_ENV" == "dev" ]; then
    php bin/console doctrine:fixtures:load --no-interaction --append
fi

# Clear cache
php bin/console cache:clear --no-warmup
php bin/console cache:warmup

# Set proper permissions
chown -R www-data:www-data /var/www/html/var /var/www/html/data

# Execute the command
exec "$@"