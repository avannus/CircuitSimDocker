#!/bin/bash

release="stable"
imageBaseName="avannus/circuit-sim"
imageName="${imageBaseName}:${release}"
hostDir="/config/host/"
p1=5800
p2=5900
SCRIPT_LINK="https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/CircuitSimDocker.sh"
SAVE_AS=$(basename "$0")
SAVE_AS_NEW="$SAVE_AS.new"

function cleanup {
  echo -e "Cleaning up"
  rm -v $SAVE_AS_NEW
  echo -e "Done Cleaning"
}
trap cleanup EXIT

### Check for updates ###
if ! command -v curl &> /dev/null
then
    echo "curl could not be found, skipping script update check. Download curl to enable this feature. Docker will still be updated if needed."
else
  echo -e "Checking for updates"
  curl -LJo $SAVE_AS_NEW $SCRIPT_LINK
  diff=$(diff $SAVE_AS $SAVE_AS_NEW)
  if [ ! -z "$diff" ]; then
    echo -e "\nUpdate found! See the changes below:\n"
    diff $SAVE_AS $SAVE_AS_NEW
    echo -e "\n"
    read -p "There is a new version of the script (diff above), would you like to update it before running? (you can view the new file at $(pwd)/$SAVE_AS_NEW) [y/N] " -n 1 -r
    echo -e "\n"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo -e "Updating Script"
        mv $SAVE_AS $SAVE_AS.bak
        mv $SAVE_AS_NEW $SAVE_AS
        chmod +x $SAVE_AS
        echo -e "Backed up current script as $SAVE_AS.bak, updated current script, running new version now:\n\n"
        ./$SAVE_AS $@
        exit 0
    else
        echo -e "Not updating script"
    fi
  else 
    echo -e "No update found"
  fi
fi

define() { IFS=$'\n' read -r -d '' "${1}" || true; }

description="Update and Run a $imageBaseName container"

usage_text=""
define usage_text <<'EOF'
USAGE:
    ./$0 [start|stop|-h|--testing|--tag]

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
    --testing
            Pull and run the testing version of the container.
    --tag
            Pull and run the specified version of the container.
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
    --testing)
      action="start"
      release="testing"
      imageName="${imageBaseName}:${release}"
      ;;
    --tag)
      >&2 echo "Error: Please specify a tag to use"
      >&2 echo ""
      print_usage
      exit 1
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
elif [ $# -eq 2 ]; then
  case "$1" in
    --tag)
      action="start"
      release="$2"
      imageName="${imageBaseName}:${release}"
      ;;
    *)
      >&2 echo "Error: Incorrect usage"
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
if [ "${#existingContainers[@]}" -ne 0 ]; then
  echo "Found $imageBaseName containers. Stopping and removing them."
  docker stop "${existingContainers[@]}" >/dev/null
  docker rm "${existingContainers[@]}" >/dev/null
else
  echo "No existing $imageBaseName containers."
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

