#!/bin/bash
#SBATCH --job-name=ND3_featurecounts
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=logs/featurecounts_slurm-%j.log

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    counts/SRR1039516_counts.txt \
    counts/SRR1039512_counts.txt \
    counts/SRR1039509_counts.txt \
    counts/SRR1039514_counts.txt
