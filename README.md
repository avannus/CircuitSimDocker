# CircuitSimDocker

A lightweight, browser-accessed Docker image for [ra4king's CircuitSim](https://github.com/ra4king/CircuitSim).

See images for each available release [here](https://hub.docker.com/repository/docker/avannus/circuit-sim/general).

Tested on Linux (x86_64/AMD64) and an M1 MacBook Air (ARM64).

## Usage

### Download the Launch Script

Open a terminal in your project directory (class folder) and type in the following command:

```bash
curl https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/CircuitSimDocker.sh --output CircuitSim.sh && chmod +x CircuitSim.sh
```

### Run the Script

To run, ensure Docker is running, open a terminal to the directory where the script now resides, and run the script:

```bash
./CircuitSim.sh
```

The URL that the container is running should be printed out at the bottom.

### Using the Container

You can load and save files by clicking `Home` on the left of file selection and choosing `host` (`/config/host/`). This directory will be whichever directory you ran the script from on your machine.

Select "Scaling Mode: Remote Resizing" from the left to scale based on your browser.

Double click the CircuitSim window to maximize.

## Misc Info

There is now an executable script wherever you ran the first command. Move it to where you would like to have file access from your machine.

You can use docker-desktop or VSCode w/ extensions to manage containers

`CMD + Double Click` terminal links on MacOS

The Docker images are hosted at <https://hub.docker.com/r/avannus/circuit-sim>

Show script help with:

```bash
./CircuitSim.sh -h
```
