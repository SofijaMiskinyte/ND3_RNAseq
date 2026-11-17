#!/bin/bash
#SBATCH --job-name=ND3_fastqc_trimmed
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/fastqc_trimmed_slurm-%j.log

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    qc/trimmed/SRR1039516_1_paired_fastqc.html \
    qc/trimmed/SRR1039516_2_paired_fastqc.html \
    qc/trimmed/SRR1039512_1_paired_fastqc.html \
    qc/trimmed/SRR1039512_2_paired_fastqc.html \
    qc/trimmed/SRR1039509_1_paired_fastqc.html \
    qc/trimmed/SRR1039509_2_paired_fastqc.html \
    qc/trimmed/SRR1039514_1_paired_fastqc.html \
    qc/trimmed/SRR1039514_2_paired_fastqc.html
