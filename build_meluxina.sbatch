# build.sbatch
#!/bin/bash
#SBATCH --job-name=torchcomms_build
#SBATCH --output=logs/build_%j.log
#SBATCH --error=logs/build_%j.err
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=1
#SBATCH --time=04:00:00

set -euo pipefail

module load env/release/2025.1
module load Miniconda3/25.7.0-2
module load GCC/14.2.0
module load CUDA/12.8.0
module load CMake/3.31.3-GCCcore-14.2.0
module load Ninja/1.12.1-GCCcore-14.2.0

source activate torchcomms

export CUDA_HOME="${CUDA_ROOT:-/usr/local/cuda}"
export NVCC_ARCH="a100"
export BUILDDIR="$HOME/torchcomms/build/ncclx"

REPO_DIR="$HOME/torchcomms"
cd "$REPO_DIR"

echo "=== Building NCCLX (full from source, system libs) ==="
USE_SYSTEM_LIBS=1 ./build_ncclx.sh

echo "=== Installing torchcomms ==="
USE_NCCL=ON \
USE_NCCLX=ON \
USE_GLOO=ON \
USE_TRANSPORT=ON \
USE_SYSTEM_LIBS=1 \
pip install --no-build-isolation -v .

echo "=== Done ==="
python -c "import torchcomms; print('import OK')"
