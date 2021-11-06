import pandas as pd
import numpy as np
import os
pd.set_option('display.max_columns', 120)


##################################################

# Load in the necessary files which will be used for building the phenotype dataset #


# We will load in the files which contain the phenotype data we want to inlcude in the analysis.

# First, we will define the directories which contain the phenotype files as c1_pheno_data_dir and c2_pheno_data_dir, where the 'c' in c1 and c2 represents consent group.
# Therefore, you can add additional lines if there is more than 2 consent groups (or delete the second consent group) depending on your study.

c1_pheno_data_dir = "/home/anbennett2/scratch/datasets/raw_data/dbgap_data/WHI/pheno/c1/PhenotypeFiles"
c2_pheno_data_dir = "/home/anbennett2/scratch/datasets/raw_data/dbgap_data/WHI/pheno/c2/PhenotypeFiles"


# In the step above, we defined the directories which contain the phenotype files as c1_pheno_data_dir etc.
# In the code below, you can rename the dataframe name (currently c1_form2) with any name you wish to use.
# Then, you can simple replace the file name within the quotation marks ("") with the name of the file you wish to use.


c1_form2 = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht000998.v6.p3.c1.f2_rel1.HMB-IRB.txt"), sep="\t", comment="#")
c2_form2 = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht000998.v6.p3.c2.f2_rel1.HMB-IRB-NPU.txt"), sep="\t", comment="#")
form2 = pd.concat([c1_form2, c2_form2], axis=0,  ignore_index=True)


c1_form30 = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht000999.v6.p3.c1.f30_rel2.HMB-IRB.txt"),sep="\t", comment="#")
c2_form30 = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht000999.v6.p3.c2.f30_rel2.HMB-IRB-NPU.txt"), sep="\t", comment="#")
form30 = pd.concat([c1_form30, c2_form30], axis=0,  ignore_index=True)


c1_form41 = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht001009.v6.p3.c1.f41_rel1.HMB-IRB.txt"), sep="\t", comment="#")
c2_form41 = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht001009.v6.p3.c2.f41_rel1.HMB-IRB-NPU.txt"), sep="\t", comment="#")
form41 = pd.concat([c1_form41, c2_form41], axis=0,  ignore_index=True)


c1_form80 = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht001019.v6.p3.c1.f80_rel1.HMB-IRB.txt"), sep="\t",comment="#")
c2_form80 = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht001019.v6.p3.c2.f80_rel1.HMB-IRB-NPU.txt"), sep="\t",comment="#")
form80 = pd.concat([c1_form80, c2_form80], axis=0,  ignore_index=True)


c1_outc_ct_os = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht003407.v3.p3.c1.outc_ct_os_rel4.HMB-IRB.txt"), sep="\t", comment="#")
c2_outc_ct_os = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht003407.v3.p3.c2.outc_ct_os_rel4.HMB-IRB-NPU.txt"), sep="\t", comment="#")
outc_ct_os = pd.concat([c1_outc_ct_os, c2_outc_ct_os], axis=0,  ignore_index=True)


c1_outc_cancer_rel4 = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht003404.v3.p3.c1.outc_cancer_rel4.HMB-IRB.txt"), sep="\t", comment="#")
c2_outc_cancer_rel4 = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht003404.v3.p3.c2.outc_cancer_rel4.HMB-IRB-NPU.txt"), sep="\t", comment="#")
outc_cancer_rel4 = pd.concat([c1_outc_cancer_rel4, c2_outc_cancer_rel4], axis=0,  ignore_index=True)





# These files are not part of the phenotype data that you are interested in per se, but are important for extracting the samples which only are present in the study you are investigating (i.e. the harmonized and imputed data)


WHI_Sample = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht001032.v8.p3.WHI_Sample.MULTI.txt"), sep="\t", comment="#")
WHI_Subject = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht000982.v8.p3.WHI_Subject.MULTI.txt"), sep="\t", comment="#")





# Loading the phenotype file for genotype data #

# The next set of files we will use contain information about the biological sample that was taken for conducting the genotyping and are stored within the phenotype subdirectory of the genotype directory.
# We will use this files to extract the biological samples which are from the study we are interested in (i.e. SHARE or WHIMS)

c1_genopheno_data_dir = "/home/anbennett2/scratch/datasets/raw_data/dbgap_data/WHI/746/c1/PhenotypeFiles"
c2_genopheno_data_dir = "/home/anbennett2/scratch/datasets/raw_data/dbgap_data/WHI/746/c2/PhenotypeFiles"

c1_746_pheno = pd.read_csv(os.path.join(c1_genopheno_data_dir, "phs000746.v2.pht004719.v1.p3.c1.WHI_Imputation_Sample_Attributes.HMB-IRB.txt"), sep="\t", comment="#")
c2_746_pheno = pd.read_csv(os.path.join(c2_genopheno_data_dir, "phs000746.v2.pht004719.v1.p3.c2.WHI_Imputation_Sample_Attributes.HMB-IRB-NPU.txt"), sep="\t", comment="#")
phenogeno = pd.concat([c1_746_pheno, c2_746_pheno], axis=0,  ignore_index=True)






# Loading the samples in the genotype dataset #

# Here we will define the directory that contains the genotype files. This is because we will use the _allchr.tsv file produced in the convert-mac-module.sh script.

GARNET_genodir= "/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset"
WHIMS_genodir= "/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/WHIMS_dataset"



GARNET_geno_samples = pd.read_csv(os.path.join(GARNET_genodir, "GARNET_allchr.pfam"), sep="\t", comment="#", names=["FID", "IID", "In-Fam-ID-Dad", "In-Fam-ID-Mum", "SEX", "Pheno"])
WHIMS_geno_samples = pd.read_csv(os.path.join(WHIMS_genodir, "WHIMS_allchr.pfam"), sep="\t", comment="#", names=["FID", "IID", "In-Fam-ID-Dad", "In-Fam-ID-Mum", "SEX", "Pheno"])


WHI_Sample_filt_746 = WHI_Sample[WHI_Sample.STUDY.str.match('phs000746')]

GARNET_dataset_temp1= pd.merge(left=GARNET_geno_samples, right=WHI_Sample_filt_746[['SAMPLE_ID', 'dbGaP_Subject_ID']], how='left', left_on='FID', right_on='SAMPLE_ID')
WHIMS_dataset_temp1= pd.merge(left=WHIMS_geno_samples, right=WHI_Sample_filt_746[['SAMPLE_ID', 'dbGaP_Subject_ID']], how='left', left_on='FID', right_on='SAMPLE_ID')





# check for dups:

GARNET_dataset_temp1.drop_duplicates(subset=['SAMPLE_ID'])
WHIMS_dataset_temp1.drop_duplicates(subset=['SAMPLE_ID'])
WHI_Sample_filt_746.drop_duplicates(subset=['SAMPLE_ID'])

#######


# Create a new dataframe which contains the phenotype data relevant to the GWAS. First, an empty df is created and db_GaP_Subject_ID is added using form 2, as it contains basic information about the patients,
# without which we cannot control for key confounders - hence this information is essential:


pancan_occ = outc_cancer_rel4[outc_cancer_rel4['PANCREAS'] == 1.0].copy()
pancan_occ.reset_index(inplace=True,drop=True)
pancan_occ['case'] = 2

pancan_occ.drop_duplicates(subset=['dbGaP_Subject_ID'])



form80_BMI=form80.groupby(by='dbGaP_Subject_ID')['BMIX'].mean()
form80_BMI=pd.DataFrame(form80_BMI)
form80_BMI.reset_index(inplace=True)

form80_WHRX=form80.groupby(by='dbGaP_Subject_ID')['WHRX'].mean()
form80_WHRX=pd.DataFrame(form80_WHRX)
form80_WHRX.reset_index(inplace=True)


# Create empty DF with subject ID column based on form 2

subject_ID = pd.DataFrame()
subject_ID['dbGaP_Subject_ID'] = form2['dbGaP_Subject_ID'].copy()




# - Merge the necessary columns to the above dfs:

# Extract and merge the columns needed for my phenotype file

my_pheno_file = pd.DataFrame()
my_pheno_file['dbGaP_Subject_ID'] = subject_ID['dbGaP_Subject_ID']

my_pheno_file = pd.merge(left=my_pheno_file, right=form2[['dbGaP_Subject_ID', 'AGE', 'RACE', 'DIAB']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
my_pheno_file = pd.merge(left=my_pheno_file, right=form41[['dbGaP_Subject_ID','SPANISH', 'BLACK']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
my_pheno_file = pd.merge(left=my_pheno_file, right=form30[['dbGaP_Subject_ID', 'PANCREAT']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


my_pheno_file = pd.merge(left=my_pheno_file, right=outc_ct_os[['dbGaP_Subject_ID', 'PANCREASDY', 'DEATH','DEATHDY', 'ENDWHIDY', 'ENDFOLLOWDY']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


my_pheno_file = pd.merge(left=my_pheno_file, right=pancan_occ[['dbGaP_Subject_ID', 'PANCREAS', 'ICDCODE', 'BEHAVIOR', 'DIAGSTAT', 'LATERAL', 'MRPHHISTB', 'GRADING', 'SIZE', 'STAGE', 'case']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


my_pheno_file = pd.merge(left=my_pheno_file, right=form80_BMI, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
my_pheno_file = pd.merge(left=my_pheno_file, right=form80_WHRX[['dbGaP_Subject_ID', 'WHRX']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


#can check with :
my_pheno_file[my_pheno_file['case'] == 2]

my_pheno_file.drop_duplicates(subset=['dbGaP_Subject_ID'])




###############################################################################################################################################################################

## Add column denoting sex:

my_pheno_file['sex'] = 2

# In plink, the sex is denoted as: 1=male/2=female/{0,NA}. Therefore, replace the values accordingly:

#my_pheno_file[my_pheno_file['sex'] == 'M'] = 1
#my_pheno_file[my_pheno_file['sex'] == 'F'] = 2

#my_pheno_file['sex'].loc[my_pheno_file['sex-temp'] == 'F'] = 2



###################################################################################################################################################################################################



# Clean and transform the datasets
## Rename the columns

my_pheno_file = my_pheno_file.rename(columns={"RACE": "race", "DIAB": "HISTORY_DIABETES", "SPANISH": "SPANISH_RACE", "PANCREAT": "PANCREATITIS", "PANCREASDY": "AGE_DIAGNOSED", "DEATH": "DECEASED", "DEATHDY": "AGE_DEATH", "ENDFOLLOWDY": "AGE_END_FOLLOW", "PANCREAS": "PAN_CAN","ICDCODE": "PAN_CAN_LOCATION","BEHAVIOR": "TUMOUR_BEHAVIOUR", "DIAGSTAT": "DIAGNOSIS_STATUS", "LATERAL": "LATERALITY", "MRPHHISTB": "TUMOUR_MORPHOLOGY", "GRADING": "TUMOUR_GRADE", "SIZE": "TUMOUR_SIZE", "STAGE": "TUMOUR_STAGE", "BMIX": "MEAN_BMI", "WHRX": "MEAN_WHR"})



# Transform the columns as required for the analysis. Further information can be found within the WHI_SHARE_phenovariables_plan.xml file in the project directory.

##  Convert age days enrolled from diagnosis to age diagnosed


my_pheno_file.AGE_DIAGNOSED = my_pheno_file.AGE + (my_pheno_file.AGE_DIAGNOSED / 365)

##Convert days till death to age of death in years

my_pheno_file.AGE_DEATH = my_pheno_file.AGE + (my_pheno_file.AGE_DEATH / 365)


## Calculate number of months survived with pancreatic cancer

my_pheno_file['PAN_CAN_MONTHS_SURVIVED'] = (my_pheno_file.AGE_DEATH - my_pheno_file.AGE_DIAGNOSED) * 12


## Convert the number of days till end follow up to their age at end of follow up

my_pheno_file.AGE_END_FOLLOW = my_pheno_file.AGE + (my_pheno_file.AGE_END_FOLLOW / 365)









GARNET_dataset_temp2 = pd.merge(left=GARNET_dataset_temp1, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
WHIMS_dataset_temp2 = pd.merge(left=WHIMS_dataset_temp1, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')



GARNET_dataset_temp2['case']
GARNET_dataset_temp2[GARNET_dataset_temp2['case'] == 2]

WHIMS_dataset_temp2['case']
WHIMS_dataset_temp2[WHIMS_dataset_temp2['case'] == 2]





GARNET_dataset_pfam = GARNET_dataset_temp2[['FID', 'IID', 'In-Fam-ID-Dad', 'In-Fam-ID-Mum', 'sex', 'case']].copy()
GARNET_dataset_pfam['case'] = GARNET_dataset_pfam ['case'].fillna(1)


WHIMS_dataset_pfam = WHIMS_dataset_temp2[['FID', 'IID', 'In-Fam-ID-Dad', 'In-Fam-ID-Mum', 'sex', 'case']].copy()
WHIMS_dataset_pfam['case'] = WHIMS_dataset_pfam ['case'].fillna(1)



GARNET_dataset_pheno=GARNET_dataset_pfam[['FID', 'IID', 'case']].copy()

WHIMS_dataset_pheno=WHIMS_dataset_pfam[['FID', 'IID', 'case']].copy()


GARNET_dataset_covar=GARNET_dataset_temp2[['FID', 'IID','AGE', 'race', 'HISTORY_DIABETES', 'MEAN_BMI', 'MEAN_WHR', 'PANCREATITIS', 'PAN_CAN_MONTHS_SURVIVED', 'DECEASED']].copy()
WHIMS_dataset_covar=WHIMS_dataset_temp2[['FID', 'IID','AGE', 'race', 'HISTORY_DIABETES', 'MEAN_BMI', 'MEAN_WHR', 'PANCREATITIS', 'PAN_CAN_MONTHS_SURVIVED', 'DECEASED']].copy()

#GARNET_dataset_covar=GARNET_dataset_temp2[['FID', 'IID','AGE', 'race', 'HISTORY_DIABETES', 'SPANISH_RACE', 'BLACK', 'MEAN_BMI', 'MEAN_WHR', 'PANCREATITIS', 'AGE_DIAGNOSED', 'PAN_CAN_LOCATION', 'TUMOUR_BEHAVIOUR', 'LATERALITY', 'TUMOUR_MORPHOLOGY', 'TUMOUR_GRADE', 'TUMOUR_SIZE', 'TUMOUR_STAGE', 'PAN_CAN_MONTHS_SURVIVED', 'DECEASED']].copy()



GARNET_dataset_covar = GARNET_dataset_covar.fillna(-9)

WHIMS_dataset_covar = WHIMS_dataset_covar.fillna(-9)





GARNET_out_dir = "/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset"


GARNET_dataset_pheno.to_csv(os.path.join(GARNET_out_dir, "GARNET_dataset_pheno.tsv"), sep='\t', index=False)
GARNET_dataset_covar.to_csv(os.path.join(GARNET_out_dir, "GARNET_dataset_covar.tsv"), sep='\t', index=False)
GARNET_dataset_pfam.to_csv(os.path.join(GARNET_out_dir, "GARNET_dataset_allchr.pfam"), sep='\t', index=False, header=False)





WHIMS_out_dir = "/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/WHIMS_dataset"


WHIMS_dataset_pheno.to_csv(os.path.join(WHIMS_out_dir, "WHIMS_dataset_pheno.tsv"), sep='\t', index=False)
WHIMS_dataset_covar.to_csv(os.path.join(WHIMS_out_dir, "WHIMS_dataset_covar.tsv"), sep='\t', index=False)
WHIMS_dataset_pfam.to_csv(os.path.join(WHIMS_out_dir, "WHIMS_dataset_allchr.pfam"), sep='\t', index=False, header=False)
