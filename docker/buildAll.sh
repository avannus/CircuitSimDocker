#!/bin/bash
# Run this file to build all containers

set -e

DOCKER_USER="avannus"
DOCKER_REPO="$DOCKER_USER/circuit-sim"
ARCH="linux/amd64,linux/arm64"
DOWNLOAD_SOURCE="https://www.roiatalla.com/public/CircuitSim/Linux/"

CircuitSimLinks=./CircuitSimLinks.txt # File to store links to CircuitSim
NO_CACHE="" # Set to --no-cache to not use cache when building
DOWNLOAD=false # Set to true to download all images after building
NEW=true # Set to false to rebuild all images, even if they already exist


# Help
define(){ IFS='\n' read -r -d '' ${1} || true; }

description="Build all versions of CircuitSim available and push all images to Docker Hub."

define usage_text <<EOF
USAGE:
    ./buildAll.sh -h|-c|-d|-r|-A [buildx targets]|-U [dockerhub username]|-R <repo name>

OPTIONS:
    -h, --help
            Show this help text.
    -c
            Do not use cache when building each container.
    -d
            Download all pushed containers
    -r
            Build and push all containers, even if they already exist
CONFIG:
    -A [buildx targets]
            The architectures to build for. Script Default: $ARCH
    -U [dockerhub username]
            The user to push the images to. Script Default: $DOCKER_USER
    -R [repo name]
            The repository to push the images to. Script Default: $DOCKER_REPO
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

# Parse arguments
while getopts "hcdA:U:R:-:" opt; do
  case $opt in
    -)
      case "${OPTARG}" in
        help)
          print_help
          exit 0
          ;;
        *)
          if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
              echo "Unknown option --${OPTARG}" >&2
              print_usage
              exit 1
          fi
          ;;
      esac;;
    h)
      print_help
      exit 0
      ;;
    c)
      NO_CACHE="--no-cache"
      ;;
    d)
      DOWNLOAD=true
      ;;
    r)
      NEW=false
      ;;
    A)
      ARCH=$OPTARG
      ;;
    U)
      DOCKER_USER=$OPTARG
      ;;
    R)
      DOCKER_REPO=$OPTARG
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      print_usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      print_usage
      exit 1
      ;;
  esac
done

echo $DOCKER_REPO

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

# Ensure user is logged in
if ! docker info | grep -q "Username: $DOCKER_USER"; then
  echo "Please login to docker as $DOCKER_USER or set the correct user with -U"
  exit
fi

if ! command -v lynx &> /dev/null
then
  echo "lynx could not be found"
  exit
fi

if ! command -v sed &> /dev/null
then
  echo "sed could not be found"
  exit
fi

if ! command -v awk &> /dev/null
then
  echo "awk could not be found"
  exit
fi

# Ensure any architechture can be built
if ! docker buildx ls | grep -q "CircuitSimBuilder"; then
  echo -e "\n-----Creating CircuitSimBuilder with buildx-----\n"
  time docker buildx create --name CircuitSimBuilder --driver docker-container --bootstrap
fi

echo -e "\n-----Done init. dep. for build-----\n\n-----Starting Download of Links from $DOWNLOAD_SOURCE-----\n"

# Download links
lynx -dump $DOWNLOAD_SOURCE | awk '/http/{print $2}' > $CircuitSimLinks
sed -i '1d' $CircuitSimLinks # Remove first line (parent directory)
links=$(cat $CircuitSimLinks)

echo -e "\n-----Done Downloading Links-----\n"
echo -e "\n-----Starting Builds-----\n"

finalLink=""
finalName=""

for link in $links
do
  name=${link##*/}
  imageName="$DOCKER_REPO:$name"
  if [ $NEW=true ]; then
    echo -e "\n-----Checking if $name exists on Docker Hub-----"
    if curl --silent -f -lSL https://hub.docker.com/v2/repositories/${DOCKER_USER}/circuit-sim/tags/{$name} > /dev/null; then
      echo -e "-----Skipping $name, exists on Docker Hub-----\n"
      continue
    else
      echo -e "-----$name not found on Docker Hub-----\n"
    fi
  else 
    echo -e "\n-----Building all images-----\n"
  fi
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
  if [ $DOWNLOAD = true ]; then
    echo -e "\n-----Pulling image-----\n"
    time docker pull $imageName
    echo -e "\n-----Done pulling image, continuing-----\n"
  fi
  finalName=$name
  finalLink=$link
done

echo -e "\n-----Done Building-----\n"

if [ finalName=="" ]; then
  echo "No new images to push to stable, exiting"
  exit 0
fi

read -p "Have you tested $finalName on both ARM64 and AMD64 and want to push $finalName to stable? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting"
    exit 0
fi

read -p "You're SURE that you tested $finalName on BOTH ARM64 and AMD64 and want to push $finalName to stable? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting"
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
