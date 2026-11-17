#!/bin/bash
#SBATCH --job-name=ND3_rseqc
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/rseqc_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    qc/rseqc/SRR1039516_infer_experiment.txt \
    qc/rseqc/SRR1039512_infer_experiment.txt \
    qc/rseqc/SRR1039509_infer_experiment.txt \
    qc/rseqc/SRR1039514_infer_experiment.txt
