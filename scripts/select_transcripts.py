
import gzip
import re

gtf_file = "ref/gencode.v50.primary_assembly.annotation.gtf.gz"
bed_file = "ref/gencode.v50.bed12"
output_file = "ref/gencode.v50.longest.bed12"

longest = {}

with gzip.open(gtf_file, "rt") as f:
    for line in f:
        if line.startswith("#"):
            continue

        fields = line.rstrip("\n").split("\t")

        if len(fields) < 9 or fields[2] != "transcript":
            continue

        gene = re.search(r'gene_id "([^"]+)"', fields[8])
        transcript = re.search(r'transcript_id "([^"]+)"', fields[8])

        if gene is None or transcript is None:
            continue

        length = int(fields[4]) - int(fields[3]) + 1
        gene_id = gene.group(1)
        transcript_id = transcript.group(1)

        if gene_id not in longest or length > longest[gene_id][1]:
            longest[gene_id] = (transcript_id, length)

selected = {item[0] for item in longest.values()}

with open(bed_file) as source, open(output_file, "w") as output:
    for line in source:
        fields = line.split("\t")
        if len(fields) >= 12 and fields[3] in selected:
            output.write(line)

print("Genes:", len(longest))
print("Selected transcripts:", len(selected))
print("Output:", output_file)
