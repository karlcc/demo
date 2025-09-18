# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the official Symfony Demo Application, a reference project demonstrating Symfony best practices. It's a complete blog application showcasing Symfony framework capabilities including user authentication, blog post management, admin interfaces, and internationalization.

## Development Commands

### Running the Application
- `symfony serve` - Start the development server (requires Symfony CLI)
- `php -S localhost:8000 -t public/` - Use built-in PHP web server

### Testing
- `./bin/phpunit` - Run all tests
- Tests use PHPUnit 11 with database transaction rollback via DAMA\DoctrineTestBundle

### Code Quality
- `./vendor/bin/phpstan analyse` - Static analysis (level 6)
- `./vendor/bin/php-cs-fixer fix` - Fix code style
- `./vendor/bin/php-cs-fixer fix --dry-run` - Check code style without fixing

### Database Operations
- `php bin/console doctrine:database:create` - Create database
- `php bin/console doctrine:migrations:migrate` - Run migrations
- `php bin/console doctrine:fixtures:load` - Load test fixtures

### Asset Management
- `php bin/console assets:install public` - Install assets
- `php bin/console importmap:install` - Install importmap dependencies
- `php bin/console sass:build` - Compile Sass assets

## Architecture

### Core Symfony Structure
- `src/` - Application code following PSR-4 autoloading (`App\` namespace)
- `src/Controller/` - HTTP controllers (Default, Blog, User, Admin)
- `src/Entity/` - Doctrine ORM entities (Post, User, Comment, Tag)
- `src/Repository/` - Doctrine repositories
- `src/Form/` - Symfony form types and data transformers
- `src/Security/` - Security components (User provider, voter)
- `config/` - Symfony configuration (routes, services, packages)
- `templates/` - Twig templates
- `public/` - Web root with entry point (`index.php`)

### Key Features
- User authentication with Symfony Security component
- Blog post CRUD operations with admin interface
- Comment system with moderation
- Tag-based categorization
- Internationalization (i18n) support
- Bootstrap 5 UI with Twig templates
- Asset management via AssetMapper component
- Live components with Symfony UX

### Database
- Uses Doctrine ORM with SQLite
- Migrations in `migrations/` directory
- Test fixtures available via DoctrineFixturesBundle

### Testing Strategy
- PHPUnit 11 with strict error reporting
- DAMA Doctrine Test Bundle for database transaction isolation
- Test doubles in `tests/` namespace (`App\Tests\`)
- Integration tests for controllers and commands

## Environment Configuration
- Environment files: `.env`, `.env.dev`, `.env.test`, `.env.local.demo`
- Uses Symfony Dotenv component for configuration
- Test environment automatically configured for database transactions

## Code Style
- PHP-CS-Fixer with Symfony rules and risky rules enabled
- Strict type checking and comparison
- Header comments with Symfony license
- PSR-4 autoloading for `App\` namespace
- PSR-12 coding standards

## Static Analysis
- PHPStan at level 6 with Symfony and Doctrine extensions
- Baseline file for existing issues
- Doctrine object manager integration for entity analysis