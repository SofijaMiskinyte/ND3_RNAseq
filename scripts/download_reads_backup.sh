#!/bin/bash
#SBATCH --job-name=ND3_download
#SBATCH --cpus-per-task=6
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/download-%j.log

set -euo pipefail
set -x

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate sra_env

mkdir -p raw tmp

prefetch SRR1039516 --output-directory raw

fasterq-dump raw/SRR1039516/SRR1039516.sra \
    --split-files \
    --threads 6 \
    --temp tmp \
    --outdir raw

gzip raw/SRR1039516_*.fastq
