#!/bin/bash
#SBATCH --job-name=ND3_remaining
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=08:00:00
#SBATCH --output=logs/remaining-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake \
    --cores 4 \
    --use-conda \
    --conda-frontend conda \
    --rerun-incomplete \
    --printshellcmds \
    --keep-going
