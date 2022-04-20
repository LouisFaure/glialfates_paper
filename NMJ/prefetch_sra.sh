while read a; do
  prefetch $a --max-size 50GB &
done <accession.txt
