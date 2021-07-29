#!/bin/bash









# PART 1: Prepare phenotype data #

## The phenotype data for the dataset must be extracted from the forms provided by dbGaP and put in a format accepted by plink and other tools. 
## Additionally, we will isolate covariates used in the analysis during this process.

## Define location of python script
pathtoscript=$HOME/SAP2-GWAS/gwas_pancan_scripts

./"${pathtoscript}"/generatephenodata.py








# PART 2: Prepare genotype data #

## Step 2.1: Combine datasets ##

## Define environment variables
### Define SHARE Root directory:
WHI_SHARE=$HOME/dbgap_data/WHI
### Define African American consent group 1 and 2 variables:
WHI_SHARE_aa_c1=${WHI_SHARE}/consentgroup_1/phenogeno/geno/746/phg000592.v1.WHI_SHARE_aa.genotype-imputed-data.c1
WHI_SHARE_aa_c2=${WHI_SHARE}/consentgroup_2/phenogeno/geno/746/phg000592.v1.WHI_SHARE_aa.genotype-imputed-data.c2
### Define Hispanic American consent group 1 and 2 variables:
WHI_SHARE_ha_c1=${WHI_SHARE}/consentgroup_1/phenogeno/geno/746/phg000592.v1.WHI_SHARE_ha.genotype-imputed-data.c1
WHI_SHARE_ha_c2=${WHI_SHARE}/consentgroup_2/phenogeno/geno/746/phg000592.v1.WHI_SHARE_ha.genotype-imputed-data.c2
### Define combined consent group directories:
WHI_SHARE_aa_cb=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_aa.genotype
WHI_SHARE_ha_cb=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_ha.genotype

## Concatenate consent groups 1 and 2 for African American
for ((i=1; i<=22; i++)); do
    echo "Concatenating African American c1 and c2 for chromosome ${i}"
    cat "${WHI_SHARE_aa_c1}"/SHAREchr"${i}"aa.dose.c1 "${WHI_SHARE_aa_c2}"/SHAREchr"${i}"aa.dose.c2 > "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.dose.cb
done
echo "Completed Concatenating African American Consent Groups"

## Concatenate consent groups 1 and 2 for Hispanic American
for ((i=1; i<=22; i++)); do
    echo "Concatenating Hispanic American c1 and c2 for chromosome ${i}"
    cat "${WHI_SHARE_ha_c1}"/SHAREchr"${i}"ha.dose.c1 "${WHI_SHARE_ha_c2}"/SHAREchr"${i}"ha.dose.c2 > "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.dose.cb
done
echo "Completed Concatenating Hispanic American Consent Groups"




## Step 2.2: Identify low quality Quality SNPs ##

## Define combined consent group directories:
WHI_SHARE_aa_cb_lq=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_aa.genotype/lowqualsnps
WHI_SHARE_ha_cb_lq=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_ha.genotype/lowqualsnps

for ((i=1; i<=22; i++)); do
    echo "Copying Files and Generating low quality SNPs for African Americans"
    echo "Doing Chromosome number ${i}"

    cp "${WHI_SHARE_aa_c1}"/SHAREchr${i}aa.info "${WHI_SHARE_aa_cb}"/SHAREchr${i}aa.info

    awk '{if ($7 < 0.3) print $1}' "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info > "${WHI_SHARE_aa_cb_lq}"/SHAREchr"${i}"aa_lq03_snps.txt
    awk '{if ($7 < 0.8) print $1}' "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info > "${WHI_SHARE_aa_cb_lq}"/SHAREchr"${i}"aa_lq08_snps.txt
done

echo "Completed Generating low quality SNPs for African Americans"

for ((i=1; i<=22; i++)); do
    echo "Copying Files and Generating low quality SNPs for Hispanic Americans"
    echo "Doing Chromosome number ${i}"

    cp "${WHI_SHARE_ha_c1}"/SHAREchr"${i}"ha.info "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info

    awk '{if ($7 < 0.3) print $1}' "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info > "${WHI_SHARE_ha_cb_lq}"/SHAREchr"${i}"ha_lq03_snps.txt
    awk '{if ($7 < 0.8) print $1}' "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info > "${WHI_SHARE_ha_cb_lq}"/SHAREchr"${i}"ha_lq08_snps.txt
done

echo "Completed Generating low quality SNPs for Hispanic Americans"

# The low quality SNPs files for each chromosome need to be combined into a single file.

## African American
## Append the low qual 0.3 snp files to a combined file

for ((i=1; i<=22; i++)); do
    echo "Doing SHARE_aa lq03 ${i}"
    cat "${WHI_SHARE_aa_cb_lq}"/SHAREchr"${i}"aa_lq03_snps.txt >> "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq03_snps.txt
done

## Append the low qual 0.8 snp files to a combined file
for ((i=1; i<=22; i++)); do
    echo "Doing SHARE_aa lq08 ${i}"
    cat "${WHI_SHARE_aa_cb_lq}"/SHAREchr"${i}"aa_lq08_snps.txt >> "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq08_snps.txt
done

cat "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq03_snps.txt >> "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq_all_snps.txt
cat "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq08_snps.txt >> "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq_all_snps.txt
## Hispanic American
## Append the low qual 0.3 snp files to a combined file
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_ha lq03 ${i}"
    cat "${WHI_SHARE_ha_cb_lq}"/SHAREchr"${i}"ha_lq03_snps.txt >> "${WHI_SHARE_ha_cb_lq}"/SHARE_ha_lq03_snps.txt
done

## Append the low qual 0.8 snp files to a combined file
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_ha lq08 ${i}"
    cat "${WHI_SHARE_ha_cb_lq}"/SHAREchr"${i}"ha_lq08_snps.txt >> "${WHI_SHARE_ha_cb_lq}"/SHARE_ha_lq08_snps.txt
done

cat "${WHI_SHARE_ha_cb_lq}"/SHARE_ha_lq03_snps.txt >> "${WHI_SHARE_ha_cb_lq}"/SHARE_ha_lq_all_snps.txt




## Step 2.3: Check input file dimensions Quality control ##


# For each chromosome, the number of rows in .info should equal n-1 of number of columns in .dose
# This information will be retreived using awk and stored in a log file within the ethnicities directory.

#### NOTE ---- CHANGE THIS TO ASK DO THEY EQUAL eachother with n-1 since one has header as a QC

# African American
for ((i=1; i<=22; i++)); do
    echo "Doing AA Chromosome ${i}"
    info=$(awk 'END{print NR}' "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info)
    dose=$(awk 'END{print NF}' "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.dose.cb)
    echo "Chromosome ${i} info has ${info} rows and dose has ${dose} columns"  >> "${WHI_SHARE_aa_cb}"/qc-checklength.log
done

# Hispanic American
for ((i=1; i<=22; i++)); do
    echo "Doing HA Chromosome ${i}"
    info=$(awk 'END{print NR}' "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info)
    dose=$(awk 'END{print NF}' "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.dose.cb)
    echo "Chromosome ${i} info has ${info} rows and dose has ${dose} columns"  >> "${WHI_SHARE_ha_cb}"/qc-checklength.log
done



## Step 2.4: Convert MaCH or minimac input files into plink compatible dosage files ##


# This step needs to be performed on a machine/container which has installed dose2plink.c 
# A singularity definition file which includes dose2plink.c can be found at https://github.com/anb94/gwas_pancan/blob/master/singularity_images/custom_singularity_images/canary_v4.def


# Use the dose2plink to convert African American group .dose and .info to .pdat and .pfam:
for ((i=10; i<=22; i++)); do
    echo "Converting .info and .dose for African American Chromosome ${i}"
    dose2plink -m 7000 -dose "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.dose.cb -info "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info -gz 0 -out "${WHI_SHARE_aa_cb}"/testing-dose2plinkout/SHAREchr"${i}"aa
done


echo "Completed African American Chromosomes"

# Use the dose2plink to convert Hispanic American group .dose and .info to .pdat and .pfam:
for ((i=1; i<=22; i++)); do
    echo "Converting .info and .dose for Hispanic American Chromosome ${i}"
    dose2plink -m 7000 -dose "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.dose.cb -info "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info -gz 0 -out "${WHI_SHARE_ha_cb}"/testing-dose2plinkout/SHAREchr"${i}"ha
done

echo "Completed Hispanic American Chromosomes"




## Step 2.5: Combine the chromosomes for each dataset into a single file ##


## Define dose2plinkout combined consent group directories:
WHI_SHARE_aa_cb_d2po=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_aa.genotype/dose2plinkout
WHI_SHARE_ha_cb_d2po=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_ha.genotype/dose2plinkout

# The pdat files for each chromosome need to be combined into a single file.

## African American
## Add the first file into a new pdat file and then append the rest of the fiels without the header
cat "${WHI_SHARE_aa_cb_d2po}"/SHAREchr1aa.pdat > "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pdat
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_aa ${i}"
    cat "${WHI_SHARE_aa_cb_d2po}"/SHAREchr"${i}"aa.pdat | tail -n +2 >> "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pdat
done

## Hispanic American
## Add the first file into a new pdat file and then append the rest of the fiels without the header
cat "${WHI_SHARE_ha_cb_d2po}"/SHAREchr1ha.pdat > "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pdat
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_ha ${i}"
    cat "${WHI_SHARE_ha_cb_d2po}"/SHAREchr"${i}"ha.pdat | tail -n +2 >> "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pdat
done



## Step 2.6: Correct the gender for the pfam files produced ##

### IMPORTANT NOTE ### 
### This step is altering the 'sex' column to '2' which is female. This is specific to the data set I used because they are all female.
### For a more generic use we need to find another way to do this based on information provided elsewhere in the dataset.


awk '{print $1,$2,$3,$4,2,$6}' "${WHI_SHARE_aa_cb_d2po}"/SHAREchr1aa.pfam  > "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pfam
awk '{print $1,$2,$3,$4,2,$6}' ${WHI_SHARE_ha_cb_d2po}/SHAREchr1ha.pfam  > "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pfam


# As is, the pfam file is generic - i.e. it does not contain case vs control information or family ID. 
# To correct this, we will use the phenotype data generated in the step above to amend the pfam file.

./"${pathtoscript}"/preparepfam.py




## Step 2.7: Identify shared SNPs between datasets (if there is more than one dataset used) ##

## Define combined consent group directories:
WHI_SHARE_cb=${WHI_SHARE}/combined_consentgroups/geno


tail -n +2 "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pdat | awk '{print $1,$2,$3}' | sort > "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.snpset
tail -n +2 "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pdat | awk '{print $1,$2,$3}' | sort > "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.snpset


echo "$(comm -12 "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.snpset "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.snpset)" > "${WHI_SHARE_cb}"/SHARE_sharedsnps.txt
echo "$(cut -d ' ' -f 1 "${WHI_SHARE_cb}"/SHARE_sharedsnps.txt)" > "${WHI_SHARE_cb}"/SHARE_shared_alleles_snps.txt




## Step 2.8: Generate map file ##

# A MAP file for our dataset (which contains a list of SNPs and their location) must be created for use with PLINK (see https://zzz.bwh.harvard.edu/plink/data.shtml#map).

awk '{print 0,$1,0,0}' ${WHI_SHARE_aa_cb_d2po}/SHARE_aa.pdat > ${WHI_SHARE_aa_cb_d2po}/SHARE_aa.map
awk '{print 0,$1,0,0}' ${WHI_SHARE_ha_cb_d2po}/SHARE_ha.pdat > ${WHI_SHARE_ha_cb_d2po}/SHARE_ha.map








# Optional Part A: Using RSID #



## Step A.1: Download Rereference Genome ##

# Create/define environment variables
mkdir "$HOME"/SAP2-GWAS_ref_genome
genome_dir=$HOME/SAP2-GWAS_ref_genome

# Download the file to the scratch directory
wget http://ftp.ensembl.org/pub/grch37/release-93/variation/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz "${genome_dir}"/
zgrep -v '^#' "${genome_dir}"/1000GENOMES-phase_3.vcf.gz | cut -f 1-5 > "${genome_dir}"/snp_annot_grch37.txt
paste "${genome_dir}"/snp_annot_grch37.txt <(awk 'BEGIN {OFS=":"} {print $1,$2}' snp_annot_grch37.txt) > "${genome_dir}"/snp_annot_grch37_withLoci.txt
cat "${genome_dir}"/snp_annot_grch37_withLoci.txt | sort -u -k3,3 | sort -u -k6,6 -V > "${genome_dir}"/snp_annot_grch37_nodups.txt  # Unique rsID and chr:pos locus
rm "${genome_dir}"/snp_annot_grch37.txt "${genome_dir}"/snp_annot_grch37_withLoci.txt




## Step A.2: Step : Generate posfile for info files and concatenate ##

# In order to extract RSID for these positions, a new column must be added to .info files which contain only chr:position - matching the format of the column in the ref genome file. 
# Output is saved with same file name but .info suffix is replaced with .pos suffix.

# Generating position files (posfiles)
for ((i=1; i<=22; i++)); do
echo "Doing SHAREchr${i}aa.info"
paste "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info <(cut -f 1 "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.info | cut -d ":" -f 1,2 | sed 's/SNP/CHR_POS/') > "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.pos
echo "Doing SHAREchr${i}ha.info"
paste "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info <(cut -f 1 "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.info | cut -d ":" -f 1,2 | sed 's/SNP/CHR_POS/') > "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.pos
done

# Comebine the posfiles

## African American
## Add the first file into a new pos file and then append the rest of the files without the header
cat "${WHI_SHARE_aa_cb}"/SHAREchr1aa.pos > "${WHI_SHARE_aa_cb}"/SHARE_aa.pos
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_aa ${i}"
    cat "${WHI_SHARE_aa_cb}"/SHAREchr"${i}"aa.pos | tail -n +2 >> "${WHI_SHARE_aa_cb}"/SHARE_aa.pos
done

## Hispanic American
## Add the first file into a new pos file and then append the rest of the files without the header
cat "${WHI_SHARE_ha_cb}"/SHAREchr1ha.pos > "${WHI_SHARE_ha_cb}"/SHARE_ha.pos
for ((i=2; i<=22; i++)); do
    echo "Doing SHARE_ha ${i}"
    cat "${WHI_SHARE_ha_cb}"/SHAREchr"${i}"ha.pos | tail -n +2 >> "${WHI_SHARE_ha_cb}"/SHARE_ha.pos
done


## Step A.3: Extract RSID ##

./"${pathtoscript}"/getrsid.py









# Part 3: PLINK2 Analysis #

## Define combined consent group directories:
WHI_SHARE_aa_cb_p2o=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_aa.genotype/plink2out
WHI_SHARE_ha_cb_p2o=${WHI_SHARE}/combined_consentgroups/geno/WHI_SHARE_ha.genotype/plink2out

## Step 3.1: Import dosage files into PLINK2 format

# Import dosage files for SHARE_aa excluding the low quality snps identified earlier
echo "importing dosage files for SHARE African Americans..."
plink2 --import-dosage "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pdat \
	--psam "${WHI_SHARE_aa_cb_d2po}"/SHARE_aa.pfam \
	--exclude "${WHI_SHARE_aa_cb_lq}"/SHARE_aa_lq_all_snps.txt \
	--make-pgen \
	--out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp
echo "Done"

echo "importing dosage files for SHARE Hispanic Americans Americans..."
# Import dosage files for SHARE_ha excluding the low quality snps identified earlier
plink2 --import-dosage "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pdat \
	--psam "${WHI_SHARE_ha_cb_d2po}"/SHARE_ha.pfam \
	--exclude "${WHI_SHARE_ha_cb_lq}"/SHARE_ha_lq_all_snps.txt \
	--make-pgen \
	--out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp
echo "Done"



## Step 3.2: Correct pfiles ##

# Once the files have been imported into plink format the chromosome and position information must be updated as they are currently null. 
# To do this we will use information that is present within the pvar file.

echo "Generating files for african americans"
# Print the 3rd column called ID from the pvar file and split it based on ':' then take the first and second element. Take off the header and add a new header and add to new file
echo "Taking ID and splitting into chromosome and position for later use..."
awk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp.pvar | awk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' | tail -n+2 | sed '1i #CHROM POS' > "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_chrpos.pvar
# Paste the original pvar and the new intermediate file into another intermediate file
echo "Making temporary file..."
paste "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp.pvar "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_chrpos.pvar > "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_w_chrpos.pvar
# Make a new pvar file with the corrected columns
echo "Make new pvar file with correct chromosome and position information..."
awk 'BEGIN{FS="\t";OFS="\t"}{print $6,$7,$3,$4,$5}' "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_w_chrpos.pvar > "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_updated.pvar
# Copy the other pfiles with a matching name so that plink2 knows they are together.
echo "Copying other files in the set for plink compatibility..."
cp "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp.psam "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_updated.psam
cp  "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp.pgen "${WHI_SHARE_aa_cb_d2po}"/WHI_SHARE_aa_temp_updated.pgen
echo "Done"

echo "Generating files for african americans"
# Print the 3rd column called ID from the pvar file and split it based on ':' then take the first and second element. Take off the header and add a new header and add to new file
echo "Taking ID and splitting into chromosome and position for later use..."
awk 'BEGIN{FS="\t"; OFS="\t"}{print $3}' "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp.pvar | awk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}' | tail -n+2 | sed '1i #CHROM POS' > "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_chrpos.pvar
# Paste the original pvar and the new intermediate file into another intermediate file
echo "Making temporary file..."
paste "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp.pvar "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_chrpos.pvar > "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_w_chrpos.pvar
# Make a new pvar file with the corrected columns
echo "Make new pvar file with correct chromosome and position information..."
awk 'BEGIN{FS="\t";OFS="\t"}{print $6,$7,$3,$4,$5}' "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_w_chrpos.pvar > "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_updated.pvar
# Copy the other pfiles with a matching name so that plink2 knows they are together.
cp "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp.psam "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_updated.psam
cp  "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp.pgen "${WHI_SHARE_ha_cb_d2po}"/WHI_SHARE_ha_temp_updated.pgen
echo "Done"

echo "Process Complete"




## Step 3.3: PLINK2 QC ##
# The first steps of the quality control must be performed to remove missing and poor quality data.


### QC Step 1: Investigate missingness ###


# Investigate missingness per individual and per SNP and make histograms.
echo "Investigating missingness per individuals for african american"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_updated --missing
echo "Investigating missingness per individuals for hispanic american"
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_updated --missing
# output: plink.imiss and plink.lmiss, these files show respectively the proportion of missing SNPs per individual and the proportion of missing individuals per SNP.


# Generate plots to visualize the missingness results.
Rscript --no-save "${pathtoscript}"/hist_miss.R

# Delete SNPs and individuals with high levels of missingness, explanation of this and all following steps can be found in box 1 and table 1 of the article mentioned in the comments of this script.
# The following two QC commands will not remove any SNPs or individuals. However, it is good practice to start the QC with these non-stringent thresholds.  
# Delete SNPs with missingness >0.2.
echo "Delete SNPs with a missingness of more than 0.2"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_updated --geno 0.2 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_2
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_updated --geno 0.2 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_2

# Delete individuals with missingness >0.2.
echo "Delete individuals with a missingness of more than 0.2"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_2 --mind 0.2 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_3
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_2 --mind 0.2 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_3

# Delete SNPs with missingness >0.02.
echo "Delete SNPs with a missingness of more than 0.02"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_3 --geno 0.02 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_4
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_3 --geno 0.02 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_4


# Delete individuals with missingness >0.02.
echo "Delete individuals with a missingness of more than 0.02"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_4 --mind 0.02 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_5
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_4 --mind 0.02 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_5


### QC Step 2: Check for sex discrepancy ###

##  All individuals in this dataset are definitely female therefore no need to complete this step.

#### IMPORTANT NOTE!!! - THIS WILL NEED TO BE INCLUDED FOR THE TOOL ####


## QC Step 3: Minor Allele Frequency ###

# Generate a plot of the MAF distribution.
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_5 --freq --out "${WHI_SHARE_aa_cb_p2o}"/MAF_check
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_aa_temp_5 --freq --out "${WHI_SHARE_aa_cb_p2o}"/MAF_check

# Use Rscript --no-save MAF_check.R to plot this.
Rscript --no-save "${pathtoscript}"/MAF_check.R

# Calculate MAFs. Remove all variants with MAF < 0.05 from the current analysis.
echo "Delete variants with a minor allele frequency of more than 0.05"
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_5 --maf 0.05 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_6
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_5 --maf 0.05 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_6


### QC Step 4: Hardy-Weinberg equilibrium ###

# Delete SNPs which are not in Hardy-Weinberg equilibrium (HWE).
# Check the distribution of HWE p-values of all SNPs.
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_6 --hardy
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_6 --hardy

# Selecting SNPs with HWE p-value below 0.00001, required for one of the two plot generated by the next Rscript, allows to zoom in on strongly deviating SNPs. 
awk '{ if ($9 <0.00001) print $0 }' "${WHI_SHARE_aa_cb_p2o}"/plink2.hardy > "${WHI_SHARE_aa_cb_p2o}"/plink2zoomhwe.hardy
awk '{ if ($9 <0.00001) print $0 }' "${WHI_SHARE_ha_cb_p2o}"/plink2.hardy > "${WHI_SHARE_ha_cb_p2o}"/plink2zoomhwe.hardy
Rscript --no-save "${pathtoscript}"/hwe.R

# By default the --hwe option in plink only filters for controls.
# Therefore, we use two steps, first we use a stringent HWE threshold for controls, followed by a less stringent threshold for the case data.
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_6 --hwe 1e-6 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_filter_step1
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_6 --hwe 1e-6 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_filter_step1


# The HWE threshold for the cases filters out only SNPs which deviate extremely from HWE. 
# This second HWE step only focusses on cases because in the controls all SNPs with a HWE p-value < hwe 1e-6 were already removed
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_filter_step1 --hwe 1e-10 --make-pgen --out "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_7
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_filter_step1 --hwe 1e-10 --make-pgen --out "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_7


### QC Step 5: Check heterozygosity ###

# Checks for heterozygosity are performed on a set of SNPs which are not highly correlated.
# Therefore, to generate a list of non-(highly)correlated SNPs, we exclude high inversion regions (inversion.txt [High LD regions]) and prune the SNPs using the command --indep-pairwise�.
# The parameters �50 5 0.2� stand respectively for: the window size, the number of SNPs to shift the window at each step, and the multiple correlation coefficient for a SNP being regressed on all other SNPs simultaneously.
plink2 --pfile "${WHI_SHARE_aa_cb_p2o}"/WHI_SHARE_aa_temp_7 --exclude "${WHI_SHARE_aa_cb_p2o}"/inversion.txt --indep-pairwise 50 5 0.2 --out "${WHI_SHARE_aa_cb_p2o}"/indepSNP
plink2 --pfile "${WHI_SHARE_ha_cb_p2o}"/WHI_SHARE_ha_temp_7 --exclude "${WHI_SHARE_ha_cb_p2o}"/inversion.txt --indep-pairwise 50 5 0.2 --out "${WHI_SHARE_ha_cb_p2o}"/indepSNP

#plink --pfile /WHI_SHARE_aa_temp_7 --extract indepSNP.prune.in --het --out R_check
# This file contains the pruned data set.


# Plot of the heterozygosity rate distribution
Rscript --no-save "${pathtoscript}"/check_heterozygosity_rate.R


# The following code generates a list of individuals who deviate more than 3 standard deviations from the heterozygosity rate mean.
Rscript --no-save "${pathtoscript}"/heterozygosity_outliers_list.R