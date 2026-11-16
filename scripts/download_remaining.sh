#!/bin/bash
#SBATCH --job-name=ND3_remaining
#SBATCH --cpus-per-task=6
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/remaining-%j.log

set -euo pipefail
set -x

cd "$SLURM_SUBMIT_DIR"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate sra_env

mkdir -p raw tmp

while IFS= read -r sample || [[ -n "$sample" ]]; do

    [[ -z "$sample" ]] && continue

    if [[ -s "raw/${sample}_1.fastq.gz" &&
          -s "raw/${sample}_2.fastq.gz" ]]; then
        echo "$sample jau atsisiustas, praleidziame"
        continue
    fi

    echo "Apdorojamas meginys: $sample"

    prefetch "$sample" --output-directory raw

    fasterq-dump "raw/${sample}/${sample}.sra" \
        --split-files \
        --threads "$SLURM_CPUS_PER_TASK" \
        --temp tmp \
        --outdir raw

    gzip "raw/${sample}_1.fastq" "raw/${sample}_2.fastq"

done < samples_ID.txt

echo "Visi meginiai apdoroti"
