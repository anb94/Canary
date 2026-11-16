#!/bin/bash

########################################################################


Help()
{
   # Display help
    printf "
    This script imports one converted MaCH dataset into PLINK and corrects chromosome and position in the PLINK1 files.\n\n"
    printf "Usage:\n\n"
    echo "-d    Directory containing the converted dataset."
    echo "-n    dataset output naming prefix, the same prefix passed to convert-mac-module.sh."
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
if [ -z "${dataset_dir}" ] || [ -z "${dataset}" ]
then
    printf "Error: Missing argument(s). See usage below."
    Help
    exit 1
fi

if [ ! -d "$dataset_dir" ]
then
    printf "\n\" $dataset_dir \" does not seem to be a valid directory, "
    printf "please check the directory passed with -d\n\n"
    exit 1
fi


# display a helpful message of inputs
printf "\nUsing specified arguments:\n"
printf "\nDataset directory:\n"

printf "\n $dataset_dir \n"

printf "\n\nName prefix: $dataset\n"


########################################################################


# One dataset has no second SNP list to intersect. Build the map from its own .pdat,
# then import that dosage file. Chromosome and position are filled in afterwards.
echo "Generating map file for ${dataset}"
tail -n +2 "${dataset_dir}"/"${dataset}"_allchr.pdat | gawk '{print 0,$1,0,0}' > "${dataset_dir}"/"${dataset}".map

echo "importing ${dataset} into plink2 format"
plink2 --import-dosage "${dataset_dir}"/"${dataset}"_allchr.pdat \
  --psam "${dataset_dir}"/"${dataset}"_allchr.pfam \
  --map "${dataset_dir}"/"${dataset}".map \
  --exclude "${dataset_dir}"/"${dataset}"_all_chr_lq_all_snps.txt \
  --pheno "${dataset_dir}"/"${dataset}"_pheno.tsv \
  --covar "${dataset_dir}"/"${dataset}"_covar.tsv \
  --make-pgen \
  --out "${dataset_dir}"/"${dataset}"_plink2_temp1

echo "converting ${dataset} into plink1 format"
plink2 --pfile "${dataset_dir}"/"${dataset}"_plink2_temp1 \
  --make-bed \
  --out "${dataset_dir}"/"${dataset}"_plink1_temp1


# Correct bfiles of plink1 files ##

#gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${dataset_dir}"/"${dataset}"_temp2*.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' > "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim
gawk 'BEGIN{FS="\t"; OFS="\t"}{print $2}' "${dataset_dir}"/"${dataset}"_plink1_temp1.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}'  > "${dataset_dir}"/"${dataset}"_plink1_temp1_chrpos.bim


paste "${dataset_dir}"/"${dataset}"_plink1_temp1*.bim "${dataset_dir}"/"${dataset}"_plink1_temp1_chrpos.bim > "${dataset_dir}"/"${dataset}"_plink1_temp1_w_chrpos.bim
#paste "${dataset_dir}"/"${dataset}"_temp2.bim "${dataset_dir}"/"${dataset}"_temp2_chrpos.bim > "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.bim


#gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}'  "${dataset_dir}"/"${dataset}"_temp2_w_chrpos.pvar > "${dataset_dir}"/"${dataset}"_temp2_updated.pvar
gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}' "${dataset_dir}"/"${dataset}"_plink1_temp1_w_chrpos.bim  > "${dataset_dir}"/"${dataset}"_plink1_temp1_updated.bim


echo "Copying other files in the set for plink compatibility..."
cp "${dataset_dir}"/"${dataset}"_plink1_temp1.bed "${dataset_dir}"/"${dataset}"_plink1_temp1_updated.bed
cp  "${dataset_dir}"/"${dataset}"_plink1_temp1.fam "${dataset_dir}"/"${dataset}"_plink1_temp1_updated.fam
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
