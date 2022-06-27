<p align="center">
    <img src="https://github.com/anb94/Canary/blob/97247ab0bd8439e9d6f4d9ee6265c56536270bcd/canarylogo.png">
</p>


# Canary


## Introduction

Canary is a bioinformatics tool that allows for the automatic conversion of MaCH dosage files (mlinfo and mldose) into PLINK1 and PLINK2 compatible files. 


This repository provides a guide for using Canary for semi-automated preparation of both genotype and phenotype files for GWAS analyses using MaCH dosage  files, mlinfo and mldose format, such as those provided by dbGaP for the Women's Health Initiative (WHI).



## How To Use

Canary is essentially a singularity container that comes preloaded with software and scripts that allows users to convert file format and perform GWAS more easily on a local machine and/or HPC environment. 

In order to use Canary, you must first build it using singularity. Therefore, you must install singularity on your local machine, following the instructions provided at https://sylabs.io/guides/latest/admin-guide/ and then build the container.

Once you have built the container, you can run the container with:

singularity shell ~/path/to/file/Canary.sif

Once inside the container, run the script you desire to use. For example, starting at the first step, combining the consent groups you would type the following command:


~/Canary/combine-datasets-module.sh -d ~/dbgap/WHI/SHARE_dataset -d ~/dbgap/WHI/SHARE_dataset -n whicombtest -o ~/processed_data/dbgap/WHI/combined_SHARE


It is important to note that if you plan to use Canary on an HPC, singularity must be installed on the HPC. If your HPC system does not have singularity installed, contact a system administrator if required. 


## Software Installed

The Canary container comes with software essential for performing GWAS analyses installed, including:

- PLINK1 and PLINK2
- BCFTools
- SRAToolkit
- GCTA
- Python3: 
    - Pandas
    - NumPy
- R:
    - GWASTools (Biocondutor)
    - Tidyverse


## Phenotype File Preparation

It is recommended to begin with preparing the phenotype files for your analysis first as these are required when preparing the genotype files.
A tutorial for preparing the phenotype file is provided in the script "Tutorial-for-Phenotype-File.py"


## Genotype File Preparation




###  Canary Logo Credit
Canary logo was creating using an original image from <a href="https://www.vecteezy.com/free-vector/nature">Nature Vectors by Vecteezy</a>.
