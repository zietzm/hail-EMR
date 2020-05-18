#!/bin/bash

source $HOME/miniconda/etc/profile.d/conda.sh
conda activate hail-remote

git clone https://github.com/hail-is/hail.git
# Note: this would be where to checkout a specific tag
cd hail/hail
make clean
make install-on-cluster HAIL_COMPILE_NATIVES=1 SPARK_VERSION=2.4.4
