# RNAscope segmentatio nanalysis

## Setting up environment

```bash
conda create --name cellpose python=3.8 -y
conda activate cellpose
pip install cellpose[all]
pip uninstall torch -y
conda install pytorch cudatoolkit=10.2 cuml=0.19.0 -c pytorch -c rapidsai -c nvidia -y
pip install matplotlib trackpy ipykernel seaborn numpy=1.20 -y
python -m ipykernel install --user --name cellpose
```
