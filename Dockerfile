FROM debian:stretch-slim

MAINTAINER dar.blue

#copy julia on docker image and link
COPY .tmp/julia-1.0.3 /opt/julia-1.0.3
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia

#copy our pkgInstallation script, install busybox for it and run it
COPY pkgInstallation.jl /tmp/
RUN apt update && apt install busybox -y
RUN julia /tmp/pkgInstallation.jl
