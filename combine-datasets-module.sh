#!/bin/bash

# manual input
# Path of the *allchr.pdat input files - (should be the dir used in ${dose2plinkout}"/"${dataset}" from convert-mac-module.sh)

dataset_1_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/WHIMS_dataset/
dataset_2_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset/
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
  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
  # remove the first line as it contains header
  tail -n +2  "${i}"/*_allchr.pdat | gawk '{print $1,$2,$3}' | sort > "${out_dir}"/"${dtst}"_snp-set.tsv
  echo "Finished generating SNP set for "${i}""
done
echo "Completed Generating SNP sets"

echo "Generating file of shared snps between the datasets"
# Use the script multi_comm to compare all input files for common SNPs
"${BASH_SOURCE%/*}/multi_comm.sh"  "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv

# NOTE: if any errors occur in this step, they are also likely to occur in the step below as the code is very similar #


#echo "$(comm -12 "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv
#echo "Done generating file of shared snps"
#echo "$(cut -d ' ' -f 1 "${out_dir}"/"${output_name}"_sharedsnps.tsv)" > "${out_dir}"/"${output_name}"_shared_alleles.tsv



# Generate map file for the combined dataset #
# The below code generating the map files is based on the code above
for i in "${datasets[@]}"; do
  echo "Generating map file for "${i}""
  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
  # remove the first line as it contains header
  tail -n +2 "${i}"/*_allchr.pdat | sort > "${out_dir}"/"${dtst}"_tempmap1.tsv
  echo "Finished generating map file for "${i}""
done
echo "Completed Generating SNP sets"

echo "Generating file of shared snps between the datasets"
# Use the script multi_comm to compare all input files for common SNPs
"${BASH_SOURCE%/*}/multi_comm.sh" "${out_dir}"/*_tempmap1.tsv > "${out_dir}"/"${output_name}"__tempmap2.tsv

# map file must contain a header since header was removed in the above for loop - take header from the first pdat file in array.
gawk '{print 0,$1,0,0}' "${datasets[0]}"/*_allchr.pdat | head -n 1 > "${out_dir}"/"${output_name}".map
gawk '{print 0,$1,0,0}' "${out_dir}"/"${output_name}"__tempmap2.tsv >> "${out_dir}"/"${output_name}".map


# Collect low quality SNPs
rm -rf "${out_dir}"/"${output_name}"_tempsnps.txt
for i in "${datasets[@]}"; do
  echo "Copying low quality snps for "${i}" to "${out_dir}""
cat "${i}"/*_all_chr_lq_all_snps.txt >> "${out_dir}"/"${output_name}"_tempsnps.txt
done
echo "Finished combining low quality SNPs"

# Keep only unique entries
sort "${out_dir}"/"${output_name}"_tempsnps.txt | uniq -u > "${out_dir}"/"${output_name}"_lq_all_snps.txt


for i in "${datasets[@]}"; do
  echo "importing "${i}" into plink2 format"
  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
  plink2 --import-dosage "${i}"/*_allchr.pdat \
  --psam "${i}"/*_allchr.pfam \
  --include "${i}"/"$dtst}"_sharedsnps.tsv \
  --exclude "${i}"/"${dtst}"_lq_all_snps.txt \
  --make-pgen \
  --out "${i}"/"${dtst}"_plink_temp1
done

for i in "${datasets[@]}"; do
  echo "${i}"/"${dtst}"_plink_temp1 >> "${out_dir}"/"${output_name}"_plink.txt
done


plink2 --pmerge-list "${out_dir}"/"${output_name}"_plink.txt --make-pgen --out "${out_dir}"/"${output_name}"_temp2
