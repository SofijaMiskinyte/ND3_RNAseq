#!/bin/bash
#SBATCH --job-name=ND3_hisat2_index
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/hisat2_index-%j.log

set -euo pipefail
set -x

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate bioinfo

mkdir -p ref/hisat2_index

if [[ ! -s ref/GRCh38.primary_assembly.genome.fa ]]; then
    gzip -dc ref/GRCh38.primary_assembly.genome.fa.gz \
        > ref/GRCh38.primary_assembly.genome.fa
fi

hisat2-build -p "$SLURM_CPUS_PER_TASK" \
    ref/GRCh38.primary_assembly.genome.fa \
    ref/hisat2_index/grch38

echo "HISAT2 indeksas sukurtas sekmingai"
