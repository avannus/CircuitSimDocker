# CircuitSimDocker

A Dockerfile (and supporting files) to build a Docker image for CircuitSim.

Tested on Linux (x86_64/AMD64) and an M1 MacBook Air (ARM64).

## Usage

### Download the Launch Script

Open a terminal in your project directory (class folder) and type in the following command:

```bash
curl https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/CircuitSimDocker.sh --output CircuitSimDocker.sh && chmod +x CircuitSimDocker.sh
```

There is now an executable script wherever you ran the command above. Move it to where you would like to have file access from your machine.

The script should always work but won't auto-update #TODO

### Run the Script

To run, ensure Docker is running, open a terminal to the directory where the script now resides, and run the script:

```bash
./CircuitSimDocker.sh
```

The URL that the container is running should be printed out at the bottom.

* `CMD + Double Click` terminal links on MacOS

### Using the Container

You can load and save files by clicking `Home` on the left of file selection and choosing `host` (`/config/host/`). This directory will be whichever directory you ran the script from on your machine.

Select "Scaling Mode: Remote Resizing" from the left to scale based on your browser.

Double click the CircuitSim window to maximize.

## Misc Info

The images are hosted at <https://hub.docker.com/r/avannus/circuit-sim>

The script currently closes GTCS2110 containers to ensure performance and possibly compatibility.

Show script help with:

```bash
./CircuitSimDocker.sh -h
```
