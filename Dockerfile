FROM alpine

MAINTAINER dar.blue
RUN apk add --no-cache bash
COPY .tmp/julia-1.0.3 /opt/
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia

