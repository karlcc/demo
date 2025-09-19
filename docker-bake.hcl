variable "TAG" {
  default = "latest"
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

group "default" {
  targets = ["symfony-demo", "symfony-demo-test"]
}

target "symfony-demo" {
  dockerfile = "Dockerfile"
  tags = ["symfony-demo:${TAG}"]
  platforms = PLATFORMS
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "symfony-demo-test" {
  dockerfile = "Dockerfile.test"
  tags = ["symfony-demo-test:${TAG}"]
  platforms = PLATFORMS
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}