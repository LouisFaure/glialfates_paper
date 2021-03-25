while read sample; do
        parallel-fastq-dump --sra-id $sample --threads 40 --outdir . --split-files --gzip

        wget -O index.html https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=$sample

        mv "$sample"_1.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read1PairFiles=).*(?= --read2PairFiles)')
        mv "$sample"_2.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read2PairFiles=).*(?= --read3PairFiles)')
        mv "$sample"_3.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read3PairFiles=).*(?= )')
        rm index.html
done <accession.txt

