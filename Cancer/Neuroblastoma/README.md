# Neuroblastoma analysis

## Obtaining raw data

### donwload sra
```bash
while read a; do
  prefetch $a --max-size 50GB &
done <accession.txt
```

### generate and organise fastq files
```bash
while read sample; do
        parallel-fastq-dump --sra-id $sample --threads 40 --outdir . --split-files --gzip

        wget -O index.html https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=$sample

        mv "$sample"_1.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read1PairFiles=).*(?= --read2PairFiles)')
        mv "$sample"_2.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read2PairFiles=).*(?= --read3PairFiles)')
        mv "$sample"_3.fastq.gz $(echo $(grep "read1PairFiles" index.html) | grep -o -P '(?<=read3PairFiles=).*(?= )')
        rm index.html
done <accession.txt


for f in *R1_00*; do
	sample="$(cut -d'_' -f1 <<<$f)"
	mkdir $sample
	mkdir "$sample"/fastqs/
	mv "$sample"*.gz "$sample"/fastqs/
done
```

## Aligning data

The following code is specially made for two NUMA node HPC system

code to write onto the file **run_cellranger.sh**
```bash
#!/bin/bash
export CR_REF=/home/lfaure/tools/refs/GRCh38
cd $1
cellranger count --id="$1"_CR \
--fastqs=fastqs \
--sample=$1 \
--transcriptome=$CR_REF \
--localmem=256 \
--localcores=32
```

```python
import glob
from pathlib import Path
import pandas as pd
import subprocess
import numpy as np

folds=glob.glob("*/")
sizes = list(map(lambda fold: sum(f.stat().st_size for f in Path(fold).glob('**/*.fastq.gz') if f.is_file()),folds))
folds = list(map(lambda fold: fold[:-1],folds))
sizes=pd.Series(sizes,index=folds)
sizes.sort_values(ascending=False,inplace=True)
toproc=np.array(sizes.index).reshape((8,2))

for i in range(6):
    command1="numactl --cpubind=0 --membind=0 bash run_cellranger.sh "+toproc[i,0]
    command2="numactl --cpubind=1 --membind=1 bash run_cellranger.sh "+toproc[i,1]
    commands = [command1.split(), command2.split()]
    procs = [ subprocess.Popen(i) for i in commands ]
    for p in procs:
        p.wait()
```