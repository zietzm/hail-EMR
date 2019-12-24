#!/bin/bash

sudo yum install -y git-core g++ cmake git gcc72-c++ lz4 lz4-devel atlas-devel

LATEST_JDK=`ls  /usr/lib/jvm/ | grep "java-1.8.0-openjdk-1.8"`
sudo ln -s /usr/lib/jvm/$LATEST_JDK/include /etc/alternatives/jre/include

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output-document miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source $HOME/miniconda/etc/profile.d/conda.sh

conda env create -f 2.remote/environment.yml
conda activate hail-remote

git clone https://github.com/hail-is/hail.git
cd hail/hail
make clean
make install-on-cluster HAIL_COMPILE_NATIVES=1 SPARK_VERSION=2.4.4
