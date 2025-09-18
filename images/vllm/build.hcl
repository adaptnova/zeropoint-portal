# build.hcl for the vllm application image

# Define the target for the image
target "vllm" {
  # The context directory for the build
  context = "."
  # The Dockerfile to use
  dockerfile = "Dockerfile"
  # The platforms to build for
  platforms = [
    "linux/amd64"
  ]
  # The tags for the image
  tags = ["adaptnova/zeropoint-portal/app/vllm:latest"]
  # Labels for the image
  labels = {
    "org.opencontainers.image.source" = "https://github.com/adaptnova/zeropoint-portal"
    "org.opencontainers.image.vendor" = "AdaptNova"
  }
}