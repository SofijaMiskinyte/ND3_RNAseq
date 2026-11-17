#!/bin/bash
#SBATCH --job-name=ND3_trimming
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=06:00:00
#SBATCH --output=logs/trimming_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    trimmed/SRR1039516_1_paired.fastq.gz \
    trimmed/SRR1039512_1_paired.fastq.gz \
    trimmed/SRR1039509_1_paired.fastq.gz \
    trimmed/SRR1039514_1_paired.fastq.gz
