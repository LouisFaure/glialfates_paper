# Main SS2 analysis

## Setting up environment (GPU enabled)

```bash
mamba create -n SS2 -c rapidsai -c nvidia -c conda-forge -c defaults -c r \
	cuml=22.04 cugraph=22.04 python=3.8 cudatoolkit=11.0 r-mgcv rpy2 -y
mamba activate SS2
pip install scFates git+https://github.com/LouisFaure/anndata2pagoda palantir cellrank \
	brie==2.0.5 tensorflow==2.4.0 tensorflow-probability==0.12.2 ipykernel

python -m ipykernel install --user --name SS2
```
