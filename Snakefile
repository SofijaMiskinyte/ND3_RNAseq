configfile: "config.yaml"

SAMPLES = config["samples"]

rule all:
    input:
        expand("qc/raw/{sample}_{mate}_fastqc.html",
               sample=SAMPLES, mate=[1, 2]),

        expand("qc/trimmed/{sample}_{mate}_paired_fastqc.html",
               sample=SAMPLES, mate=[1, 2]),

        expand("mapped/{sample}.sorted.bam.bai", sample=SAMPLES),

        expand("counts/{sample}_counts.txt", sample=SAMPLES),

        expand("results/kallisto/{sample}/abundance.tsv", sample=SAMPLES),

        expand("qc/alignment/{sample}_flagstat.txt", sample=SAMPLES),
        expand("qc/alignment/{sample}_stats.txt", sample=SAMPLES),

        expand("qc/rseqc/{sample}_infer_experiment.txt", sample=SAMPLES),
        expand("qc/rseqc/{sample}_read_distribution.txt", sample=SAMPLES),
        expand("qc/rseqc/{sample}_geneBodyCoverage.geneBodyCoverage.txt",
               sample=SAMPLES),
        expand("qc/rseqc/{sample}_inner_distance.inner_distance.txt",
               sample=SAMPLES),

        "results/multiqc/multiqc_report.html",
        "qc/deeptools/multibam_summary.npz",
        "results/deeptools/correlation.png",
        "results/deeptools/correlation_matrix.tsv",
        "results/deeptools/pca.png",
        "results/deeptools/pca_data.tsv"

rule fastqc_raw:
    input:
        "raw/{sample}_{mate}.fastq.gz"
    output:
        html="qc/raw/{sample}_{mate}_fastqc.html",
        zip="qc/raw/{sample}_{mate}_fastqc.zip"
    threads: config["threads"]["fastqc"]
    conda:
        "envs/fastqc.yaml"
    log:
        "logs/fastqc_{sample}_{mate}.log"
    shell:
        """
        mkdir -p qc/raw
        fastqc --threads {threads} --outdir qc/raw {input} > {log} 2>&1
        """
rule trim_reads:
    input:
        r1="raw/{sample}_1.fastq.gz",
        r2="raw/{sample}_2.fastq.gz"
    output:
        r1="trimmed/{sample}_1_paired.fastq.gz",
        r1_unpaired="trimmed/{sample}_1_unpaired.fastq.gz",
        r2="trimmed/{sample}_2_paired.fastq.gz",
        r2_unpaired="trimmed/{sample}_2_unpaired.fastq.gz"
    threads: config["threads"]["trimming"]
    params:
        adapters=config["adapters"]
    conda:
        "envs/trimmomatic.yaml"
    log:
        "logs/trimming_{sample}.log"
    shell:
        """
        trimmomatic PE -threads {threads} \
            {input.r1} {input.r2} \
            {output.r1} {output.r1_unpaired} \
            {output.r2} {output.r2_unpaired} \
            ILLUMINACLIP:{params.adapters}:2:30:10 \
            LEADING:3 TRAILING:3 \
            SLIDINGWINDOW:4:20 MINLEN:36 \
            > {log} 2>&1
        """  
rule align_reads:
    input:
        r1="trimmed/{sample}_1_paired.fastq.gz",
        r2="trimmed/{sample}_2_paired.fastq.gz",
        index=expand(
            "ref/hisat2_index/grch38.{i}.ht2",
            i=range(1, 9)
        )
    output:
        bam="mapped/{sample}.sorted.bam"
    threads: config["threads"]["alignment"]
    conda:
        "envs/hisat2.yaml"
    log:
        "logs/hisat2_{sample}.log"
    shell:
        """
        set -euo pipefail
        hisat2 -p 6 \
            -x {config[reference][hisat2_index]} \
            -1 {input.r1} \
            -2 {input.r2} \
            2> {log} | \
        samtools sort -@ 2 -o {output.bam} -
        """ 
rule featurecounts:
    input:
        bam="mapped/{sample}.sorted.bam",
        annotation=config["reference"]["annotation"]
    output:
        counts="counts/{sample}_counts.txt"
    threads: 2
    conda:
        "envs/featurecounts.yaml"
    log:
        "logs/featurecounts_{sample}.log"
    shell:
        """
        featureCounts -T {threads} \
            -p --countReadPairs \
            -s 0 \
            -t exon -g gene_id \
            -a {input.annotation} \
            -o {output.counts} \
            {input.bam} > {log} 2>&1
        """   
rule kallisto_index:
    input:
        transcriptome=config["reference"]["transcriptome"]
    output:
        index="ref/kallisto_index/transcripts.idx"
    threads: 2
    conda:
        "envs/kallisto.yaml"
    log:
        "logs/kallisto_index.log"
    shell:
        """
        mkdir -p ref/kallisto_index
        kallisto index -t {threads} -i {output.index} {input.transcriptome} > {log} 2>&1
        """  
rule kallisto_quant:
    input:
        index="ref/kallisto_index/transcripts.idx",
        r1="trimmed/{sample}_1_paired.fastq.gz",
        r2="trimmed/{sample}_2_paired.fastq.gz"
    output:
        abundance="results/kallisto/{sample}/abundance.tsv",
        run_info="results/kallisto/{sample}/run_info.json"
    threads: 4
    conda:
        "envs/kallisto.yaml"
    log:
        "logs/kallisto_{sample}.log"
    params:
        outdir="results/kallisto/{sample}"
    shell:
        """
        mkdir -p {params.outdir}
        kallisto quant \
            -i {input.index} \
            -o {params.outdir} \
            -t {threads} \
            {input.r1} {input.r2} \
            > {log} 2>&1
        """
rule fastqc_trimmed:
    input:
        "trimmed/{sample}_{mate}_paired.fastq.gz"
    output:
        html="qc/trimmed/{sample}_{mate}_paired_fastqc.html",
        zip="qc/trimmed/{sample}_{mate}_paired_fastqc.zip"
    threads: config["threads"]["fastqc"]
    conda:
        "envs/fastqc.yaml"
    log:
        "logs/fastqc_trimmed_{sample}_{mate}.log"
    shell:
        """
        mkdir -p qc/trimmed
        fastqc --threads {threads} \
            --outdir qc/trimmed \
            {input} > {log} 2>&1
        """
rule index_bam:
    input:
        bam="mapped/{sample}.sorted.bam"
    output:
        bai="mapped/{sample}.sorted.bam.bai"
    threads: 2
    conda:
        "envs/hisat2.yaml"
    log:
        "logs/samtools_index_{sample}.log"
    shell:
        """
        samtools index -@ {threads} {input.bam} {output.bai} > {log} 2>&1
        """
rule multiqc:
    input:
        raw=expand("qc/raw/{sample}_{mate}_fastqc.zip",
                   sample=SAMPLES, mate=[1, 2]),
        trimmed=expand("qc/trimmed/{sample}_{mate}_paired_fastqc.zip",
                       sample=SAMPLES, mate=[1, 2]),
        trimming_logs=expand("logs/trimming_{sample}.log",
                             sample=SAMPLES),
        hisat2_logs=expand("logs/hisat2_{sample}.log",
                           sample=SAMPLES),
        bam_files=expand("mapped/{sample}.sorted.bam",
                         sample=SAMPLES),
        flagstat=expand("qc/alignment/{sample}_flagstat.txt",
                        sample=SAMPLES),
        stats=expand("qc/alignment/{sample}_stats.txt",
                     sample=SAMPLES),
        counts=expand("counts/{sample}_counts.txt",
                      sample=SAMPLES),
        read_distribution=expand("qc/rseqc/{sample}_read_distribution.txt",
                                 sample=SAMPLES),
        gene_body=expand(
            "qc/rseqc/{sample}_geneBodyCoverage.geneBodyCoverage.txt",
            sample=SAMPLES)
    output:
        html="results/multiqc/multiqc_report.html"
    conda:
        "envs/multiqc.yaml"
    log:
        "logs/multiqc.log"
    shell:
        """
        mkdir -p results/multiqc
        multiqc qc/ logs/ counts/ \
            -o results/multiqc \
            --force > {log} 2>&1
        """
rule flagstat:
    input:
        bam="mapped/{sample}.sorted.bam"
    output:
        txt="qc/alignment/{sample}_flagstat.txt"
    threads: 2
    conda:
        "envs/hisat2.yaml"
    log:
        "logs/flagstat_{sample}.log"
    shell:
        """
        mkdir -p qc/alignment
        samtools flagstat -@ {threads} {input.bam} \
            > {output.txt} 2> {log}
        """
rule samtools_stats:
    input:
        bam="mapped/{sample}.sorted.bam"
    output:
        txt="qc/alignment/{sample}_stats.txt"
    threads: 2
    conda:
        "envs/hisat2.yaml"
    log:
        "logs/stats_{sample}.log"
    shell:
        """
        mkdir -p qc/alignment
        samtools stats -@ {threads} {input.bam} \
            > {output.txt} 2> {log}
        """
rule gtf_to_bed12:
    input:
        gtf=config["reference"]["annotation"]
    output:
        bed="ref/gencode.v50.bed12"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/gtf_to_bed12.log"
    shell:
        """
        set -euo pipefail
        zcat {input.gtf} 2> {log} | \
        gtfToGenePred -genePredExt -ignoreGroupsWithoutExons stdin stdout 2>> {log} | \
        genePredToBed stdin {output.bed} 2>> {log}
        """
rule infer_experiment:
    input:
        bam="mapped/{sample}.sorted.bam",
        bed="ref/gencode.v50.bed12"
    output:
        txt="qc/rseqc/{sample}_infer_experiment.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/infer_experiment_{sample}.log"
    shell:
        """
        mkdir -p qc/rseqc
        infer_experiment.py \
            -i {input.bam} \
            -r {input.bed} \
            > {output.txt} 2> {log}
        """
rule read_distribution:
    input:
        bam="mapped/{sample}.sorted.bam",
        bed="ref/gencode.v50.bed12"
    output:
        txt="qc/rseqc/{sample}_read_distribution.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/read_distribution_{sample}.log"
    shell:
        """
        mkdir -p qc/rseqc
        read_distribution.py \
            -i {input.bam} \
            -r {input.bed} \
            > {output.txt} 2> {log}
        """
rule gene_body_coverage:
    input:
        bam="qc/subsampled/{sample}.bam",
        bai="qc/subsampled/{sample}.bam.bai",
        bed="ref/gencode.v50.longest.bed12"
    output:
        txt="qc/rseqc/{sample}_geneBodyCoverage.geneBodyCoverage.txt"
    params:
        prefix="qc/rseqc/{sample}_geneBodyCoverage"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/geneBodyCoverage_{sample}.log"
    shell:
        """
        mkdir -p qc/rseqc
        geneBody_coverage.py \
            -i {input.bam} \
            -r {input.bed} \
            -o {params.prefix} \
            > {log} 2>&1
        """
rule select_transcripts:
    input:
        gtf=config["reference"]["annotation"],
        bed="ref/gencode.v50.bed12",
        script="scripts/select_transcripts.py"
    output:
        bed="ref/gencode.v50.longest.bed12"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/select_transcripts.log"
    shell:
        """
        python {input.script} > {log} 2>&1
        """
rule multi_bam_summary:
    input:
        bams=expand("mapped/{sample}.sorted.bam", sample=SAMPLES),
        indexes=expand("mapped/{sample}.sorted.bam.bai", sample=SAMPLES)
    output:
        npz="qc/deeptools/multibam_summary.npz"
    threads: 4
    conda:
        "envs/deeptools.yaml"
    log:
        "logs/multibam_summary.log"
    shell:
        """
        mkdir -p qc/deeptools
        multiBamSummary bins \
            --bamfiles {input.bams} \
            --labels {SAMPLES} \
            --numberOfProcessors {threads} \
            --outFileName {output.npz} \
            > {log} 2>&1
        """
rule plot_correlation:
    input:
        npz="qc/deeptools/multibam_summary.npz"
    output:
        png="results/deeptools/correlation.png",
        matrix="results/deeptools/correlation_matrix.tsv"
    conda:
        "envs/deeptools.yaml"
    log:
        "logs/plot_correlation.log"
    shell:
        """
        mkdir -p results/deeptools
        plotCorrelation \
            --corData {input.npz} \
            --corMethod spearman \
            --whatToPlot heatmap \
            --plotFile {output.png} \
            --outFileCorMatrix {output.matrix} \
            > {log} 2>&1
        """
rule plot_pca:
    input:
        npz="qc/deeptools/multibam_summary.npz"
    output:
        png="results/deeptools/pca.png",
        data="results/deeptools/pca_data.tsv"
    conda:
        "envs/deeptools.yaml"
    log:
        "logs/plot_pca.log"
    shell:
        """
        mkdir -p results/deeptools
        plotPCA \
            --corData {input.npz} \
            --plotFile {output.png} \
            --outFileNameData {output.data} \
            > {log} 2>&1
        """
rule subsample_bam:
    input:
        bam="mapped/{sample}.sorted.bam"
    output:
        bam="qc/subsampled/{sample}.bam",
        bai="qc/subsampled/{sample}.bam.bai"
    threads: 2
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/subsample_{sample}.log"
    shell:
        """
        set -euo pipefail
        mkdir -p qc/subsampled

        samtools view -@ {threads} -b -s 42.10 \
            {input.bam} -o {output.bam} \
            2> {log}

        samtools index -@ {threads} {output.bam} \
            2>> {log}
        """
rule inner_distance:
    input:
        bam="mapped/{sample}.sorted.bam",
        bed="ref/gencode.v50.longest.bed12"
    output:
        txt="qc/rseqc/{sample}_inner_distance.inner_distance.txt"
    params:
        prefix="qc/rseqc/{sample}_inner_distance"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/inner_distance_{sample}.log"
    shell:
        """
        mkdir -p qc/rseqc
        inner_distance.py \
            -i {input.bam} \
            -r {input.bed} \
            -o {params.prefix} \
            -k 1000000 \
            --skip-plot \
            > {log} 2>&1
        """