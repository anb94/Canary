#!/bin/bash

#dataset_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/test_combine
#dataset=whi_test


########################################################################

# JETHRO CREATE INPUT HERE

Help()
{
   # Display help
    printf "
    This script combines MaCH and minimac imputed data for consent groups from the same study.\n\n"
    printf "Usage:\n\n"
    echo "-d    Directories containing the dataset, pass once per directory."
    echo "-n    dataset output naming prefix, for naming things."
    echo "-h    Print this help."
    echo ""
}

# input arguments
while getopts ":d:n:h" option;
do
   case $option in
        d)
            dataset_dir="$OPTARG"
            ;;
        n)
            dataset="$OPTARG"
            ;;
        h)
            Help
            exit 1
            ;;
        \?)
            printf "\nInvalid option passed: -$OPTARG. See usage below.\n"
            Help
            exit 1
            ;;
   esac
done

# display help on passing no arguments
if [ $OPTIND -eq 1 ];
then
    Help
    exit 1
fi

# check all args given
for arg in "$dataset_dir" "$dataset"
do
    if [ -n "${!arg}" ]
    then
        printf "Error: Missing argument(s). See usage below."
        Help
        exit 1
    fi
done


# display a helpful message of inputs
printf "\nUsing specified arguments:\n"
printf "\nDataset directories:\n"

printf "\n $dataset_dir \n"

printf "\n\nName prefix: $dataset\n"


########################################################################


# Correct bfiles of plink1 files ##

#gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${dataset_dir}"/"${dataset}"_temp2*.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' > "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim
gawk 'BEGIN{FS="\t"; OFS="\t"}{print $2}' "${dataset_dir}"/"${dataset}"_temp2.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}'  > "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim


paste "${dataset_dir}"/"${dataset}"_temp2*.bim "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim > "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.bim
paste "${dataset_dir}"/"${dataset}"_temp2.bim "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim > "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.bim


#gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}'  "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.pvar > "${dataset_dir}"/"${dataset}"_temp2_updated.pvar
gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}' "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.bim  > "${dataset_dir}"/"${dataset}"_temp2_updated.bim


echo "Copying other files in the set for plink compatibility..."
cp "${dataset_dir}"/"${dataset}"_temp2.bed "${dataset_dir}"/"${dataset}"_temp2_updated.bed
cp  "${dataset_dir}"/"${dataset}"_temp2.fam "${dataset_dir}"/"${dataset}"_temp2_updated.fam
echo "Done"




## Step 3.2: Correct pfiles ##

# Once the files have been imported into plink format the chromosome and position information must be updated as they are currently null.
# To do this we will use information that is present within the pvar file.

#echo "Generating files for '${dataset}' "


# Print the 3rd column called ID from the pvar file and split it based on ':' then take the first and second element. Take off the header and add a new header and add to new file
#echo "Taking ID and splitting into chromosome and position for later use..."
#gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${dataset_dir}"/"${dataset}"_temp.pvar | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' | tail -n+2 | sed '1i #CHROM POS' > "${dataset_dir}"/"${dataset}"_temp_chrpos.pvar


# Paste the original pvar and the new intermediate file into another intermediate file
#echo "Making temporary file..."
#paste "${dataset_dir}"/"${dataset}"_temp.pvar "${dataset_dir}"/"${dataset}"_temp_chrpos.pvar > "${dataset_dir}"/"${dataset}"_temp_w_chrpos.pvar



# Make a new pvar file with the corrected columns

#echo "Make new pvar file with correct chromosome and position information..."
#gawk 'BEGIN{FS="\t";OFS="\t"}{print $6,$7,$3,$4,$5}' "${dataset_dir}"/"${dataset}"_temp_w_chrpos.pvar > "${dataset_dir}"/"${dataset}"_temp_updated.pvar


# Copy the other pfiles with a matching name so that plink2 knows they are together.

#echo "Copying other files in the set for plink compatibility..."
#cp "${dataset_dir}"/"${dataset}"_temp.psam "${dataset_dir}"/"${dataset}"_temp_updated.psam
#cp  "${dataset_dir}"/"${dataset}"_temp.pgen "${dataset_dir}"/"${dataset}"_temp_updated.pgen
#echo "Done"
