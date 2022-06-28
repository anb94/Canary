<p align="center">
    <img src="https://github.com/anb94/Canary/blob/97247ab0bd8439e9d6f4d9ee6265c56536270bcd/canarylogo.png">
</p>


# Canary


## Introduction

Canary is a bioinformatics tool that allows for the automatic conversion of MaCH dosage files (mlinfo and mldose) into PLINK1 and PLINK2 compatible files. It also has other software that is essential for performing GWAS installed.


This repository provides a guide for using Canary for semi-automated preparation of both genotype and phenotype files for GWAS analyses using MaCH dosage  files, mlinfo and mldose format, such as those provided by dbGaP for the Women's Health Initiative (WHI).



### Software Installed in Canary

The Canary container comes with software essential for performing GWAS analyses installed, including:

- PLINK1
- PLINK2
- BCFTools
- SRAToolkit
- GCTA
- Python3: 
    - Pandas
    - NumPy
- R:
    - GWASTools (Biocondutor)
    - Tidyverse


### System Requirements

In order to use Canary you must have singularity installed on your system. To installm please follow the installation guide at https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#quick-installation-steps.


## Phenotype File Preparation

It is recommended that phenotype files are prepared first as these are required when preparing the genotype files. An overview of the phenotype file generation process can be seen in the image below:


<p align="center">
    <img height="600"  src="https://github.com/anb94/Canary/blob/a7add4d454b231a42804b168490c99c737df4c4e/canary-images/phenotype-file.png">
</p>


Automated preparation of the phenotype file is not supported by Canary. However, we do provide a detailed tutorial for preparing the phenotype file using Python3 in the script "Tutorial-for-Phenotype-File.py". Users are advised to edit a copy this file rather than edit it directly.


## Genotype File Preparation

The main function of Canary is to convert mldose and mlinfo MaCH files into PLINK compatible files. This can be achieved using the scripts provided whilst using the Canary environment.

An overview of the modules available can be seen in the image below:

<p align="center">
    <img height="400"  src="https://github.com/anb94/Canary/blob/34f31779fab82712abb4dd021250f79f92772856/canary-images/canary-overview.png">
</p>


As described in the image above, the typical order of operations would be:
- convert-mac-module.sh
- combine-datasets-module.sh (Should be skipped if using single dataset/consent group)
- correct-plinkfiles.sh (Should be skipped if used combine-datasets-module.sh, as it is automatically performed in this module)

## User Guide

Canary is a singularity container that comes preloaded with software and scripts that allows users to convert file formats and perform GWAS more easily on a local machine and/or HPC environment. To install and use Canary, please folow the steps below. 


### Step 1: Install singularity

In order to use Canary, you must first build it using singularity. Therefore, you must install singularity on your local machine, following the instructions provided at https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#quick-installation-steps before attempting to build the container.

Once singularity is installed, you can follow the user guide at https://docs.sylabs.io/guides/latest/user-guide/index.html for detailed instructions on how to use singularity.

NOTE: System Administrators can consult the Admin guide for singularity at https://sylabs.io/guides/latest/admin-guide/.

### Step 2: Download Canary github repo

Download/clone the github repo to your local machine using the green 'Code' drop down menu at the top right of the Canary homepage.

or use the following command:

```bash
git clone https://github.com/anb94/Canary.git
```

### Step 3: Build the Canary container

To build the Canary container, you should do so using singularity (installed in step 1). As this first step requires sudo permissions, it is reccomended that you build the container on your local machine, rather than a HPC as users often do not have permission to use sudo.

For example:

```bash
sudo singularity build ~/Canary/Canary.sif ~/Canary/canary-container.def
```

In the example above, the first argument is the path where you wish to save the Canary container (in this case inside the Canary folder downloaded in step 1) and the second argumet is the Canary definition file that is in this repo. 


For help with this step or more detailed instructions on how to use singularity please consult the singularity user guide at https://docs.sylabs.io/guides/latest/user-guide/index.html.


### Optional Step: Copying the container to HPC

If you wish to use this container on an HPC, you should first copy the Canary folder and the Canary.sif to the HPC. One way to do this is to use the command scp, such as in the below example:

```bash
scp -r ~/Canary HPC-username@10.10.0.2:/usr/Canary
```

For help with this step you can read this article https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/.

It is important to note that if you plan to use Canary on an HPC, singularity must be installed on the HPC. If your HPC system does not have singularity installed, contact a system administrator and provide them with the guide at https://sylabs.io/guides/latest/admin-guide/.



### Step 4: Using the Canary container

Once you have built the container, you can run the container with:

```bash
singularity shell ~/Canary/Canary.sif
```


### Step 5: Using Canary's automated scripts

Once inside the container (step 4), you can run the script you desire to use. 

For example, if you wish to combine the consent groups, you would type the following command:


```bash
~/Canary/combine-datasets-module.sh -d ~/dbgap/WHI/SHARE_dataset -d ~/dbgap/WHI/SHARE_dataset -n WHI-SHARE-CB -o ~/processed_data/dbgap/WHI/SHARE-CB
```



###  Canary Logo Credit
Canary logo was creating using an original image from <a href="https://www.vecteezy.com/free-vector/nature">Nature Vectors by Vecteezy</a>.
