

DOCKER_USER="avannus"
DOCKER_REPO="$DOCKER_USER/circuit-sim"
ARCH="linux/amd64,linux/arm64"
DOWNLOAD_SOURCE="https://www.roiatalla.com/public/CircuitSim/Linux"
DOCKER_REPO_LINK="https://hub.docker.com/v2/repositories/$DOCKER_REPO"
CircuitSimLinks=./CircuitSimLinks.txt # File to store links to CircuitSim

links=$(cat $CircuitSimLinks)

function fch () {
  prevName
}

for link in $links; do
  name=${link##*/}
  imageName="$DOCKER_REPO:$name"
  minor=$(echo $name | sed 's/.[^.]*$//')
  major=$(echo $minor | sed 's/.[^.]*$//')

  if [ "$minor" != "$prevMinor" ]; then
    echo "$minor"
  fi
  if [ "$major" != "$prevMajor" ]; then
    echo "$major"
  fi
  echo
  echo $name

  # echo $major
  # echo $prevMajor
  # echo $minor
  # echo $prevMinor

  prevName=$name
  prevLink=$link
  prevMajor=$major
  prevMinor=$minor
done

echo "$(echo $prevName | sed 's/.[^.]*$//')"
echo "$(echo $prevName | sed 's/.[^.]*$//' | sed 's/.[^.]*$//')"

