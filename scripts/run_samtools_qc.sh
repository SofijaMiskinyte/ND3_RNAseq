#!/bin/bash
#SBATCH --job-name=ND3_samtools_qc
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/samtools_qc_slurm-%j.log

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$SLURM_CPUS_PER_TASK" \
    --use-conda \
    --conda-frontend conda \
    --printshellcmds \
    $(for sample in SRR1039516 SRR1039512 SRR1039509 SRR1039514; do
        echo "mapped/${sample}.sorted.bam.bai"
        echo "qc/alignment/${sample}_flagstat.txt"
        echo "qc/alignment/${sample}_stats.txt"
    done)
