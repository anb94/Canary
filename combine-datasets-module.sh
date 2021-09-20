#!/bin/bash

########################################################################

# JETHRO CREATE INPUT HERE

while getopts "m:" opt; do
    case $opt in
        m) multi+=("$OPTARG");;
        #...
    esac
done
shift $((OPTIND -1))

# OPTIONS ARE TO CREATE THE FOLLOWING:

# Define environment variables
# Define base directory:
dataset_base_dir=$HOME/SAP2-GWAS/datasets/
dataset1=${dataset_base_dir}/dataset

# Define dataset variables:

# project name for naming files
project=TEST

dataset_1_dir=$HOME/indir_1
dataset_2_dir=$HOME/indir_2

# an array which contains the datasets to be combined
datasets=(dataset_1_dir, dataset_2_dir...etc)


dataset_combined_dir=$HOME/outdir_cb



########################################################################



# Combine genotype datasets #


# Plan to combine by using a snpset variable created by input names
