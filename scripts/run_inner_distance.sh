#!/bin/bash
#SBATCH --job-name=ND3_insert_size
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/inner_distance_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake \
    --cores 4 \
    --use-conda \
    --conda-frontend conda \
    --rerun-incomplete \
    --printshellcmds
