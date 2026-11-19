# RNA-seq Analysis Using Snakemake

## 1. Project Overview

This project presents a reproducible RNA-seq analysis workflow implemented using Snakemake.

The analysis utilizes four paired-end RNA-seq samples derived from human airway smooth muscle cells under three experimental conditions: control (untreated), treatment with dexamethasone, and treatment with albuterol.

The primary objectives are to assess sequencing quality, perform initial processing of the sequencing data, align the sequences to the human reference genome, quantify gene and transcript expression levels, and evaluate the quality and consistency of the RNA-seq data.

The workflow employs the following tools: FastQC, Trimmomatic, HISAT2, featureCounts, Kallisto, RSeQC, deepTools, and MultiQC.

## 2. Samples

Four paired-end RNA-seq samples were used: SRR1039516 and SRR1039512 (Control), SRR1039509 (Dexamethasone), and SRR1039514 (Albuterol).

The dataset consists of two control samples and one sample for each treatment. The analysis focuses primarily on RNA-seq quality and the quantification of gene expression.

## 3. Reference Genome

The human reference genome GRCh38 and the GENCODE v50 annotation were used for RNA sequencing (RNA-seq) analysis.

The reference genome was used to align sequence fragments (reads) using HISAT2, while the annotation was used to quantify genes using featureCounts.

## 4. Workflow

The RNA-seq analysis was performed using Snakemake.

- FastQC – read quality check
- Trimmomatic – read trimming
- HISAT2 – read alignment
- featureCounts – gene counting
- Kallisto – transcript quantification
- RSeQC – RNA-seq quality analysis
- deepTools – sample comparison and PCA
- MultiQC – summary of results

## 5. How to Run

Run the workflow using:
```bash
snakemake --cores 4 --use-conda
```
## 6. Results

The analysis produced:
- FastQC and MultiQC quality reports
- HISAT2 aligned BAM files
- Gene counts from featureCounts
- Transcript quantification from Kallisto
- RNA-seq quality results from RSeQC
- Sample correlation and PCA plots from deepTools

Mapping rates were approximately 98–99%, and featureCounts assigned approximately 78–80% of reads to genes.

Results are saved in the `results/`, `qc/`, and `counts/` directories.