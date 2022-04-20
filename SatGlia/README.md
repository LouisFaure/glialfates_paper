# Satellite glia analysis

## required tools

```bash
pip install kb-python
kb compile all
```

### fetching raw data

```bash
while read a; do
  echo $a
  prefetch $a --max-size 50GB &
done < accession.txt
wait
```


## Data alignment

### making index

```bash
wget http://ftp.ensembl.org/pub/release-97/gtf/mus_musculus/Mus_musculus.GRCm38.97.gtf.gz
wget http://ftp.ensembl.org/pub/release-97/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
kb ref --workflow lamanno -i kallisto/index -g kallisto/t2g.tsv -f1 kallisto/cDNA \
  -f2 kallisto/iDNA -c1 kallisto/cDNA2tr -c2 kallisto/iDNA2tr \
  Mus_musculus.GRCm38.dna.primary_assembly.fa.gz Mus_musculus.GRCm38.97.gtf.gz
```

### Run kallisto

```bash
while read a; do
  parallel-fastq-dump --sra-id $a --threads 40 --outdir . --split-files --gzip
  mkdir $a
  kb count -o $a -t 6 -x DROPSEQ --workflow lamanno --h5ad -g kallisto/t2g.tsv \
    -i kallisto/index -c1 kallisto/cDNA2tr -c2 kallisto/iDNA2tr $(ls $a*.gz)
done < accession.txt
```
