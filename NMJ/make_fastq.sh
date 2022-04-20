mkdir -p fastq
while read sample; do
        parallel-fastq-dump --sra-id $sample --threads 40 --outdir . --split-files --gzip
        mv "$sample"_1.fastq.gz fastq/"$sample"_R1_001.fastq.gz
done <accession.txt