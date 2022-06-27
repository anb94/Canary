<p align="center">
    <img src="https://github.com/anb94/Canary/blob/97247ab0bd8439e9d6f4d9ee6265c56536270bcd/canarylogo.png">
</p>


# Canary

A tool for automatic conversion of MaCH dosage files into PLINK compatible files.

## Introduction

This repo provides a semi-automated workflow for preparing files for GWAS analyses on files in MaCH or Minimac dosage format, such as those provided by dbGaP for the Women's Health Initiative (WHI).


## How To Use

In order to use Canary, you must build it using singularity. Therefore, you must install singularity on your local machine, following the instructions provided at https://sylabs.io/guides/latest/admin-guide/ and then build the container.


Once you have built the container, you can run the container with:

singularity shell ~/path/to/file/Canary.sif

Once inside the container, run the script you desire to use. For example, starting at the first step, combining the consent groups you would type the following command:


~/Canary/combine-datasets-module.sh -d ~/dbgap/WHI/SHARE_dataset -d ~/dbgap/WHI/SHARE_dataset -n whicombtest -o ~/processed_data/dbgap/WHI/combined_SHARE


## Software Installed

Canary comes with other software essential for performing GWAS:

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




