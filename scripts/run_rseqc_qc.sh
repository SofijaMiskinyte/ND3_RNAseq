#!/bin/bash
#SBATCH --job-name=ND3_rseqc_qc
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/rseqc_qc_slurm-%j.log

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    $(for sample in SRR1039516 SRR1039512 SRR1039509 SRR1039514; do
        echo "qc/rseqc/${sample}_read_distribution.txt"
        echo "qc/rseqc/${sample}_geneBodyCoverage.geneBodyCoverage.txt"
    done)
