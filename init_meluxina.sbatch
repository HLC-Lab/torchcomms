#!/bin/bash -l
#SBATCH --job-name=torchcomms_init
#SBATCH --account=p201236
#SBATCH --output=logs/init_%j.log
#SBATCH --error=logs/init_%j.err
#SBATCH --qos=default
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=1
#SBATCH --time=00:30:00

set -euo pipefail

module load env/release/2025.1
module load Miniconda3/25.7.0-2
module load GCC/14.2.0
module load CUDA/12.8.0

CONDA_ENV_PATH="/project/home/p201236/conda_envs/torchcomms"

mkdir -p "/project/home/p201236/conda_envs"

# Accept TOS
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

if [ -d "$CONDA_ENV_PATH" ]; then
    echo "Env at $CONDA_ENV_PATH already exists, skipping creation"
else
    # We use -p (prefix) to point to the project partition
    conda create -y -p "$CONDA_ENV_PATH" python=3.10
fi

source activate "$CONDA_ENV_PATH"

echo "=== Installing Native Dependencies ==="
conda install -y -p "$CONDA_ENV_PATH" \
    jemalloc gtest boost double-conversion libevent \
    conda-forge::libsodium libunwind snappy conda-forge::fast_float \
    conda-forge::libdwarf gflags "glog==0.4.0" xxhash zstd \
    conda-forge::zlib conda-forge::libopenssl-static fmt

echo "=== Installing Python Dependencies ==="
# Set pip cache to project space so it doesn't fill $HOME/root
export PIP_CACHE_DIR="/project/home/p201236/.cache/pip"
mkdir -p "$PIP_CACHE_DIR"

pip install torch --index-url https://download.pytorch.org/whl/cu128
pip install setuptools packaging pyyaml
pip install pytest numpy psutil lintrunner parameterized pydot

echo "Init done. Env location: $CONDA_ENV_PATH"
