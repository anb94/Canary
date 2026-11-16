#!/bin/bash
# Exit on the first failed command, including a failure in the middle of a pipeline.
set -eo pipefail

#### 
# This script converts MaCH and minimac mlinfo and mldose imputed data into PLINK compatible files.

Help()
{
   # Display help
    printf "
    Concatenate MaCH/minimac .dose files across consent groups and convert them\n"
    printf "    to PLINK dosage files (.pdat and .pfam). This script does not run PLINK.\n\n"
    printf "Usage:\n\n"
    echo "convert-mac-module.sh -c DIR [-c DIR ...] -n PREFIX -o OUTDIR"
    echo ""
    echo "-c    Consent-group directory. Pass once per directory."
    echo "      Expected names look like SHAREchr1aa.dose.c1 and SHAREchr1aa.info."
    echo "      A letter must follow the chromosome number so chromosome 1 does not"
    echo "      also match chromosomes 10-19. aa is African American, ha is Hispanic American."
    echo "-n    Prefix for the output files, for example SHARE. Writes SHARE_chrN.dose,"
    echo "      SHARE_allchr.pdat, and SHARE_allchr.pfam in the output directory."
    echo "-o    Output directory. A trailing slash is removed."
    echo "-h    Print this help."
    echo ""
    echo "The script stops at the first failed command. A re-run clears PREFIX_chr1.dose"
    echo "through PREFIX_chr22.dose before concatenating the consent groups again."
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
            dataset="$OPTARG"
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
if [ ${#consent_groups[@]} -eq 0 ] || [ -z "${dataset}" ] || [ -z "${out_dir}" ]
then
    printf "Error: Missing argument(s). See usage below."
    Help
    exit 1
fi

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

printf "\n\nName prefix: $dataset\n"

printf "\nOutput directory: $out_dir\n"


# create directory if doesn't already exist
if [[ "${out_dir: -1}" == "/" ]]
then
	# check for trailing slash and remove
	out_dir="${out_dir%/}"
fi

d2p="${out_dir}"/"${dataset}"_d2p
mkdir -p "${d2p}"
printf "\nUsing output directory: $d2p"


# Prepare genotype data #


## Step 1: Combine datasets ##

# regex to find the info files grep '/.{0,}(?:chr)\d{1,2}.{0,}\.(info)$/gm'
#- NOTE needs to be done for the dose file too which isnt necesarrily ending in .dose
# may be .dose.c1 or .dose.c2 etc depending on consent group

# Concatenate consent groups


# Clear this run's chromosome dose files first. >> below still appends each
# consent group onto the same chromosome; a re-run must not append onto the last run.
for ((j=1; j<=22; j++)); do
  rm -f "${out_dir}"/"${dataset}"_chr"${j}".dose
done

# Concatenate consent groups
for i in "${consent_groups[@]}"; do
  for ((j=1; j<=22; j++)); do
    echo "Concatenating ${dataset} consent group ${i} for chromosome ${j}"
    # [a-z] requires a letter immediately after the chromosome number.
    # SHAREchr1aa.dose.c1 matches chromosome 1. SHAREchr10aa.dose.c1 does not.
    cat "${i}"/*chr"${j}"[a-z]*.dose* >> "${out_dir}"/"${dataset}"_chr"${j}".dose
  done
done
echo "Completed Concatenating ${dataset} Consent Groups"



#for i in "${consent_groups[@]}"; do
#  for ((j=1; j<=22; j++)); do
    # for all consent groups find each chromosome .dose file and
    # add all consent groups chromsome file contents to a single .dose file
#    echo "Concatenating ${dataset} consent group ${i} for chromosome ${j}"
#    chr_dose_file=$(find -E "${i}" -iregex ".*chr${j}.dose(\.)?[a-z0-9]*$")

    # sense check only 1 file found, decide how to handle more later
    #if [ $(echo "$files" | wc -w) >  1 ]
    #then
		#printf "Found more than one .dose file for chromosome ${j} in ${consent_groups[0]}\n"
		#printf "${chr_info_file}"
		#printf "Should probably do something about this as there should be one"
    #fi

    # define file to add contents to
#    combined_dose_file="${out_dir}/${dataset}_chr${j}.dose"

#    cat $chr_dose_file >> $combined_dose_file
#  done
#done
#echo "Completed Concatenating ${dataset} Consent Groups"


# As all info files in the study should be identical, copy info files
# from only first consent group


# As all info files in the study should be identical, copy info files from only one consent group
for ((i=1; i<=22; i++)); do
  echo "Copying ${dataset} info file for for chromosome ${i}"
  # Same chromosome pattern as the .dose files above.
  cp "${consent_groups[0]}"/*chr"${i}"[a-z]*.info* "${out_dir}"/"${dataset}"_chr"${i}".info
done


#for ((i=1; i<=22; i++)); do
#  echo "Copying ${dataset} info file for for chromosome ${i}"
#
#    # find file for given chromosome in consent group dir
#    chr_info_file=$(find -E "${consent_groups[0]}" -iregex ".*chr${i}.info$")
#
##    # sense check only 1 file found, decide how to handle more later
#  if [ $(echo "$files" | wc -w) >  1 ]
#    then
#		printf "Found more than one .info file for chromosome ${i} in ${consent_groups[0]}\n"
#		printf "${chr_info_file}"
#		printf "Should probably do something about this as there should be one"
#    fi

    # set destination dir to be specified out dir and name by dataset and chromosome
#    destination="${out_dir}/${dataset}_chr${i}.info"

#    cp "$chr_info_file" "$destination"
#done


## Step 2: Identify low quality Quality SNPs ##

for ((i=1; i<=22; i++)); do
  echo "Generating low quality SNPs for "${dataset}" Chromosome number ${i}"

  gawk '{if ($7 < 0.3) print $1}' "${out_dir}"/"${dataset}"_chr"${i}".info > "${out_dir}"/"${dataset}"_chr"${i}"_lq03_snps.txt
  gawk '{if ($7 < 0.8) print $1}' "${out_dir}"/"${dataset}"_chr"${i}".info > "${out_dir}"/"${dataset}"_chr"${i}"_lq08_snps.txt
done
echo "Completed Generating low quality SNPs"


# The low quality SNPs files for each chromosome need to be combined into a single file.

# Append the low qual 0.3 snp files to a combined file
rm -f "${out_dir}"/"${dataset}"_all_chr_lq03_snps.txt
for ((i=1; i<=22; i++)); do
  echo "Collecting low quality (cut-off 0.03) for "${dataset}" chrosome ${i}"
  cat "${out_dir}"/"${dataset}"_chr"${i}"_lq03_snps.txt >> "${out_dir}"/"${dataset}"_all_chr_lq03_snps.txt
done

# Append the low qual 0.8 snp files to a combined file
rm -f "${out_dir}"/"${dataset}"_all_chr_lq08_snps.txt
for ((i=1; i<=22; i++)); do
  echo "Collecting low quality (cut-off 0.08) for "${dataset}" chrosome ${i}"
  cat "${out_dir}"/"${dataset}"_chr"${i}"_lq08_snps.txt >> "${out_dir}"/"${dataset}"_all_chr_lq08_snps.txt
done
echo "Completed collecting low quality SNPs"

echo "Combining low quality SNPs of all thresholds"
cat "${out_dir}"/"${dataset}"_all_chr_lq03_snps.txt > "${out_dir}"/"${dataset}"_all_chr_lq_all_snps.txt
cat "${out_dir}"/"${dataset}"_all_chr_lq08_snps.txt >> "${out_dir}"/"${dataset}"_all_chr_lq_all_snps.txt


## Step 3: Check input file dimensions Quality control ##


# For each chromosome, the number of rows in .info should equal n-1 of number of columns in .dose
# This information will be retreived using awk and stored in a log file within the ethnicities directory.

#### NOTE ---- CHANGE THIS TO ASK DO THEY EQUAL eachother with n-1 since one has header as a QC
# e.g. Chromosome '2' info has '1765129' rows and dose has '1765130' columns  columns is 1 more than rows

for ((i=1; i<=22; i++)); do
  echo "Generating QC for dose and info file length....Doing Chromosome ${i}"
  info=$(gawk 'END{print NR}' "${out_dir}"/"${dataset}"_chr"${i}".info)
  dose=$(gawk 'END{print NF}' "${out_dir}"/"${dataset}"_chr"${i}".dose)
  echo "Chromosome '${i}' info has '${info}' rows and dose has '${dose}' columns"  >> "${out_dir}"/"${dataset}"_qc-checklength.log
done



## Step 4: Convert MaCH or minimac input files into plink compatible dosage files ##

# Use the dose2plink to convert .dose and .info to .pdat and .pfam:


for ((i=1; i<=22; i++)); do
    echo "Converting .info and .dose for Chromosome ${i}"
    dose2plink -m 15000 --dose "${out_dir}"/"${dataset}"_chr"${i}".dose --info "${out_dir}"/"${dataset}"_chr"${i}".info -gz 0 --out "${d2p}"/"${dataset}"_chr"${i}"
done

echo "Completed dose2plink conversion"


## Step 5: Combine the chromosomes for each dataset into a single file ##

# The pdat files for each chromosome need to be combined into a single file.
# Add the first file into a new pdat file and then append the rest of the fiels without the header
cat "${d2p}"/"${dataset}"_chr1.pdat > "${out_dir}"/"${dataset}"_allchr.pdat
for ((i=2; i<=22; i++)); do
    echo "Doing "${dataset}"_chr${i}"
    cat "${d2p}"/"${dataset}"_chr"${i}".pdat | tail -n +2 >> "${out_dir}"/"${dataset}"_allchr.pdat
done

cp "${d2p}"/"${dataset}"_chr1.pfam "${out_dir}"/"${dataset}"_allchr.pfam
cp "${d2p}"/"${dataset}"_chr1.pfam "${out_dir}"/"${dataset}"_allchr.tsv


# NOTE: The completed files are stored in the outdir not d2p subfolder for convenience in later steps. Also, the individual files in d2p subfolder are no longer needed and can be deleted.
