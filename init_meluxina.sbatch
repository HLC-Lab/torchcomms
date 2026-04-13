#!/bin/bash
#SBATCH --job-name=torchcomms_init
#SBATCH --output=logs/init_%j.log
#SBATCH --error=logs/init_%j.err
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

set -euo pipefail

module load env/release/2025.1
module load Miniconda3/25.7.0-2
module load GCC/14.2.0
module load CUDA/12.8.0
module load CMake/3.31.3-GCCcore-14.2.0
module load Ninja/1.12.1-GCCcore-14.2.0

CONDA_ENV_NAME="torchcomms"

if conda env list | grep -q "^$CONDA_ENV_NAME "; then
    echo "Env $CONDA_ENV_NAME already exists, skipping creation"
else
    conda create -y -n "$CONDA_ENV_NAME" python=3.10
fi

source activate "$CONDA_ENV_NAME"

# PyTorch from source would go here — for now install stable wheel matching CUDA 12.8
pip install torch --index-url https://download.pytorch.org/whl/cu128

# Native deps needed by NCCLX build
conda install -y \
	cmake ninja jemalloc gtest boost double-conversion libevent \
	conda-forge::libsodium libunwind snappy conda-forge::fast_float \
	conda-forge::libdwarf gflags "glog==0.4.0" xxhash zstd \
	conda-forge::zlib conda-forge::libopenssl-static fmt

pip install setuptools packaging pyyaml
pip install pytest numpy psutil lintrunner parameterized pydot

echo "Init done."
