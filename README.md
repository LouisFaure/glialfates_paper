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

## Hardware used for this analysis
* HPC system with 88 cores and 1 To of RAM
* RTX8000 nvidia GPU (used in SS2 velocity and tree analysis, Neuroblastoma preprocessing & RNAscope segmentation)
