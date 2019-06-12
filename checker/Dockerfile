FROM python
LABEL maintainer="ENOFLAG <mail@enoflag.de>"

# Install python3 and uswgi
RUN apt-get update
RUN apt-get install -y nginx git
RUN apt-get install wget -y

#install julia
WORKDIR /opt
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.3-linux-x86_64.tar.gz
RUN tar -zxf julia-1.0.3-linux-x86_64.tar.gz
RUN rm julia-1.0.3-linux-x86_64.tar.gz

#copy julia on docker image and link
RUN ln -s /opt/julia-1.0.3/bin/julia /usr/bin/julia


# use python3
RUN pip3 install uwsgi

# copy our files in.
WORKDIR /checker
COPY ./requirements.txt /checker/requirements.txt
RUN pip3 install -r requirements.txt
COPY pkgInstallation.jl .
RUN julia pkgInstallation.jl 
COPY . .


#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT [ "uwsgi", "--uid", "uwsgi", \
               "--socket", "0.0.0.0:3031", \
               "--protocol", "uwsgi", \
               "--ini", "/checker/uwsgi.ini" ]
