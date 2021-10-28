#!/bin/bash

dataset_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/test_combine
output_name=whi_test


########################################################################

# JETHRO CREATE INPUT HERE










########################################################################

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
