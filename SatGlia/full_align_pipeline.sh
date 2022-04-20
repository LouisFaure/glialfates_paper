#!/bin/bash
while read a; do
  echo $a
  prefetch $a --max-size 50GB &
done < accession.txt
wait


while read a; do
  parallel-fastq-dump --sra-id $a --threads 40 --outdir . --split-files --gzip
  mkdir $a
  kb count -o $a -t 6 -x DROPSEQ --workflow lamanno --h5ad -g kallisto/Velo_97/tr2g.tsv -i kallisto/Velo_97/cDNA_introns.idx -c1 kallisto/Velo_97/cDNA_tx_to_capture.txt -c2 kallisto/Velo_97/introns_tx_to_capture.txt $(ls $a*.gz)
done < accession.txt
