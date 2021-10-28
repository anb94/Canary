#!/bin/bash

# manual input
# Path of the *allchr.pdat input files - (should be the dir used in ${dose2plinkout}"/"${dataset}" from convert-mac-module.sh)

dataset_1_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/WHIMS_dataset
dataset_2_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset
datasets=()
datasets=(${dataset_1_dir} ${dataset_2_dir})


# name the prefix for the output
output_name=whi_test

# output directory for the combined datasets
out_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/test_combine
script_dir=/home/anbennett2/github/SAP2-GWAS


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
  tail -n +2  "${i}"/*_allchr.pdat | gawk '{print $1,$2,$3}' | sort > "${i}"/"${dtst}"_snp-set.tsv

  echo "Finished generating SNP set for "${i}""
done
echo "Completed Generating SNP sets"

echo "Generating file of shared snps between the datasets"
# Use the script multi_comm to compare all input files for common SNPs
"${script_dir}"/multi_comm.sh  "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv


# NOTE: if any errors occur in this step, they are also likely to occur in the step below as the code is very similar #


#echo "$(comm -12 "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv
#echo "Done generating file of shared snps"
#echo "$(cut -d ' ' -f 1 "${out_dir}"/"${output_name}"_sharedsnps.tsv > "${out_dir}"/"${output_name}"_shared_alleles.tsv




# Generate map file for the combined dataset #
# The below code generating the map files is based on the code above
for i in "${datasets[@]}"; do
  echo "Generating map file for "${dtst}" in directory "${i}""
  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
  # remove the first line as it contains header
  tail -n +2  "${i}"/*_allchr.pdat | gawk '{print 0,$1,0,0}' > "${i}"/"${dtst}".map
  echo "Finished generating map file for "${dtst}""
done
echo "Completed Generating map files for datasets"

"${script_dir}"/multi_comm.sh "${out_dir}"/*_tempmap1.tsv > "${out_dir}"/"${output_name}"__tempmap2.tsv






# ########################### ########################### ########################### ########################### ##########################

#  tail -n +2  "${i}"/*_allchr.pdat | gawk '{print 0,$1,$0}' > "${out_dir}"/"${dtst}"_tempmap1.tsv
#tail -n +2 "${i}"/*_allchr.pdat > "${out_dir}"/"${dtst}"_temp_allchr.pdat
#sort --buffer-size=64 "${out_dir}"/"${dtst}"_temp_allchr.pdat -o "${out_dir}"/"${dtst}"_tempmap1.tsv
# Use the script multi_comm to compare all input files for common SNPs
# map file must contain a header since header was removed in the above for loop - take header from the first pdat file in array.
#gawk '{print 0,$1,0,0}' "${datasets[0]}"/*_allchr.pdat | head -n 1 > "${out_dir}"/"${output_name}".map
#gawk '{print 0,$1,0,0}' "${out_dir}"/"${output_name}"__tempmap2.tsv >> "${out_dir}"/"${output_name}".map
# ########################### ########################### ########################### ########################### ##########################




# Collect low quality SNPs
rm -rf "${out_dir}"/"${output_name}"_tempsnps.txt
for i in "${datasets[@]}"; do
  echo "Copying low quality snps for "${i}" to "${out_dir}" "
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
  --map "${i}"/"${dtst}".map \
  --extract "${out_dir}"/"${output_name}"_sharedsnps.tsv \
  --exclude "${i}"/*_lq_all_snps.txt \
  --pheno *_phenogeno.tsv \
  --covar "${i}"/*covar* \
  --make-pgen \
  --out "${i}"/"${dtst}"_plink2_temp1
echo "converting "${i}" into plink1 format"
  plink2 --pfile "${i}"/"${dtst}"_plink2_temp1 \
  --make-bed \
  --out "${i}"/"${dtst}"_plink1_temp1
done








rm -rf "${out_dir}"/"${output_name}"_plink.txt
for i in "${datasets[@]}"; do
  echo "${i}"/"${dtst}"_plink_temp1 >> "${out_dir}"/"${output_name}"_plink.txt
done

plink2 --pmerge-list "${out_dir}"/"${output_name}"_plink.txt --make-pgen --out "${out_dir}"/"${output_name}"_temp2





## Step 3.2: Correct pfiles ##

# Once the files have been imported into plink format the chromosome and position information must be updated as they are currently null.
# To do this we will use information that is present within the pvar file.

echo "Generating files for "${output_name}" "


# Print the 3rd column called ID from the pvar file and split it based on ':' then take the first and second element. Take off the header and add a new header and add to new file
echo "Taking ID and splitting into chromosome and position for later use..."
gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${dataset_dir}"/"${output_name}"_temp.pvar | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' | tail -n+2 | sed '1i #CHROM POS' > "${dataset_dir}"/"${output_name}"_temp_chrpos.pvar


# Paste the original pvar and the new intermediate file into another intermediate file
echo "Making temporary file..."
paste "${dataset_dir}"/"${output_name}"_temp.pvar "${dataset_dir}"/"${output_name}"_temp_chrpos.pvar > "${dataset_dir}"/"${output_name}"_temp_w_chrpos.pvar



# Make a new pvar file with the corrected columns

echo "Make new pvar file with correct chromosome and position information..."
gawk 'BEGIN{FS="\t";OFS="\t"}{print $6,$7,$3,$4,$5}' "${dataset_dir}"/"${output_name}"_temp_w_chrpos.pvar > "${dataset_dir}"/"${output_name}"_temp_updated.pvar


# Copy the other pfiles with a matching name so that plink2 knows they are together.

echo "Copying other files in the set for plink compatibility..."
cp "${dataset_dir}"/"${output_name}"_temp.psam "${dataset_dir}"/"${output_name}"_temp_updated.psam
cp  "${dataset_dir}"/"${output_name}"_temp.pgen "${dataset_dir}"/"${output_name}"_temp_updated.pgen
echo "Done"
