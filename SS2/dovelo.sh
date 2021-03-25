#!/bin/bash

if [ -z "$1" ]; then echo "specify folder please"; exit; fi

cd $1
start=`date +%s`
starts=`date '+%Y-%m-%d %H:%M:%S'`
for D in *; do
    if [ -d "${D}" ]; then
        velocyto run_smartseq2 -o "${D}" -m ../../_prior/mm10_rmsk.gtf -e velocyted "${D}"/star_mm10/*/*unique.bam ../../_prior/gencode.vM19.annotation.gtf
        printf "done\n"
    fi &
done
wait

end=`date +%s`
ends=`date '+%Y-%m-%d %H:%M:%S'`

runtime=$((end-start))

cd ..

python sendmail.py "$starts" "$ends" "$runtime" "$1"
