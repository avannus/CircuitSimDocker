#!/bin/bash

# Run this file to test your Dockerfile
# Builds, pushes to :testing, and runs the container

set -e

# function cleanup {
#   echo -e "\n\n\n-----Cleaning up-----\n"
#   echo -e "\n\n\n-----Done Cleaning-----\n"
# }
# trap cleanup EXIT

link="https://www.roiatalla.com/public/CircuitSim/Linux/CircuitSim1.9.1"
name="CircuitSim1.9.1"

# Help
define() { IFS=$'\n' read -r -d '' "${1}" || true; }
usage_text=""
define usage_text <<'EOF'
USAGE:
    ./testing [amd64|arm64|all|-h|-c] [-c]

OPTIONS:
    amd, amd64 (default)
            Build the container for the amd64 architecture.
    arm, arm64
            Build the container for arm64 architecture.
    all
            Build the container for amd64 and arm64 architectures.
    h, -h, --h, help, -help, --help
            Show this help text.
    -c, -nc, --no-cache
            Do not use the cache when building the container.
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

#ARCH is the architectures to build
ARCH=""
#NO_CACHE is whether to use the cache when building the container
NO_CACHE=""

if [ $# -eq 0 ]; then
  ARCH="linux/amd64"
elif [ $# -gt 2 ]; then
  >&2 echo "Error: too many arguments"
  >&2 echo ""
  print_usage
  exit 1
else
  case "$1" in
    amd|amd64)
      ARCH="linux/amd64"
      ;;
    arm|arm64)
      ARCH="linux/arm64"
      ;;
    all)
      ARCH="linux/amd64,linux/arm64"
      ;;
    h|-h|--h|help|-help|--help)
      print_help
      exit 0
      ;;
    -c|-nc|--no-cache)
      ARCH="linux/amd64"
      NO_CACHE="--no-cache"
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
  if [ $# -eq 2 ]; then
    case "$2" in
      -c|-nc|--no-cache)
        NO_CACHE="--no-cache"
        ;;
      *)
        >&2 echo "Error: unrecognized argument: $2"
        >&2 echo ""
        print_usage
        exit 1
        ;;
    esac
  fi
fi

# Ensure docker is installed
if ! command -v docker &> /dev/null
then
  echo "docker could not be found"
  exit
fi

# Ensure docker buildx is installed
if ! command -v docker buildx &> /dev/null
then
  echo "docker buildx could not be found"
  exit
fi

# Ensure any architechture can be built
if ! docker buildx ls | grep -q "CircuitSimBuilder"; then
  echo -e "\n-----Starting init. dep. for build-----\n"
  time docker buildx create --name CircuitSimBuilder --driver docker-container
fi

echo -e "\n-----Done init. dep. for build-----\n\n\n-----Starting Build-----\n"

# Build image for specified platform, default of amd64
time docker buildx build \
  --builder CircuitSimBuilder \
  --platform $ARCH \
  -t avannus/circuit-sim:testing \
  --push \
  --build-arg LINK=$link \
  --build-arg NAME=$name \
  . $NO_CACHE


echo -e "\n-----Done Building-----\n\n\n-----Starting Pull-----\n"

# Move dir so mount works, use start script to pull and run image
cd ..
time ./CircuitSimDocker.sh --testing
cd docker
echo -e "\n-----Done Pulling-----"
