# Updating the Docker

run `./testing.sh` to make tests, run `CircuitSimDocker.sh -t` to run the most recent test.

## Push to stable

```bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes && docker buildx build --platform linux/amd64,linux/arm64 -t avannus/circuit-sim:stable --push .
```
