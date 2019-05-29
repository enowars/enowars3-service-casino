FROM debian:stretch-slim

MAINTAINER ENOWARS Team (dar.blue)

#install busybox and python3
RUN apt-get update
RUN apt-get install wget -y
RUN apt-get install python3 -y
RUN apt-get install python3-pip -y
RUN apt-get install pwgen -y
RUN apt-get install nmap -y

WORKDIR /opt
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.3-linux-x86_64.tar.gz
RUN tar -zxf julia-1.0.3-linux-x86_64.tar.gz
RUN rm julia-1.0.3-linux-x86_64.tar.gz

#copy julia on docker image and link
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia


#copy our pkgInstallation script, install busybox for it and run it
WORKDIR /app

COPY casino/pkgInstallation.jl .
COPY casino/requirements.txt .

#install libs
RUN julia pkgInstallation.jl
RUN pip3 install -r requirements.txt

COPY casino casino
WORKDIR casino

RUN chmod u+x start.sh
RUN chmod u+x cryptomat/rsa.py
RUN chmod u+x cryptomat/rsa_sig.py

#generate the aes.seed randomly
RUN pwgen -s -y -1 64 > assets/aes.seed

#TODO: start the service correctly
CMD julia casino.jl
