FROM debian:stretch-slim

MAINTAINER dar.blue
COPY .tmp/julia-1.0.3 /opt/julia-1.0.3
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia

