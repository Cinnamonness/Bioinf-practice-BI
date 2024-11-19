# Bioinf-practice-BI

## Snakefile for HW2 "Why Did I Get the Flu?"

Authors:
* **Software:** *Karitskaya Polina*, *Kozlova Polina*, <br/>
Institute of Bioinformatics, Saint Petersburg, Russia.

---
## Table of Contents
- [How to Install](#how-to-install)
- [How to Run](#how-to-run)
- [Features](#features)
- [Requirements](#requirements)

---
## How to Install

- Clone the repository to your local machine using Git or download the Snakefile from the GitHub repository.

```bash
git clone git@github.com:Cinnamonness/Bioinf-practice-BI.git
cd Bioinf-practice-BI
```

---
## How to run

- Create working directory
For example:

```bash
mkdir practice2
cd practice2
```

- Make sure the Snakefile is in your working directory. In this example, the Snakefile should be in the practice2 directory.

- Ensure that you have downloaded the reference [sequence.fasta](https://www.ncbi.nlm.nih.gov/nuccore/KF848938.1?report=fasta). t should be in your working directory.

- Ensure you have installed [VarScan.v2.3.9.jar](https://sourceforge.net/projects/varscan/files/VarScan.v2.3.9.jar/download). It should be in your working directory.

- Change the absolute path in Snakefile (it is the first string). To know your absolute path you can use command:

```bash
pwd
```
- install snakemake:

```bash
pip install snakemake 
```

- Run the Snakefile using this command from your working directory:

```bash
snakemake -p --cores all  
```

---
## Features

This project includes the following features:

1. **Data Download**: 
   - Downloads FastQ files from the SRA FTP server for different samples (SRR1705851, SRR1705858, SRR1705859, and SRR1705860).

2. **Reference Indexing**: 
   - The reference genome (`sequence.fasta`) is indexed using BWA to generate required index files for alignment.

3. **Alignment and Sorting**:
   - Aligns FastQ files to the reference genome using BWA.
   - Sorts the resulting BAM files using Samtools for downstream processing.

4. **MPileup Generation**: 
   - Generates MPileup files from the aligned BAM files using Samtools, which are used for variant calling.

5. **Variant Calling**:
   - Two levels of variant calling are supported:
     - **Common Variants**: Calls variants with a minimum frequency of 95% using VarScan.
     - **Rare Variants**: Calls variants with a minimum frequency of 0.1% using VarScan.

6. **Parallel Processing**:
   - Processes multiple samples in parallel using Snakemake's expand functionality, ensuring that the workflow runs efficiently for multiple samples (SRR1705858, SRR1705859, SRR1705860).

7. **VCF Output**:
   - Generates VCF files containing the variant calls for each sample, separated into two files: one for common variants and another for rare variants.

8. **Sample-Specific Results**:
   - Each sample's analysis (alignment, variant calling, etc.) is handled separately, allowing for easy scalability to more samples by adding them to the Snakefile.

9. **Compatibility with VarScan**:
   - Integration with VarScan for variant calling ensures high-quality SNP calling and variant analysis from high-depth sequencing data.

10. **Efficient Data Management**:
   - All output files are neatly organized in the working directory, ensuring proper file management and easy retrieval of results.

---
## Requirements

1. snakemake 8.25.3

2. bwa 0.7.17-r1188

3. samtools 1.13

4. VarScan.v2.3.9




