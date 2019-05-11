#!/bin/bash
echo "#############Script for building the casino docker##################"
echo -e "If you want to clean extra files use the -clean option.\n\n"

#checks if the script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#cleans the files which are created during the build/installation
if [[ $1 == clean ]]; then
    echo "Cleaning..."
    rm -rf .tmp
    rm julia-1.0.3-linux-x86_64.tar.gz* 2> /dev/null
    echo "Cleaning done"
    exit 0
fi

#if ctrl+c is used, this removes the unfinished download
exitfn () {
    trap SIGINT
    rm julia-1.0.3-linux-x86_64.tar.gz
    exit
}

#traps the ctrl+c command
trap "exitfn" INT

echo -e "\n########Downloading Julia on host#########\n"

#Not working right now :(, sym links cant be followed via docker COPY https://stackoverflow.com/questions/31881904/docker-follow-symlink-outside-context
#if test -d "/opt/julia-1.0.3/"; then
#	echo "Using your current installtion of Julia 1.0.3 in /opt"
#	mkdir -p .tmp
#	cp -rs /opt/julia-1.0.3/ .tmp/ 2> /dev/null
#elif test ! -d ".tmp/julia-1.0.3"; then
if test ! -d ".tmp/julia-1.0.3"; then
	mkdir -p .tmp
	#download latest julia 1.0.3(lts) version and extract to .tmp
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.3-linux-x86_64.tar.gz
	mv julia-1.0.3-linux-x86_64.tar.gz .tmp
	cd .tmp
	tar -zxf julia-1.0.3-linux-x86_64.tar.gz
	rm julia-1.0.3-linux-x86_64.tar.gz
	cd ..
fi

echo -e "\n########Start Building Docker#########\n"

sudo docker build -t julias_casino .

echo -e "\nFinished"
