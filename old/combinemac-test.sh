project=WHIMS
consent1=/home/anbennett2/scratch/datasets/raw_data/dbgap_data/746/c1/phg000592.v1.WHIMS.genotype-imputed-data.c1/
consent2=/home/anbennett2/scratch/datasets/raw_data/dbgap_data/746/c2/phg000592.v1.WHIMS.genotype-imputed-data.c2/

consent_groups=()
consent_groups=(${consent1} ${consent2})
out_dir=/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/
dose2plinkout=/scratch/anbennett2/datasets/processed_data/dbgap/WHI/dose2plinkout/

# Prepare genotype data #


## Step 1: Combine datasets ##


# Concatenate consent groups
for i in "${consent_groups[@]}"; do
  for ((j=1; j<=22; j++)); do
    echo "Concatenating ${project} consent group ${i} for chromosome ${j}"
    cat "${i}"/*chr"${j}"*.dose* >> "${out_dir}"/"${project}"_chr"${j}".dose
  done
done
echo "Completed Concatenating ${project} Consent Groups"


# As all info files in the study should be identical, copy info files from only one consent group
for ((i=1; i<=22; i++)); do
  echo "Copying ${project} info file for for chromosome ${i}"
  cp "${consent_groups[0]}"/*chr"${i}"*.info* "${out_dir}"/"${project}"_chr"${i}".info
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
  echo "Doing lq03 ${i}"
  cat "${out_dir}"/"${project}"_chr"${i}"_lq08_snps.txt >> "${out_dir}"/"${project}"_all_chr_lq08_snps.txt
done


cat "${out_dir}"/"${project}"_all_chr_lq03_snps.txt > "${out_dir}"/"${project}"_all_chr_lq_all_snps.txt
cat "${out_dir}"/"${project}"_all_chr_lq08_snps.txt >> "${out_dir}"/"${project}"_all_chr_lq_all_snps.txt




## Step 3: Check input file dimensions Quality control ##


# For each chromosome, the number of rows in .info should equal n-1 of number of columns in .dose
# This information will be retreived using awk and stored in a log file within the ethnicities directory.

#### NOTE ---- CHANGE THIS TO ASK DO THEY EQUAL eachother with n-1 since one has header as a QC
# Chromosome '2' info has '1765129' rows and dose has '1765130' columns  columns is 1 more than rows

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
    dose2plink -m 7000 -dose "${out_dir}"/"${project}"_chr"${i}".dose -info "${out_dir}"/"${project}"_chr"${i}".info -gz 0 -out "${dose2plinkout}"/"${project}"_chr"${i}"
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
