#!/bin/bash
#SBATCH --job-name=ND3_hisat2
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/hisat2_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    mapped/SRR1039516.sorted.bam \
    mapped/SRR1039512.sorted.bam \
    mapped/SRR1039509.sorted.bam \
    mapped/SRR1039514.sorted.bam
