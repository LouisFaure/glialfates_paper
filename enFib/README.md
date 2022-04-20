# NMJ analysis

## required packages and data download

```bash
mamba create -n enFib -c conda-forge -c bioconda -c bioturing \
	r-seurat r-devtools r-seuratdisk r-seuratdat python=3.8 -y
mamba activate enFib

# donwload data
R --slave -e "devtools::install_github("millerkaplanlab/MouseSciaticNerve")"
```

