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