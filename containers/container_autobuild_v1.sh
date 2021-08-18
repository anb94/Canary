#!/bin/bash

# Define environment variables
## Define SHARE Root directory:
build_dir=$HOME/test

wget https://raw.githubusercontent.com/anb94/gwas_pancan/master/singularity_images/custom_singularity_images/canary_v5.def -O "${build_dir}"/canary.def
sudo singularity build --sandbox "${build_dir}"/canary_v5.sif "${build_dir}"/canary.def
sudo singularity shell --writable "${build_dir}"/canary_v5.sif ~/canary_upgrade.sh





apt-get install -y default-jre openjdk-11-jre-headless openjdk-8-jre-headless default-jdk libcurl4 libcurl4-openssl-dev \
libxml2-dev libssl-dev
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe"
apt-get update
apt-get upgrade -y
apt-get install -y r-base r-base-dev
R --no-save
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("GWASTools")
install.packages("tidyverse")
q()
exit
