#!/bin/bash

Help()
{
   # Display help
    printf "
    This script does something, I'm not entirely sure what, but it's definitely
    something to do with science. And data. GWAS, more like GWHAT.\n\n"
    printf "Usage:\n\n"
    echo "-c    Directories containing consent data, pass once per directory."
    echo "-n    Output naming prefix, for naming things."
    echo "-o    Output directory, for outputting data."
    echo "-b    Base directory, the directory of the base."
    echo "-h    Print this help."
    echo ""
}

# input arguments
while getopts ":c:n:o:b:h" option;
do
   case $option in
        c)
            consent_dir+=("$OPTARG")
            ;;
        n)
            name="$OPTARG"
            ;;
        o)
            out_dir="$OPTARG"
            ;;
        b)
            base_dir="$OPTARG"
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
for arg in "$consent_dir" "$name" "$out_dir" "$base_dir"
do
    if [ -n "${!arg}" ]
    then
        printf "Error: Missing argument(s). See usage below."
        Help
        exit 1
    fi        
done

# sense check given consent directories exist, can also check for correct data etc.
for dir in "${consent_dir[@]}"
do
    if [ ! -d "$dir" ]
    then
        printf "\n\" $dir \" does not seem to be a valid directory, "
        printf "please check the directories passed with -c\n\n"
        exit 1
    fi
done

# display a helpful message of inputs
printf "\nUsing specified arguments:\n"
printf "\nConsent directories:\n"

for dir in "${consent_dir[@]}"
do
    printf "\t $dir"
done

printf "\n\nName prefix: $name"
printf "\nOutput directory: $out_dir"
printf "\nBase directory: $base_dir\n\n"


#######################################
## you access elements of the array like this xo

# for dir in "${consent_dir[@]}"; do
#     echo "$dir"
# done
#######################################

# create directory if doesn't already exist
if [[ "${out_dir: -1}" == "/" ]]
then
	# check for trailing slash and remove
	$out_dir="${outidr%?}"
fi
dose2plinkout="${out_dir}/${name}_dose2plinkout"
mkdir -p dose2plinkout
printf "Using output directory: $dose2plinkout"




# OPTIONS ARE TO CREATE THE FOLLOWING:

# Define base directory:
# dataset_base_dir=$HOME/SAP2-GWAS/datasets/


# project name - for naming files
# project=TEST

# # consent groups not just to but equal to n that the user inputs
# c1_dataset_dir=$HOME/indir_1
# c2_dataset_dir=$HOME/indir_2
#... etc etc to how many they have

# an array containing the all consent groups that the user input so that commands are carried out on the array
# consent_groups=(c1_dataset_dir, c2_dataset_dir...etc)

# out directory for the combined files
# cb_dataset_dir=$HOME/outdir_cb

########################################################################



# Prepare genotype data #


## Step 1: Combine datasets ##



# Concatenate consent groups
for i in "${consent_groups[@]}"; do
  for ((j=1; j<=22; j++)); do
    echo "Concatenating ${project} consent group ${i} for chromosome ${j}"
    cat "${i}"/*chr"${j}"*.dose* >> "${cb_dataset_dir}"/"${project}"_chr"${j}".dose
  done
done
echo "Completed Concatenating ${project} Consent Groups"


# As all info files in the study should be identical, copy info files from only one consent group
for ((i=1; i<=22; j++)); do
  echo "Copying ${project} info file for for chromosome ${i}"
  cp "${consent_groups[0]}"/*chr"${i}"*.info* "${cb_dataset_dir}"/"${project}"_chr"${i}".info
done



## Step 2: Identify low quality Quality SNPs ##

for ((i=1; i<=22; i++)); do
  echo "Generating low quality SNPs"
  echo "Doing Chromosome number ${i}"

  awk '{if ($7 < 0.3) print $1}' "${cb_dataset_dir}"/"${project}"_chr"${i}".dose > "${cb_dataset_dir}"/"${project}"_chr"${i}"_lq03_snps.txt
  awk '{if ($7 < 0.8) print $1}' "${cb_dataset_dir}"/"${project}"_chr"${i}".dose > "${cb_dataset_dir}"/"${project}"_chr"${i}"_lq08_snps.txt
done

echo "Completed Generating low quality SNPs"


# The low quality SNPs files for each chromosome need to be combined into a single file.

# Append the low qual 0.3 snp files to a combined file
for ((i=1; i<=22; i++)); do
  echo "Doing lq03 ${i}"
  cat "${cb_dataset_dir}"/"${project}"_chr"${i}"_lq03_snps.txt >> "${cb_dataset_dir}"/"${project}"_all_chr_lq03_snps.txt
done

# Append the low qual 0.8 snp files to a combined file
for ((i=1; i<=22; i++)); do
  echo "Doing lq03 ${i}"
  cat "${cb_dataset_dir}"/"${project}"_chr"${i}"_lq08_snps.txt >> "${cb_dataset_dir}"/"${project}"_all_chr_lq08_snps.txt
done


cat "${cb_dataset_dir}"/"${project}"_all_chr_lq03_snps.txt > "${cb_dataset_dir}"/"${project}"_all_chr_lq_all_snps.txt
cat "${cb_dataset_dir}"/"${project}"_all_chr_lq08_snps.txt >> "${cb_dataset_dir}"/"${project}"_all_chr_lq_all_snps.txt




## Step 3: Check input file dimensions Quality control ##


# For each chromosome, the number of rows in .info should equal n-1 of number of columns in .dose
# This information will be retreived using awk and stored in a log file within the ethnicities directory.

#### NOTE ---- CHANGE THIS TO ASK DO THEY EQUAL eachother with n-1 since one has header as a QC

for ((i=1; i<=22; i++)); do
  echo "Doing Chromosome ${i}"
  info=$(awk 'END{print NR}' "${cb_dataset_dir}"/"${project}"_chr"${i}".info)
  dose=$(awk 'END{print NF}'  "${cb_dataset_dir}"/"${project}"_chr"${i}".dose)
  echo "Chromosome ${i} info has ${info} rows and dose has ${dose} columns"  >> "${cb_dataset_dir}"/"${project}"_qc-checklength.log
done



## Step 4: Convert MaCH or minimac input files into plink compatible dosage files ##


  # This step needs to be performed on a machine/container which has installed dose2plink.c
  # A singularity definition file which includes dose2plink.c can be found at https://github.com/anb94/gwas_pancan/blob/master/singularity_images/custom_singularity_images/canary_v4.def

  # Use the dose2plink to convert .dose and .info to .pdat and .pfam:


for ((i=10; i<=22; i++)); do
    echo "Converting .info and .dose for Chromosome ${i}"
    dose2plink -m 7000 -dose "${cb_dataset_dir}"/"${project}"_chr"${i}".dose -info "${cb_dataset_dir}"/"${project}"_chr"${i}".info -gz 0 -out "${dose2plinkout}"/"${project}"_chr"${i}"
done
echo "Completed dose2plink conversion"



## Step 5: Combine the chromosomes for each dataset into a single file ##

# The pdat files for each chromosome need to be combined into a single file.
# Add the first file into a new pdat file and then append the rest of the fiels without the header
cat "${dose2plinkout}"/"${project}"_chr1.pdat > "${dose2plinkout}"/"${project}"_allchr.pdat
for ((i=2; i<=22; i++)); do
    echo "Doing "${project}"_chr${i}"
    cat "${dose2plinkout}"/"${project}"_chr"${i}".pdat | tail -n +2 >> "${dose2plinkout}"/"${project}"_allchr.pdat
done
