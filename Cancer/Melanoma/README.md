# Melanoma analysis

## getting raw data

```bash
while read g; do
	gpre=$(echo $g | cut -d_ -f1)
	wget -q ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4147nnn/"$gpre"/suppl/"$g"_barcodes.tsv.gz &&
	wget -q ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4147nnn/"$gpre"/suppl/"$g"_genes.tsv.gz &&
	wget -q ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4147nnn/GSM4147091/suppl/"$g"_matrix.mtx.gz &
done <gsm.txt
wait
```