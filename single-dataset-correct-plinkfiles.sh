#!/bin/bash
# Exit on the first failed command, including a failure in the middle of a pipeline.
set -eo pipefail

########################################################################

Help()
{
   # Display help
    printf "
    Import one or more converted datasets into PLINK and fill in chromosome and\n"
    printf "    position on the PLINK 1 files. Datasets are not merged, and there is no\n"
    printf "    shared-SNP list. The script stops at the first failed command.\n\n"
    printf "Usage:\n\n"
    echo "single-dataset-correct-plinkfiles.sh -d DIR [-d DIR ...] -n PREFIX -o OUTDIR"
    echo ""
    echo "-d    Dataset directory. Pass once per directory. Files are named from the"
    echo "      folder name, not from -n. A folder named SHARE must contain"
    echo "      SHARE_allchr.pdat, SHARE_allchr.pfam, SHARE_pheno.tsv, and SHARE_covar.tsv."
    echo "-o    Directory for the low-quality SNP list copied from the dataset directories."
    echo "-n    Prefix for that low-quality SNP list."
    echo "-h    Print this help."
    echo ""
}

# input arguments
while getopts ":d:o:n:h" option;
do
   case $option in
        d)
            datasets+=("$OPTARG")
            ;;
        o)
            out_dir="$OPTARG"
            ;;
        n)
            output_name="$OPTARG"
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
if [ ${#datasets[@]} -eq 0 ] || [ -z "${out_dir}" ] || [ -z "${output_name}" ]
then
    printf "Error: Missing argument(s). See usage below."
    Help
    exit 1
fi

# sense check given dataset directories exist
for dir in "${datasets[@]}"
do
    if [ ! -d "$dir" ]
    then
        printf "\n\" $dir \" does not seem to be a valid directory, "
        printf "please check the directories passed with -d\n\n"
        exit 1
    fi
done

# display a helpful message of inputs
printf "\nUsing directories (-d):\n"

for dir in "${datasets[@]}"
do
    printf "\n\t $dir"
done

printf "\n\nOuputting to (-o): ${out_dir}\n"
printf "\nOutput file prefix (-n): ${output_name}\n\n"


########################################################################


# Collect low quality SNPs
rm -rf "${out_dir}"/"${output_name}"_tempsnps.txt
for i in "${datasets[@]}"; do
  echo "Copying low quality snps for "${i}" to "${out_dir}" "
cat "${i}"/*_all_chr_lq_all_snps.txt >> "${out_dir}"/"${output_name}"_tempsnps.txt
done
echo "Finished combining low quality SNPs"

# Keep only unique entries
sort "${out_dir}"/"${output_name}"_tempsnps.txt | uniq -u > "${out_dir}"/"${output_name}"_lq_all_snps.txt


# One dataset has no second SNP list to intersect. Build the map from its own .pdat.
for i in "${datasets[@]}"; do
  dtst=$(basename "$i")
  echo "Generating map file for "${dtst}" in directory "${i}""
  tail -n +2 "${i}"/"${dtst}"_allchr.pdat | gawk '{print 0,$1,0,0}' > "${i}"/"${dtst}".map
  echo "Finished generating map file for "${dtst}""
done


for i in "${datasets[@]}"; do
  echo "importing "${i}" into plink2 format"
  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
  plink2 --import-dosage "${i}"/"${dtst}"_allchr.pdat \
  --psam "${i}"/"${dtst}"_allchr.pfam \
  --map "${i}"/"${dtst}".map \
  --exclude "${i}"/*_lq_all_snps.txt \
  --pheno "${i}"/"${dtst}"_pheno.tsv \
  --covar "${i}"/"${dtst}"_covar.tsv \
  --make-pgen \
  --out "${i}"/"${dtst}"_plink2_temp1
echo "converting "${i}" into plink1 format"
  plink2 --pfile "${i}"/"${dtst}"_plink2_temp1 \
  --make-bed \
  --out "${i}"/"${dtst}"_plink1_temp1
done

# Correct bfiles of plink1 files ##

for i in "${datasets[@]}"; do
  dtst=$(basename "$i")
  #gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${i}"/"${dtst}"_temp2*.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' > "${i}"/"${dtst}"_temp2_chrpos.bim
  gawk 'BEGIN{FS="\t"; OFS="\t"}{print $2}' "${i}"/"${dtst}"_plink1_temp1.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}'  > "${i}"/"${dtst}"_plink1_temp1_chrpos.bim


  paste "${i}"/"${dtst}"_plink1_temp1*.bim "${i}"/"${dtst}"_plink1_temp1_chrpos.bim > "${i}"/"${dtst}"_plink1_temp1_w_chrpos.bim
  #paste "${i}"/"${dtst}"_temp2.bim "${i}"/"${dtst}"_temp2_chrpos.bim > "${i}"/"${dtst}"_temp2_w_chrpos.bim


  #gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}'  "${i}"/"${dtst}"_temp2_w_chrpos.pvar > "${i}"/"${dtst}"_temp2_updated.pvar
  gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}' "${i}"/"${dtst}"_plink1_temp1_w_chrpos.bim  > "${i}"/"${dtst}"_plink1_temp1_updated.bim


  echo "Copying other files in the set for plink compatibility..."
  cp "${i}"/"${dtst}"_plink1_temp1.bed "${i}"/"${dtst}"_plink1_temp1_updated.bed
  cp  "${i}"/"${dtst}"_plink1_temp1.fam "${i}"/"${dtst}"_plink1_temp1_updated.fam
  echo "Done"
done




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
