Building in Docker
---

At its simplest, just run `start.sh`.  Optionally, you can specify which SDK to use with the `--sdk` option.

For example:
```
./start.sh --sdk 28
```
By default, SDK 21 will be used.

A Docker image will be created if it doesn't already exist. The image will be about 5.5GB and will contain the build environment including the Android SDK, NDK and build-tools. This gets you to around point 4 of the [build guide](../Readme.md) however you may also need make changes to your local `build.rc` fle for signing etc.

Note that a separate Docker image will be created (if necessary) for each SDK version.  This is to ensure a clean environment and to make it easier to catch any implicit dependencies that could be missed if multiple vesions were installed in the same image.

The installed Android packages are shown when the image starts:
```
--------------------------------------------
Installed Android packages:
Build tools: 28.0.3
NDK: 21.0.6113669
SDK: 21
--------------------------------------------
```
Running `start.sh` with no parameters will start a BASH shell in the image. Otherwise whatever is passed to `start.sh` will be run in the Docker image.

The parent directory of the packaging repository will be mapped into the image so all source files should be available in the same paths as on the host machine.
