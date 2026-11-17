#!/bin/bash
#SBATCH --job-name=ND3_fastqc
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/fastqc_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds
