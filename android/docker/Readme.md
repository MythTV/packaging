Building in Docker
---

Just run `start.sh`.

The Docker image will be created if it doesn't already exist. The image will be about 6.2GB and will contain the build environment including the Android SDK, NDK and build-tools. This gets you to around point 4 of the [build guide](../Readme.md) however you may also need make changes to your local `build.rc` fle for signing etc.

Running `start.sh` with no parameters will start a BASH shell in the image. Otherwise whatever is passed to `start.sh` will be run in the Docker image.

The parent directory of the packaging repository will be mapped into the image so all source files should be available in the same paths as on the host machine.
