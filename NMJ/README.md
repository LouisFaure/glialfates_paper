# NMJ analysis

## required packages

```bash
mamba create -n NMJ -c bioconda -c defaults -c conda-forge \
	star subread python=3.8 bioconductor-deseq2 bioconductor-apeglm rpy2 -y
mamba activate NMJ

pip install git+https://github.com/LouisFaure/bulktools-py.git
pip install git+https://github.com/LouisFaure/deseq2py.git
```

## downloading the data

### fetching sra

```bash
while read a; do
  prefetch $a --max-size 50GB &
done <accession.txt
```

### generating fastq

```bash
mkdir -p fastq
while read sample; do
        parallel-fastq-dump --sra-id $sample --threads 40 --outdir . --split-files --gzip
        mv "$sample"_1.fastq.gz fastq/"$sample"_R1_001.fastq.gz
done <accession.txt
```

## Running alignment

### Generate STAR index

```bash
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/gencode.vM27.annotation.gtf.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/GRCm39.primary_assembly.genome.fa.gz
gunzip *.gz
mkdir -p star
STAR --runMode genomeGenerate --runThreadN 40 --genomeDir star/GRCm39_vM27_NMJ \
  --genomeFastaFiles GRCm39.primary_assembly.genome.fa \
  --sjdbGTFfile gencode.vM27.annotation.gtf --sjdbOverhang 149
```

### Do the alignement and counting

```bash
bt -s star/GRCm39_vM27_NMJ -g gencode.vM27.annotation.gtf -n 20
```
