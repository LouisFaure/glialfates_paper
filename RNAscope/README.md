# RNAscope segmentation analysis

## Setting up environment

```bash
mamba create --name cellpose python=3.8 -y
mamba activate cellpose
pip install cellpose[all]
pip uninstall torch -y
mamba install pytorch cudatoolkit=10.2 cuml=0.19.0 -c pytorch -c rapidsai -c nvidia -y
pip install matplotlib trackpy ipykernel seaborn numpy=1.20 -y
python -m ipykernel install --user --name cellpose
```
## Downloading cropped and annotated data

```bash
wget https://figshare.com/ndownloader/files/34851852 --output-document image_data.tar.gz
tar xvf image_data.tar.gz
```
