#!/bin/bash
#SBATCH --job-name=ND3_reference
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=02:00:00
#SBATCH --output=logs/reference-%j.log

set -euo pipefail
set -x

cd "$SLURM_SUBMIT_DIR"

mkdir -p ref

wget -c -P ref \
"https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/gencode.v50.primary_assembly.annotation.gtf.gz"

wget -c -P ref \
"https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/gencode.v50.transcripts.fa.gz"

gzip -t ref/gencode.v50.primary_assembly.annotation.gtf.gz
gzip -t ref/gencode.v50.transcripts.fa.gz

echo "Referentiniai failai sekmingai atsisiusti"
