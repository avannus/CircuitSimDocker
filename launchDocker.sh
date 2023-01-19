#!/bin/bash

release="stable"
imageBaseName="avannus/circuit-sim"
imageName="${imageBaseName}:${release}"
hostDir="/host/"
GT2110Container="gtcs2110/cs2110docker"
p1=5800
p2=5900

define() { IFS=$'\n' read -r -d '' "${1}" || true; }

description="Update and Run a $imageBaseName container"

usage_text=""
define usage_text <<'EOF'
USAGE:
    ./launchDocker.sh [start|stop|-h|-t]

OPTIONS:
    start (default)
            Start a new (graphical) container in the background. This is the default if no options
            are provided.
            This will also update the container if it is out of date. 
            The directory from which this is run will be mounted to the container.
    stop
            Stop and remove any running instances of the container.
    -h, --help
            Show this help text.
    -t, --testing
            Pull and run the testing version of the container.
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

action=""
if [ $# -eq 0 ]; then
  action="start"
elif [ $# -eq 1 ]; then
  case "$1" in
    start)
      action="start"
      ;;
    stop)
      action="stop"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -t|--testing)
      action="start"
      release="testing"
      imageName="${imageBaseName}:${release}"
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
fi

### Check for Docker ###
if ! docker -v >/dev/null; then
  >&2 echo "ERROR: Docker not found. Please install Docker before running this script."
  exit 1
fi
if ! docker container ls >/dev/null; then
  >&2 echo "ERROR: Docker is not currently running. Please start Docker before running this script."
  exit 1
fi
echo "Found Docker Installation. Checking for existing containers."

### Check for existing containers ###
existingContainers=($(docker ps -a | grep "$imageBaseName" | awk '{print $1}'))
echo "${existingContainers[@]}"
if [ "${#existingContainers[@]}" -ne 0 ]; then
  echo "Found $imageBaseName containers. Stopping and removing them."
  docker stop "${existingContainers[@]}" >/dev/null
  docker rm "${existingContainers[@]}" >/dev/null
else
  echo "No existing $imageBaseName containers."
fi

### Check for existing GT2110 containers ###
existingContainers=($(docker ps -a | grep "$GT2110Container" | awk '{print $1}'))
echo "${existingContainers[@]}"
if [ "${#existingContainers[@]}" -ne 0 ]; then
  echo "Found $GT2110Container containers. Stopping and removing them."
  docker stop "${existingContainers[@]}" >/dev/null
  docker rm "${existingContainers[@]}" >/dev/null
else
  echo "No existing $GT2110Container containers."
fi

if [ "$action" = "stop" ]; then
  echo "Successfully stopped $GT2110Container containers"
  exit 0
fi

echo "Pulling down most recent image of $imageName"

if ! docker pull $imageName; then
  >&2 echo "ERROR: Unable to pull down the most recent image of $imageName"
fi

echo "Starting up new $imageName Docker Container:"

if ! ipAddress="$(docker-machine ip default 2>/dev/null)"; then
  ipAddress="127.0.0.1"
fi

if command -v docker-machine &> /dev/null; then
  # We're on legacy Docker Toolbox
  # pwd -W doesn't work with Docker Toolbox
  # Extra '/' fixes some mounting issues
  currDir="/$(pwd)"
else
  # pwd -W should correct path incompatibilites on Windows for Docker Desktop users
  currDir="/$(pwd -W 2>/dev/null || pwd)"
fi

docker run -d \
-p $ipAddress:$p1:$p1 \
-p $ipAddress:$p2:$p2 \
-v "$currDir":$hostDir \
--cap-add=SYS_PTRACE \
--security-opt seccomp=unconfined \
"$imageName"

successfulRun=$?

if [ $successfulRun = 0 ]; then
  echo -e "\nSuccessfully launched $imageName Docker container.\nPlease go to http://$ipAddress:$p1/ to access it."
else
  >&2 echo -e "ERROR: Unable to launch $imageName Docker container.\n $?"
fi

