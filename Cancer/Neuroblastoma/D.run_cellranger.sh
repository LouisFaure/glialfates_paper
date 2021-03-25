export CR_REF=/home/lfaure/tools/refs/GRCh38

cd $1
cellranger count --id="$1"_CR \
--fastqs=fastqs \
--sample=$1 \
--transcriptome=$CR_REF \
--localmem=256 \
--localcores=32
