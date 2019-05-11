FROM debian:stretch-slim

MAINTAINER ENOWARS Team (dar.blue)


RUN cd /tmp/
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.3-linux-x86_64.tar.gz
RUN tar -zxf julia-1.0.3-linux-x86_64.tar.gz
RUN rm julia-1.0.3-linux-x86_64.tar.gz

#copy julia on docker image and link
RUN cp -r /tmp/julia-1.0.3 /opt/julia-1.0.3
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia

#install busybox and python3
RUN apt update && apt install busybox python3 python3-pip -y

#copy our pkgInstallation script, install busybox for it and run it
WORKDIR /app
COPY  casino .
WORKDIR casino

#clean up everythin what is not intended for the team
RUN rm assets/aes.seed

#install libs
RUN julia /tmp/pkgInstallation.jl
RUN pip3 install -r requierement.txt

#generate the aes.seed randomly
RUN pwgen -s -y -1 64 > assets/aes.seed

#TODO: start the service correctly
