# Glial fates paper code reproducibility
[![Line count](https://raw.githubusercontent.com/LouisFaure/glialfates_paper/linecount/badge.svg)](https://github.com/LouisFaure/glialfates_paper/actions/workflows/linecount.yml)
[![DOI](https://img.shields.io/badge/DOI-10.15252/embj.2021108780-blue)](https://doi.org/10.15252/embj.2021108780)
[![GEO](https://img.shields.io/badge/SmartSeq2%20data-GSE201257-green)](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE201257)
[![GEO](https://img.shields.io/badge/RNAscope%20data-10.6084/m9.figshare.19620102.v1-green)](https://figshare.com/articles/dataset/RNAscope_data/19620102)

## Cite this paper

```
Kastriti, M. E., Faure, L., von Ahsen, D., Bouderlique, T. G., Boström, J., Solovieva, T., Jackson, C., Bronner, M., Meijer, D., Hadjab, S., Lallemend, F., Erickson, A., Kaucka, M., Dyachuk, V., Perlmann, T., Lahti, L., Krivanek, J., Brunet, J., Fried, K.,; Adameyko, I. (2022). 
Schwann cell precursors represent a neural crest‐like state with biased multipotency. 
The EMBO Journal, 41(17). https://doi.org/10.15252/embj.2021108780
```

## Required software

It is highly recommended to work on `linux`, with `mamba` in order to create dedicated environments. For more information on how to install and use mamba, please check out the [following link](https://mamba.readthedocs.io/en/latest/installation.html).

## Obtain complete cell annotation

The complete assignment of all cell types/states can be found as a [csv file](https://github.com/LouisFaure/glialfates_paper/blob/main/assignments.csv). It combines the result of three analysis: (1) cell assignment to known cell type using canonical marker scoring, (2) Hub cell assignment using gene scoring and Leiden clustering and (3) SC subtypes assignment using tree analysis. (1) and (2) analysis code is located [here](https://github.com/LouisFaure/glialfates_paper/blob/main/SS2/03.Cell-type_Assigment.ipynb), (3) analysis code [here](https://github.com/LouisFaure/glialfates_paper/blob/main/SS2/10.Glial_focus.ipynb).

```bash
wget -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE201nnn/GSE201257/suppl/GSE201257%5Fadata%5Fassigned%2Eh5ad%2Egz
wget -nv https://ftp.ncbi.nlm.nih.gov/geo/series/GSE201nnn/GSE201257/suppl/GSE201257%5Fadata%5Fglia%5Ffocus%2Eh5ad%2Egz
gunzip *.gz
```


```python
import scanpy as sc
adata=sc.read_h5ad("GSE201257_adata_assigned.h5ad")
celltypes=['BCC',
 'ChC',
 'enteric glia',
 'enteric neu.',
 'melanocytes',
 'mesenchyme',
 'neural crest',
 'SC',
 'sat. glia',
 'sens. neu.',
 'symp. neu.',
 'endo. fib.']

adata.obs.assignments=adata.obs.assignments.cat.rename_categories(
    list(markers.keys())+["none"])

cols=dict(zip(celltypes,adata.uns["assignments_colors"]))
cols["none"]="lightgrey"
adata.obs.assignments=adata.obs.assignments.astype(str)

# assign Schwann Cell subtypes
adata_glia=sc.read("GSE201257_adata_glia_focus.h5ad")
adata.obs.loc[adata_glia.obs_names[adata_glia.obs.milestones=="tSC"],"assignments"]="tSC"
adata.obs.loc[adata_glia.obs_names[adata_glia.obs.milestones=="nmSC"],"assignments"]="nmSC"
adata.obs.loc[adata_glia.obs_names[adata_glia.obs.milestones=="mSC"],"assignments"]="mSC"

# add Hub cells
adata.obs.loc[adata[adata.obs.Hub_leiden=="True"].obs_names,"assignments"]="Hub"

adata.obs.assignments=adata.obs.assignments.astype("category")
cols["tSC"]="#b69169"
cols["mSC"]="#192bc2"
cols["nmSC"]=adata_glia.uns["milestones_colors"][
    adata_glia.obs.milestones.cat.categories=="nmSC"][0]
cols["endo. fib."]="#d33f6a"
cols["Hub"]="#fa9e8b"

celltypes.append("tSC")
celltypes.append("mSC")
celltypes.append("nmSC")
celltypes.append("Hub")

palette=[cols[a] for a in adata.obs.assignments.cat.categories]
sc.pl.umap(adata,color="assignments",palette=palette)
adata.obs[["assignments"]].to_csv("assignments.csv")
```


## Hardware used for this analysis
* HPC system with 88 cores and 1 To of RAM
* RTX8000 nvidia GPU (used in SS2 velocity and tree analysis, Neuroblastoma preprocessing & RNAscope segmentation)
