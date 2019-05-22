FROM debian:stretch-slim

MAINTAINER ENOWARS Team (dar.blue)

#install busybox and python3
RUN apt update
RUN apt install wget -y
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install pwgen -y
RUN apt install nmap -y

WORKDIR /opt
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.3-linux-x86_64.tar.gz
RUN tar -zxf julia-1.0.3-linux-x86_64.tar.gz
RUN rm julia-1.0.3-linux-x86_64.tar.gz

#copy julia on docker image and link
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia


#copy our pkgInstallation script, install busybox for it and run it
WORKDIR /app
COPY casino casino
WORKDIR casino

#install libs
RUN julia pkgInstallation.jl
RUN pip3 install -r requirements.txt

#generate the aes.seed randomly
RUN pwgen -s -y -1 64 > assets/aes.seed

#TODO: start the service correctly
CMD ncat -k -e "./start.sh" -l 6969 
