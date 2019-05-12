# Casino

## Installation

You need to have *docker* installed.

Something like `apt-get install docker.io` should work. Tested with the latest debian rep verison (Docker version 18.09.2, build 6247962).

You also need *docker-compose*.
---

The service itself need some packages.
* Install julia-1.0.3 (LTS)
* Run `julia pkgInstallation.jl`
* Also install python package via `pip3 install -r requirements.txt` (virtualenv recommended)

---
Build and run the container with `sudo docker-compose up`.

Then connect to the container via `nc localhost 6969`.

