#!/bin/bash

#### THIS SCRIPT NEEDS A DOC STRING HERE TO EXPLAIN WHAT IT DOES
# This script will combine MaCH and minimac imputed data for consent groups from the same study. For example, it can combine the two consent groups of WHI SHARE data available from dbGaP.

Help()
{
   # Display help
    printf "
    This script combines MaCH and minimac imputed data for consent groups from the same study.\n\n"
    printf "Usage:\n\n"
    echo "-c    Directories containing consent data, pass once per directory."
    echo "-n    Project output naming prefix, for naming things."
    echo "-o    Output directory, for outputting data."
    echo "-h    Print this help."
    echo ""
}

# input arguments
while getopts ":c:n:o:h" option;
do
   case $option in
        c)
            consent_groups+=("$OPTARG")
            ;;
        n)
            project="$OPTARG"
            ;;
        o)
            out_dir="$OPTARG"
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
for arg in "$consent_groups" "$project" "$out_dir"
do
    if [ -n "${!arg}" ]
    then
        printf "Error: Missing argument(s). See usage below."
        Help
        exit 1
    fi
done

# sense check given consent directories exist, can also check for correct data etc.
for dir in "${consent_groups[@]}"
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

for dir in "${consent_groups[@]}"
do
    printf "\t $dir"
done

printf "\n\nName prefix: $project"
printf "\nOutput directory: $out_dir"


# create directory if doesn't already exist
if [[ "${out_dir: -1}" == "/" ]]
then
	# check for trailing slash and remove
	$out_dir="${outidr%?}"
fi

dose2plinkout="${out_dir}/${project}_dose2plinkout"
mkdir -p dose2plinkout
printf "Using output directory: $dose2plinkout"


# Prepare genotype data #


## Step 1: Combine datasets ##

# regex to find the info files grep '/.{0,}(?:chr)\d{1,2}.{0,}\.(info)$/gm'
#- NOTE needs to be done for the dose file too which isnt necesarrily ending in .dose
# may be .dose.c1 or .dose.c2 etc depending on consent group

# Concatenate consent groups
for i in "${consent_groups[@]}"; do
  for ((j=1; j<=22; j++)); do
    # for all consent groups find each chromosome .dose file and
    # add all consent groups chromsome file contents to a single .dose file
    echo "Concatenating ${project} consent group ${i} for chromosome ${j}"

    chr_dose_file=$(find -regextype posix-extended "${i}" -iregex ".*chr${j}.dose(\.)?[a-z0-9]*$")

    # sense check only 1 file found, decide how to handle more later
    if [ $(echo "$files" | wc -w) >  1 ]
    then
		printf "Found more than one .dose file for chromosome ${j} in ${consent_groups[0]}\n"
		printf "${chr_info_file}"
		printf "Should probably do something about this as there should be one"
    fi

    # define file to add contents to
    combined_dose_file="${out_dir}/${project}_chr${j}.dose"

    cat $chr_dose_file >> $combined_dose_file
  done
done
echo "Completed Concatenating ${project} Consent Groups"


# As all info files in the study should be identical, copy info files
# from only first consent group
for ((i=1; i<=22; i++)); do
  echo "Copying ${project} info file for for chromosome ${i}"

    # find file for given chromosome in consent group dir
    chr_info_file=$(find -E "${consent_groups[0]}" -iregex ".*chr${i}.info$")

    # sense check only 1 file found, decide how to handle more later
    if [ $(echo "$files" | wc -w) >  1 ]
    then
		printf "Found more than one .info file for chromosome ${i} in ${consent_groups[0]}\n"
		printf "${chr_info_file}"
		printf "Should probably do something about this as there should be one"
    fi

    # set destination dir to be specified out dir and name by project and chromosome
    destination="${out_dir}/${project}_chr${i}.info"

    cp "$chr_info_file" "$destination"
done


## Step 2: Identify low quality Quality SNPs ##

for ((i=1; i<=22; i++)); do
  echo "Generating low quality SNPs"
  echo "Doing Chromosome number ${i}"

  awk '{if ($7 < 0.3) print $1}' "${out_dir}"/"${project}"_chr"${i}".info > "${out_dir}"/"${project}"_chr"${i}"_lq03_snps.txt
  awk '{if ($7 < 0.8) print $1}' "${out_dir}"/"${project}"_chr"${i}".info > "${out_dir}"/"${project}"_chr"${i}"_lq08_snps.txt
done

echo "Completed Generating low quality SNPs"


# The low quality SNPs files for each chromosome need to be combined into a single file.

# Append the low qual 0.3 snp files to a combined file
for ((i=1; i<=22; i++)); do
  echo "Doing lq03 ${i}"
  cat "${out_dir}"/"${project}"_chr"${i}"_lq03_snps.txt >> "${out_dir}"/"${project}"_all_chr_lq03_snps.txt
done

# Append the low qual 0.8 snp files to a combined file
for ((i=1; i<=22; i++)); do
  echo "Doing lq08 ${i}"
  cat "${out_dir}"/"${project}"_chr"${i}"_lq08_snps.txt >> "${out_dir}"/"${project}"_all_chr_lq08_snps.txt
done


cat "${out_dir}"/"${project}"_all_chr_lq03_snps.txt > "${out_dir}"/"${project}"_all_chr_lq_all_snps.txt
cat "${out_dir}"/"${project}"_all_chr_lq08_snps.txt >> "${out_dir}"/"${project}"_all_chr_lq_all_snps.txt


## Step 3: Check input file dimensions Quality control ##


# For each chromosome, the number of rows in .info should equal n-1 of number of columns in .dose
# This information will be retreived using awk and stored in a log file within the ethnicities directory.

#### NOTE ---- CHANGE THIS TO ASK DO THEY EQUAL eachother with n-1 since one has header as a QC
# e.g. Chromosome '2' info has '1765129' rows and dose has '1765130' columns  columns is 1 more than rows

for ((i=1; i<=22; i++)); do
  echo "Doing Chromosome ${i}"
  info=$(gawk 'END{print NR}' "${out_dir}"/"${project}"_chr"${i}".info)
  dose=$(gawk 'END{print NF}' "${out_dir}"/"${project}"_chr"${i}".dose)
  echo "Chromosome '${i}' info has '${info}' rows and dose has '${dose}' columns"  >> "${out_dir}"/"${project}"_qc-checklength.log
done



## Step 4: Convert MaCH or minimac input files into plink compatible dosage files ##

# Use the dose2plink to convert .dose and .info to .pdat and .pfam:

for ((i=1; i<=22; i++)); do
    echo "Converting .info and .dose for Chromosome ${i}"
    dose2plink -m 15000 --dose "${out_dir}"/"${project}"_chr"${i}".dose --info "${out_dir}"/"${project}"_chr"${i}".info -gz 0 --out "${dose2plinkout}"/"${project}"_chr"${i}"
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
