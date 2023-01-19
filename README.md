# CircuitSimDocker

A Dockerfile (and supporting files) to build a docker image for CircuitSim.

Tested on AMD64 linux and ARM64 MacOS (base M1).

## Usage

### Download the Launch Script

Open a terminal in your project directory (class folder) and type in the following command:

```bash
curl https://raw.githubusercontent.com/avannus/CircuitSimDocker/main/CircuitSimDocker.sh --output CircuitSimDocker.sh && chmod +x CircuitSimDocker.sh
```

### Run the Script

To run, ensure Docker is running, open a terminal to the directory where the script now resides, and run the script:

```bash
./CircuitSimDocker.sh
```

The URL that the container is running should be printed out at the bottom.

* `CMD + Double Click` terminal links on MacOS

### Using the Container

You can load and save files by clicking `Home` on the left of file selection and choosing `host` (`/config/host/`). This will be whichever directory you ran the script from.

Select "Scaling Mode: Remote Resizing" from the left to scale based on your browser.

Double click the CircuitSim window to maximize.

## Misc Info

The images are hosted at <https://hub.docker.com/r/avannus/circuit-sim>

The script currently closes GTCS2110 containers to ensure performance and possibly compatibility.

<!-- `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes && docker buildx build --platform linux/amd64,linux/arm64 -t avannus/circuit-sim:stable --push .` -->
