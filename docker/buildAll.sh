#!/bin/bash
# Run this file to build all containers

set -e

# function cleanup {
#   echo -e "\n-----Cleaning up-----\n"
#   echo -e "\n-----Done Cleaning-----\n"
# }
# trap cleanup EXIT

DOCKER_REPO="avannus/circuit-sim"
#ARCH is the architectures to build
ARCH="linux/amd64,linux/arm64"
#NO_CACHE is whether to use the cache when building the container
NO_CACHE=""
DOWNLOAD=false
CircuitSimLinks=./CircuitSimLinks.txt

# Help
description="Build all containers"
define() { IFS=$'\n' read -r -d '' "${1}" || true; }
usage_text=""
define usage_text <<'EOF'
USAGE:
    ./buildAll.sh [-h|-c|-d]

OPTIONS:
    h, -h, --h, help, -help, --help
            Show this help text.
    -c, -nc, --no-cache
            Do not use the cache when building the container.
    -d, --download
            Download all pushed containers
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

if [ $# -eq 0 ]; then
  :
elif [ $# -eq 1 ]; then
  case "$1" in
    h|-h|--h|help|-help|--help)
      print_help
      exit 0
      ;;
    -c|-nc|--no-cache)
      NO_CACHE="--no-cache"
      ;;
    -d|--download)
      DOWNLOAD=true
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
else
  >&2 echo "Error: too many arguments"
  >&2 echo ""
  print_usage
  exit 1
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
  echo -e "\n-----Creating CircuitSimBuilder with buildx-----\n"
  time docker buildx create --name CircuitSimBuilder --driver docker-container --bootstrap
fi

echo -e "\n-----Done init. dep. for build-----\n\n-----Starting Download of Links-----\n"

# Download links
time lynx -dump https://www.roiatalla.com/public/CircuitSim/Linux/ | awk '/http/{print $2}' > $CircuitSimLinks
time sed -i '1d' $CircuitSimLinks
links=$(cat $CircuitSimLinks)

echo -e "\n-----Done Downloading Links-----\n\n-----Starting Builds-----\n"

finalLink=""
finalName=""

for link in $links
do
  name=${link##*/}
  imageName="$DOCKER_REPO:$name"
  echo -e "\n-----Starting Build of $name-----\n"
  time docker buildx build \
    --builder CircuitSimBuilder \
    --platform $ARCH \
    -t $imageName \
    --push \
    --build-arg LINK=$link \
    --build-arg NAME=$name \
    . $NO_CACHE
  echo -e "\n-----Done Building $name-----\n"
  if [ -z "$finalName" ] || [ $DOWNLOAD = true ]; then
    if [ -z "$finalName" ]; then
      echo -e "\n-----First image, pulling-----\n"
    else
      echo -e "\n-----Pulling image-----\n"
    fi
    time docker pull $imageName
    echo -e "\n-----Done pulling image, continuing-----\n"
  fi
  finalName=$name
  finalLink=$link
done

echo -e "\n-----Done Building, pulling final build-----\n"
time docker pull $imageName
echo -e "\n-----Done pulling final build-----\n"

read -p "Have you tested this on both ARM64 and AMD64 and want to push $finalName to stable? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 0
fi

echo -e "\n-----Starting Push to Stable-----\n"
link=$finalLink
name=$finalName
imageName="$DOCKER_REPO:stable"
time docker buildx build \
  --builder CircuitSimBuilder \
  --platform $ARCH \
  -t $imageName \
  --push \
  --build-arg LINK=$link \
  --build-arg NAME=$name \
  . $NO_CACHE

echo -e "\n-----Done Pushing to Stable-----\n"
