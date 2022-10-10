#!/bin/bash

# !!!!! All files must in the same directory on Gadi !!!!!

# Record the path of our files
export BUILD_PATH=$PWD

# Create directory
export PROJECT_NAME=public
export SCRATCH=/scratch/${PROJECT_NAME}/NTHU-WY
mkdir -p $SCRATCH

# Download github repo and replace some files with our files
cd $SCRATCH
git clone https://github.com/hpcac/2022-APAC-HPC-AI.git
cd 2022-APAC-HPC-AI/Communications_Performance_with_UCX
rm -f build-env.sh cluster.cfg cudf-merge.py launch.sh run-cluster.sh
cp ${BUILD_PATH}/build-env.sh ./build-env.sh
cp ${BUILD_PATH}/cluster.cfg ./cluster.cfg
cp ${BUILD_PATH}/cudf-merge.py ./cudf-merge.py
cp ${BUILD_PATH}/launch.sh ./launch.sh
cp ${BUILD_PATH}/run-cluster.sh ./run-cluster.sh
cp ${BUILD_PATH}/ucx-env.cfg ./ucx-env.cfg

# Install miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${SCRATCH}/miniconda.sh
bash ${SCRATCH}/miniconda.sh -b -p ${SCRATCH}/miniconda

# Activate miniconda
source ${SCRATCH}/miniconda/etc/profile.d/conda.sh
conda init
source ~/.bashrc

# Install mamba
conda activate base
conda install -y -c conda-forge mamba
mamba init
source ~/.bashrc

# Create and activate Dask conda environment
mamba env create -n ucx -f ./ucx-env.yml
mamba activate ucx

# Load CUDA module
module load cuda/11.4.1

# Install UCX From Source
mkdir -p ${SCRATCH}/src
cd ${SCRATCH}/src
git clone https://github.com/openucx/ucx.git
cd ucx
git checkout v1.12.1
./autogen.sh
mkdir build && cd build
../contrib/configure-release \
    --prefix=$CONDA_PREFIX \
    --with-cuda=$CUDA_HOME \
    --enable-mt
make -j8
make install
