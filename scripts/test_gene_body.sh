#!/bin/bash
#SBATCH --job-name=ND3_gene_test
#SBATCH --cpus-per-task=1
#SBATCH --mem=12G
#SBATCH --time=00:30:00
#SBATCH --output=logs/gene_test_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 1 \
    --use-conda \
    --conda-frontend conda \
    --rerun-incomplete \
    --printshellcmds \
    qc/rseqc/SRR1039509_geneBodyCoverage.geneBodyCoverage.txt
