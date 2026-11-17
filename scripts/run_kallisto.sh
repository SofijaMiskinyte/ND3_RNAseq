#!/bin/bash
#SBATCH --job-name=ND3_kallisto
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=06:00:00
#SBATCH --output=logs/kallisto_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    results/kallisto/SRR1039516/abundance.tsv \
    results/kallisto/SRR1039512/abundance.tsv \
    results/kallisto/SRR1039509/abundance.tsv \
    results/kallisto/SRR1039514/abundance.tsv
