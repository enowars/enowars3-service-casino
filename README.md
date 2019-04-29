# Casino

## Installation

You need to have docker installed.
Something like `apt-get install docker.io` should work. Tested with the latest debian rep verison (Docker version 18.09.2, build 6247962).

Create the image via the `build.sh` script.

The *Dockerfile.easy* can also be used for build but is **WIP**. The difference is that it takes the official julian docker image but is a little bit larger than the build-script variant.

---

The service itself need some packages.
Therefore run at first `julia pkgInstallation.jl`

---

TODO: configure  
