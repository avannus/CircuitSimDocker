set -e

function cleanup {
  echo -e "\n-----Cleaning up-----\n"
  rm -v .runCircuitSimDocker.sh.new
  echo -e "\n-----Done Cleaning-----\n"
}
trap cleanup EXIT


if [ ! -f .runCircuitSimDocker.sh ]; then
  echo "Downloading run script..."
  curl https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/.runCircuitSimDocker.sh -o .runCircuitSimDocker.sh
else
  echo "Checking for script updates. Bypass this check by running `./.runCircuitSimDocker.sh` directly."

  curl https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/.runCircuitSimDocker.sh -o .runCircuitSimDocker.sh.new

  diff=$(diff .runCircuitSimDocker.sh .runCircuitSimDocker.sh.new)
  if [ ! -z "$diff" ]; then
    echo -e "Update! See the changes below:"
    diff .runCircuitSimDocker.sh .runCircuitSimDocker.sh.new
    read -p "There is a new version of the run script (diff above), would you like to update it before running? [y/N] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        mv .csrun.sh.new .csrun.sh
    fi
  fi
fi

./.runCircuitSimDocker.sh $@
