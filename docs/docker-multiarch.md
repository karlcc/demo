# Multi-Architecture Docker Setup

This document explains the multi-architecture Docker setup for the Symfony Demo Application.

## Overview

The project supports building and testing Docker images for multiple architectures:
- **linux/amd64** (Intel/AMD 64-bit)
- **linux/arm64** (ARM 64-bit, including Apple Silicon and ARM servers)

## Files

### Docker Configuration
- `Dockerfile` - Production image with FPM
- `Dockerfile.test` - Test image with CLI and development tools
- `docker-compose.yml` - Standard Docker Compose setup
- `docker-compose.test.yml` - Testing-specific services
- `docker-compose.multiarch.yml` - Multi-architecture specific setup
- `docker-bake.hcl` - Docker Bake configuration for advanced builds

### GitHub Actions
- `.github/workflows/docker-tests.yaml` - Comprehensive multi-architecture testing

## Build Strategies

### 1. GitHub Actions Multi-Architecture Pipeline

The workflow implements a "build-once, test-many" pattern:

1. **Build Stage**: Creates multi-architecture images using `docker/build-push-action`
2. **Test Stages**: Downloads and tests images on specific architectures
3. **Compose Test**: Tests Docker Compose integration
4. **Bake Test**: Tests advanced Docker Bake builds

Key features:
- ✅ GitHub Actions cache integration
- ✅ Artifact-based image distribution
- ✅ Separate AMD64 and ARM64 test jobs
- ✅ BuildKit caching for faster builds

### 2. Local Multi-Architecture Development

#### Using Docker Bake (Recommended)
```bash
# Build for multiple architectures
docker buildx bake -f docker-bake.hcl

# Build specific target
docker buildx bake symfony-demo-test

# Build with custom tag
TAG=v1.0.0 docker buildx bake
```

#### Using Docker Compose
```bash
# Standard build (host architecture)
docker compose -f docker-compose.test.yml build

# Multi-architecture build (requires buildx)
docker buildx bake -f docker-compose.multiarch.yml
```

#### Manual Buildx Commands
```bash
# Set up buildx builder
docker buildx create --name multiarch --use

# Build test image for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --file Dockerfile.test \
  --tag symfony-demo-test:latest \
  --push .  # or --load for local use
```

## Testing

### Local Testing
```bash
# Test on current architecture
docker compose -f docker-compose.test.yml run --rm symfony-test

# Test specific architecture
docker run --platform linux/amd64 \
  -v $(pwd):/var/www/html \
  symfony-demo-test:latest \
  ./bin/phpunit

docker run --platform linux/arm64 \
  -v $(pwd):/var/www/html \
  symfony-demo-test:latest \
  ./bin/phpunit
```

### GitHub Actions Testing

The workflow automatically tests:
1. **Multi-arch build creation** with caching
2. **AMD64 testing** with full test suite
3. **ARM64 testing** with full test suite
4. **Docker Compose integration**
5. **Docker Bake advanced builds**

## Performance Optimizations

### Caching Strategy
- **GitHub Actions Cache**: Persistent cache across workflow runs
- **BuildKit Cache**: Layer caching for faster builds
- **Artifact Distribution**: Build once, test multiple times

### Build Optimizations
- **Multi-stage Dockerfiles**: Separate build and runtime stages
- **Platform-specific optimizations**: Conditional logic for different architectures
- **Dependency caching**: Composer and npm package caching

## Architecture Compatibility

### Supported Platforms
- ✅ **linux/amd64**: Standard Intel/AMD 64-bit
- ✅ **linux/arm64**: ARM 64-bit (Apple Silicon, ARM servers)

### Dependencies
All project dependencies are compatible with both architectures:
- ✅ **PHP 8.4**: Native support for both platforms
- ✅ **Composer packages**: Multi-architecture compatible
- ✅ **Node.js/npm**: Multi-architecture compatible
- ✅ **System packages**: Available for both platforms

## Troubleshooting

### Common Issues

1. **QEMU emulation slowness**
   - ARM64 tests may run slower on AMD64 runners
   - This is expected behavior for cross-platform emulation

2. **Platform mismatch warnings**
   - Add `--platform` flag to specify architecture explicitly
   - Use multi-architecture aware base images

3. **Cache miss issues**
   - Ensure consistent cache keys across builds
   - Check GitHub Actions cache limits

### Debug Commands
```bash
# Check available platforms
docker buildx ls

# Inspect multi-arch image
docker buildx imagetools inspect symfony-demo-test:latest

# Test platform detection
docker run --rm symfony-demo-test:latest uname -m
```

## Best Practices

1. **Always test on target architectures** before deployment
2. **Use BuildKit caching** for faster iteration
3. **Leverage GitHub Actions cache** for CI/CD efficiency
4. **Monitor build times** and optimize Dockerfiles accordingly
5. **Keep base images updated** for security and compatibility