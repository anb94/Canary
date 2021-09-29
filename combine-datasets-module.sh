#!/bin/bash

# manual input
# Path of the *allchr.pdat input files - (should be the dir used in ${dose2plinkout}"/"${dataset}" from convert-mac-module.sh)

dataset_1_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/WHIMS_dataset/WHIMS_d2p
dataset_2_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset/GARNET_d2p
datasets=()
datasets=(${dataset_1_dir} ${dataset_2_dir})

# name the prefix for the output
output_name=whi_test

# output directory for the combined datasets
out_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/test_combine



########################################################################

# JETHRO CREATE INPUT HERE










########################################################################



# Generate the set of SNPs in each dataset #
for i in "${datasets[@]}"; do
  echo "Generating SNP set for "${i}""
  dtst=$(basename "$i")
  tail -n +2  "${i}"/*_allchr.pdat | awk '{print $1,$2,$3}' | sort > "${out_dir}"/"${dtst}"_snp-set.tsv
  echo "Finished generating SNP set for "${i}""
done
echo "Completed Generating SNP sets"

echo "Generating file of shared snps between the datasets"
source "${BASH_SOURCE%/*}/multicomm"  "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv
#echo "$(comm -12 "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv
#echo "Done generating file of shared snps"
#echo "$(cut -d ' ' -f 1 "${out_dir}"/"${output_name}"_sharedsnps.tsv)" > "${out_dir}"/"${output_name}"_shared_alleles.tsv


# Plan to combine by using a snpset variable created by input names
