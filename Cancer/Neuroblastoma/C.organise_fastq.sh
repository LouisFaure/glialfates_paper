for f in *R1_00*; do
	sample="$(cut -d'_' -f1 <<<$f)"
	mkdir $sample
	mkdir "$sample"/fastqs/
	mv "$sample"*.gz "$sample"/fastqs/
done
