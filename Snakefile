absolute_path = "/root/practice2/raw_data" #change this path for your work

url = "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/001/SRR1705851/SRR1705851.fastq.gz"
urls = [
    "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/008/SRR1705858/SRR1705858.fastq.gz",
    "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/009/SRR1705859/SRR1705859.fastq.gz",
    "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR170/000/SRR1705860/SRR1705860.fastq.gz"]

rule all:
    input:
        "SRR1705851.fastq.gz",
        expand(f"{absolute_path}/sequence.fasta.{{ext}}", ext=["amb", "ann", "bwt", "pac", "sa"]),
        "VarScan_results.vcf",
        "VarScan_results_rare.vcf",
        expand("SRR1705858.fastq.gz", sample=["SRR1705858"]),
        expand("SRR1705859.fastq.gz", sample=["SRR1705859"]),
        expand("SRR1705860.fastq.gz", sample=["SRR1705860"]),
        expand("{sample}_VarScan_results.vcf", sample=["SRR1705858", "SRR1705859", "SRR1705860"])

rule download_data:
    output:
        "SRR1705851.fastq.gz"
    shell:
        "wget -c -O {output} {url}"

rule download_additional_data:
    output:
        "SRR1705858.fastq.gz",
        "SRR1705859.fastq.gz",
        "SRR1705860.fastq.gz"
    shell:
        """
        wget -q {urls[0]} -O {absolute_path}/SRR1705858.fastq.gz
        wget -q {urls[1]} -O {absolute_path}/SRR1705859.fastq.gz
        wget -q {urls[2]} -O {absolute_path}/SRR1705860.fastq.gz
        """

rule index_reference:
    input:
        f"{absolute_path}/sequence.fasta"
    output:
        f"{absolute_path}/sequence.fasta.amb",
        f"{absolute_path}/sequence.fasta.ann",
        f"{absolute_path}/sequence.fasta.bwt",
        f"{absolute_path}/sequence.fasta.pac",
        f"{absolute_path}/sequence.fasta.sa"
    shell:
        "bwa index {input}"

rule align_and_process:
    input:
        reference=f"{absolute_path}/sequence.fasta",
        fastq="SRR1705851.fastq.gz"
    output:
        bam="sorted_output.bam"
    shell:
        """
        bwa mem {input.reference} {input.fastq} | \
        samtools view -b - | \
        samtools sort -o {output.bam}
        """

rule generate_mpileup:
    input:
        reference=f"{absolute_path}/sequence.fasta",
        bam="sorted_output.bam"
    output:
        "my.mpileup"
    shell:
        "samtools mpileup -f {input.reference} -d 100000 {input.bam} > {output}"

rule varscan_common:
    input:
        mpileup="my.mpileup"
    output:
        "VarScan_results.vcf"
    shell:
        """
        java -jar VarScan.v2.3.9.jar mpileup2snp {input.mpileup} \
        --min-var-freq 0.95 --variants --output-vcf 1 > {output}
        """

rule varscan_rare:
    input:
        mpileup="my.mpileup"
    output:
        "VarScan_results_rare.vcf"
    shell:
        """
        java -jar VarScan.v2.3.9.jar mpileup2snp {input.mpileup} \
        --min-var-freq 0.001 --variants --output-vcf 1 > {output}
        """

rule align_and_sort:
    input:
        reference=f"{absolute_path}/sequence.fasta",
        fastq="{sample}.fastq.gz"
    output:
        bam="{sample}_sorted.bam"
    shell:
        """
        bwa mem {input.reference} {input.fastq} | \
        samtools view -b - | \
        samtools sort -o {output.bam}
        """

rule index_bam:
    input:
        bam="{sample}_sorted.bam"
    output:
        index="{sample}_sorted.bam.bai"
    shell:
        "samtools index {input.bam}"

rule generate_mpileup_sample:
    input:
        reference=f"{absolute_path}/sequence.fasta",
        bam="{sample}_sorted.bam"
    output:
        mpileup="{sample}.mpileup"
    shell:
        "samtools mpileup -f {input.reference} -d 100000 {input.bam} > {output.mpileup}"

rule varscan_analysis:
    input:
        mpileup="{sample}.mpileup"
    output:
        vcf="{sample}_VarScan_results.vcf"
    shell:
        """
        java -jar VarScan.v2.3.9.jar mpileup2snp {input.mpileup} \
        --min-var-freq 0.001 --variants --output-vcf 1 > {output.vcf}
        """
