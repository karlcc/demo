# Docker Development Setup

This directory contains Docker configuration for running the Symfony Demo Application in a containerized environment.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/symfony/demo.git symfony-demo
   cd symfony-demo
   ```

2. **Set up environment:**
   ```bash
   cp .env.docker .env.local
   # Edit .env.local and set a proper APP_SECRET
   # Optionally set SERVER_PORT (defaults to 8100 if not provided)
   ```

3. **Build and run the application:**
   ```bash
   docker-compose up --build
   ```

4. **Access the application:**
   - Open your browser and go to `http://localhost:8100` (or your custom port)
   - The Symfony development server will be running inside the container

## Development Commands

### Building and Running
```bash
# Build and start containers
docker-compose up --build

# Start existing containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs -f
```

### Working Inside Container
```bash
# Access container shell
docker-compose exec symfony-app bash

# Run Symfony commands
docker-compose exec symfony-app php bin/console cache:clear
docker-compose exec symfony-app php bin/console doctrine:migrations:migrate

# Run tests
docker-compose exec symfony-app ./bin/phpunit

# Run code quality tools
docker-compose exec symfony-app ./vendor/bin/phpstan analyse
docker-compose exec symfony-app ./vendor/bin/php-cs-fixer fix
```

### Database Management
The application uses SQLite by default for simplicity. The database file is stored in `data/database.sqlite`.

To use MySQL instead:
1. Uncomment the MySQL service in `docker-compose.yml`
2. Update `DATABASE_URL` in `.env.local` to:
   ```
   DATABASE_URL="mysql://app:app@mysql:3306/symfony_demo?serverVersion=8.0.32&charset=utf8mb4"
   ```

## File Structure

```
docker/
├── Dockerfile              # Main container configuration
├── docker-compose.yml     # Docker Compose configuration
├── docker-entrypoint.sh   # Container startup script
├── supervisor.conf        # Supervisor configuration
└── README.md             # This file
```

## Environment Variables

- `APP_ENV`: Application environment (dev/prod)
- `APP_SECRET`: Application secret key (generate with `php bin/console secrets:generate-keys`)
- `SERVER_PORT`: Server port (defaults to 8100 if not provided)
- `DATABASE_URL`: Database connection string
- `SYMFONY_TRUSTED_PROXIES`: Trusted proxy IPs
- `SYMFONY_TRUSTED_HEADERS`: Trusted proxy headers

## Troubleshooting

### Port Already in Use
If port 8100 is already in use, you can set a different port:

1. **Via environment variable:**
   ```bash
   SERVER_PORT=9000 docker-compose up --build
   ```

2. **Or in .env.local:**
   ```
   SERVER_PORT=9000
   ```

3. **Or temporarily:**
   ```bash
   SERVER_PORT=9000 docker-compose up --build
   ```

### Permission Issues
If you encounter permission issues with the database or cache directories:
```bash
docker-compose exec symfony-app chown -R www-data:www-data /var/www/html/var /var/www/html/data
```

### Rebuilding Containers
If you make changes to the Dockerfile or dependencies:
```bash
docker-compose build --no-cache
docker-compose up
```

## Production Deployment

For production deployment, you should:

1. Set `APP_ENV=prod` in your environment
2. Generate a proper `APP_SECRET`
3. Use a proper database (MySQL/PostgreSQL)
4. Configure proper caching and asset optimization
5. Set up proper security and monitoring

The current setup is optimized for development. For production, consider:
- Using a multi-stage Docker build
- Separate nginx and php-fpm containers
- Proper volume management for persistent data
- Environment-specific configuration