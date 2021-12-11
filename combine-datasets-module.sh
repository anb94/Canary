#!/bin/bash

# manual input
# Path of the *allchr.pdat input files - (should be the dir used in ${dose2plinkout}"/"${dataset}" from convert-mac-module.sh)

########################################################################

Help() {
   # Display help
    printf "
    This script combines datasets.\n\n"
    printf "Usage:\n\n"
    echo "-d    Directories of datasets to combine, pass once per directory."
    echo "-o    Output directory, for outputting data."
    echo "-n    dataset output naming prefix, for naming things."
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
for arg in "$datasets" "$out_dir" "$output_name"
do
    if [ -z ${arg+x} ];
    then
        printf "Error: Missing argument(s). See usage below."
        Help
        exit 1
    fi
done

# sense check given consent directories exist, can also check for correct data etc.
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
printf "\nCombining directories (-d):\n"

for dir in "${datasets[@]}"
do
    printf "\n\t $dir"
done


printf "\n\nOuputting to (-o): ${out_dir}\n"
printf "\nOutput file prefix (-n): ${output_name}\n\n"



printf "output dir: ${out_dir}"


#### Define recursive_comm function that will be used in later steps to recurvisely compare files:



#### Define recursive_comm function that will be used in later steps to recurvisely compare files:
function recursive_comm {
    # function to get all common snps between an array of files
    # expects a single input of an array of files to compare
    arr=( "$@" )

    if [ "${#arr[@]}" -eq 2 ]; then
        comm -12 "${arr[0]}" "${arr[1]}"
    else
        # get current file and drop from array
        currFile="${arr[0]}"
        arr=("${arr[@]:1}")

        comm -12 "$currFile" <(recursive_comm "${arr[@]}")
    fi
}




############### Pipeline Start ###############


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



# build array of all snp-set tsvs in given output dir
IFS=$'\n'
snp_set_files=($(find "${out_dir}" -name "*_snp-set.tsv"))
unset IFS

# find all common snps between files
recursive_comm "${snp_set_files[@]}" > "${out_dir}"/"${output_name}"_sharedsnps.tsv

echo "Generating file of shared snps between the datasets"
# Use the script multi_comm to compare all input files for common SNPs
recursive_comm  "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv


# NOTE: if any errors occur in this step, they are also likely to occur in the step below as the code is very similar #


#echo "$(comm -12 "${out_dir}"/*_snp-set.tsv > "${out_dir}"/"${output_name}"_sharedsnps.tsv
#echo "Done generating file of shared snps"
#echo "$(cut -d ' ' -f 1 "${out_dir}"/"${output_name}"_sharedsnps.tsv > "${out_dir}"/"${output_name}"_shared_alleles.tsv




# Generate map file for the combined dataset #
# The below code generating the map files is based on the code above
for i in "${datasets[@]}"; do

  #take name of folder as the name for each individual dataset
  dtst=$(basename "$i")
    echo "Generating map file for "${dtst}" in directory "${i}""
  # remove the first line as it contains header
  tail -n +2  "${i}"/*_allchr.pdat | gawk '{print 0,$1,0,0}' > "${i}"/"${dtst}".map
  echo "Finished generating map file for "${dtst}""
done
echo "Completed Generating map files for datasets"




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
  --psam "${i}"/"${dtst}"_allchr.pfam \
  --map "${i}"/"${dtst}".map \
  --extract "${out_dir}"/"${output_name}"_sharedsnps.tsv \
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



rm -rf "${out_dir}"/"${output_name}"_plink1.txt
for i in "${datasets[@]}"; do
  dtst=$(basename "$i")
  echo "${i}"/"${dtst}"_plink1_temp1 >> "${out_dir}"/"${output_name}"_plink1.txt
done

#rm -rf "${out_dir}"/"${output_name}"_plink2.txt
#for i in "${datasets[@]}"; do
#  dtst=$(basename "$i")
#  echo "${i}"/"${dtst}"_plink2_temp1 >> "${out_dir}"/"${output_name}"_plink2.txt
#done



plink --merge-list "${out_dir}"/"${output_name}"_plink1.txt --make-bed --out "${out_dir}"/"${output_name}"_temp2
#plink2 --pmerge "${dataset_1_dir}"/WHIMS_dataset_plink2_temp1 "${dataset_2_dir}"/GARNET_dataset_plink2_temp1 --make-pgen --out "${out_dir}"/"${output_name}"_temp2



# Correct bfiles of plink1 files ##

#gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${out_dir}"/"${output_name}"_temp2*.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' > "${out_dir}"/"${output_name}"_temp2_chrpos.bim
gawk 'BEGIN{FS="\t"; OFS="\t"}{print $2}' "${out_dir}"/"${output_name}"_temp2.bim | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}'  > "${out_dir}"/"${output_name}"_temp2_chrpos.bim


paste "${out_dir}"/"${output_name}"_temp2*.bim "${out_dir}"/"${output_name}"_temp2_chrpos.bim > "${out_dir}"/"${output_name}"_temp2_w_chrpos.bim
#paste "${out_dir}"/"${output_name}"_temp2.bim "${out_dir}"/"${output_name}"_temp2_chrpos.bim > "${out_dir}"/"${output_name}"_temp2_w_chrpos.bim


#gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}'  "${out_dir}"/"${output_name}"_temp2_w_chrpos.pvar > "${out_dir}"/"${output_name}"_temp2_updated.pvar
gawk 'BEGIN{FS="\t";OFS="\t"}{print $7,$2,$3,$8,$5, $6}' "${out_dir}"/"${output_name}"_temp2_w_chrpos.bim  > "${out_dir}"/"${output_name}"_temp2_updated.bim


echo "Copying other files in the set for plink compatibility..."
cp "${out_dir}"/"${output_name}"_temp2.bed "${out_dir}"/"${output_name}"_temp2_updated.bed
cp  "${out_dir}"/"${output_name}"_temp2.fam "${out_dir}"/"${output_name}"_temp2_updated.fam
echo "Done"


## Correct pfiles of plink2 files ##

# Once the files have been imported into plink format the chromosome and position information must be updated as they are currently null.
# To do this we will use information that is present within the pvar file.

#echo "Generating files for "${output_name}" "


# Print the 3rd column called ID from the pvar file and split it based on ':' then take the first and second element. Take off the header and add a new header and add to new file
#echo "Taking ID and splitting into chromosome and position for later use..."
#gawk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${out_dir}"/"${output_name}"_temp2*.pvar | gawk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' | tail -n+2 | sed '1i #CHROM POS' > "${out_dir}"/"${output_name}"_temp2_chrpos.pvar


# Paste the original pvar and the new intermediate file into another intermediate file
#echo "Making temporary file..."
#paste "${out_dir}"/"${output_name}"_temp2*.pvar "${out_dir}"/"${output_name}"_temp2_chrpos.pvar > "${out_dir}"/"${output_name}"_temp2_w_chrpos.pvar



# Make a new pvar file with the corrected columns

#echo "Make new pvar file with correct chromosome and position information..."
#gawk 'BEGIN{FS="\t";OFS="\t"}{print $6,$7,$3,$4,$5}' "${out_dir}"/"${output_name}"_temp2_w_chrpos.pvar > "${out_dir}"/"${output_name}"_temp2_updated.pvar


# Copy the other pfiles with a matching name so that plink2 knows they are together.

#echo "Copying other files in the set for plink compatibility..."
#cp "${out_dir}"/"${output_name}"_temp2*.psam "${out_dir}"/"${output_name}"_temp2_updated.psam
#cp  "${out_dir}"/"${output_name}"_temp2*.pgen "${out_dir}"/"${output_name}"_temp2_updated.pgen
echo "Done"
