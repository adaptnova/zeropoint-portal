# build.hcl for the golden CUDA base image

# Define the target for the image
target "cuda" {
  # The context directory for the build
  context = "."
  # The Dockerfile to use
  dockerfile = "Dockerfile"
  # The platforms to build for
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  # The tags for the image
  tags = ["adaptnova/zeropoint-portal/base/cuda:latest"]
  # Labels for the image
  labels = {
    "org.opencontainers.image.source" = "https://github.com/adaptnova/zeropoint-portal"
    "org.opencontainers.image.vendor" = "AdaptNova"
  }
}