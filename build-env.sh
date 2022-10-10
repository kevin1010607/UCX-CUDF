# Create directory
export PROJECT_NAME=public
export SCRATCH=/scratch/${PROJECT_NAME}/NTHU-WY
mkdir -p $SCRATCH

# Download github repo
cd $SCRATCH
git clone https://github.com/hpcac/2022-APAC-HPC-AI.git
cd 2022-APAC-HPC-AI/Communications_Performance_with_UCX

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
