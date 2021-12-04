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
#c2_WHI_Sample = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht001032.v8.p3.WHI_Sample.MULTI.txt"), sep="\t", comment="#")
#WHI_Sample = pd.concat([c1_WHI_Sample, c2_WHI_Sample], axis=0,  ignore_index=True)



WHI_Subject = pd.read_csv(os.path.join(c1_pheno_data_dir, "phs000200.v11.pht000982.v8.p3.WHI_Subject.MULTI.txt"), sep="\t", comment="#")
#c2_WHI_Subject = pd.read_csv(os.path.join(c2_pheno_data_dir, "phs000200.v11.pht000982.v8.p3.WHI_Subject.MULTI.txt"), sep="\t", comment="#")
#WHI_Subject = pd.concat([c1_WHI_Subject, c2_WHI_Subject], axis=0,  ignore_index=True)




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



GARNET_geno_samples = pd.read_csv(os.path.join(GARNET_genodir, "test.tsv"), sep="\t", comment="#", names=["FID", "IID", "In-Fam-ID-Dad", "In-Fam-ID-Mum", "SEX", "Pheno"])
WHIMS_geno_samples = pd.read_csv(os.path.join(WHIMS_genodir, "WHIMS_allchr.tsv"), sep="\t", comment="#", names=["FID", "IID", "In-Fam-ID-Dad", "In-Fam-ID-Mum", "SEX", "Pheno"])







# N.B. The columns of these files are defined by plink:

#Family ID ('FID')
#Within-family ID ('IID'; cannot be '0')
#Within-family ID of father ('0' if father isn't in dataset)
#Within-family ID of mother ('0' if mother isn't in dataset)
#Sex code ('1' = male, '2' = female, '0' = unknown)
#Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)




##################################################

# Preparing dataframes #

# First, since cancer is marked with a 1 if a case, we can assume NA is not a case and therefore fill NA with values with 0.

outc_cancer_rel4.PANCREAS = outc_cancer_rel4.PANCREAS.fillna(0)



# We will know create intermediate dataframes containing information we want to add to our phenotype file

# In this first step, we will make a df which only contains confirmed cases of pancreatic cancer.
# Once extracted, we have to reset the index on the new dataframe as the rows retain their indexing information from the df from which they were taken.

pancan_occ = outc_cancer_rel4[outc_cancer_rel4['PANCREAS'] == 1.0].copy()
pancan_occ.reset_index(inplace=True,drop=True)
pancan_occ['case'] = 2




form80_BMI=form80.groupby(by='dbGaP_Subject_ID')['BMIX'].mean()
form80_BMI=pd.DataFrame(form80_BMI)
form80_BMI.reset_index(inplace=True)

form80_WHRX=form80.groupby(by='dbGaP_Subject_ID')['WHRX'].mean()
form80_WHRX=pd.DataFrame(form80_WHRX)
form80_WHRX.reset_index(inplace=True)






# Prepare dataframes containing list of samples only present in the dataset we want. In this example, the study phs000746 contains the harmonized and imputed data.
# Therefore, we will create a new df ('WHI_sample_filt_746') which only contains samples which have phs000746 present in the 'STUDY' column.

WHI_sample_filt_746 = WHI_Sample[WHI_Sample.STUDY.str.match('phs000746')]
WHI_sample_filt_746.reset_index(inplace=True,drop=True)

WHI_sample_filt_746_info = WHI_sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID', 'SAMPLE_ID', 'SUBJID']]
WHI_sample_filt_746_final = WHI_sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID']]


## - Then, using the phenotype file which describes the genotyping samples, extract the samples which were used in the SHARE substudy:


phenogeno_sample_info = phenogeno[['dbGaP_Sample_ID', 'SAMPLE_ID', 'SAMPLE_ORIGIN']]





phenogeno_sample_info_SHARE = phenogeno_sample_info[phenogeno_sample_info.SAMPLE_ORIGIN.str.match('SHARE')]
phenogeno_sample_info_SHARE.reset_index(inplace=True,drop=True)


phenogeno_sample_info_WHIMS = phenogeno_sample_info[phenogeno_sample_info.SAMPLE_ORIGIN.str.match('WHIMS')]
phenogeno_sample_info_WHIMS.reset_index(inplace=True,drop=True)


phenogeno_sample_info_GARNET = phenogeno_sample_info[phenogeno_sample_info.SAMPLE_ORIGIN.str.match('GARNET')]
phenogeno_sample_info_GARNET.reset_index(inplace=True,drop=True)


phenogeno_sample_info_all = pd.concat([phenogeno_sample_info_SHARE, phenogeno_sample_info_WHIMS, phenogeno_sample_info_GARNET], axis=0,  ignore_index=True)


# - Merge the above filtered dataframes from the WHI Sample and 746 pheno dataframes. This is done with a left join onto the 746_pheno_info_SHARE dfs, as these should contain only those subjects who participated in SHARE.
# The subsequent df will be used later on when appending the phenotype information:

SHARE_dataset = pd.merge(left=phenogeno_sample_info_SHARE, right=WHI_sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
GARNET_dataset = pd.merge(left=phenogeno_sample_info_GARNET, right=WHI_sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
WHIMS_dataset = pd.merge(left=phenogeno_sample_info_WHIMS, right=WHI_sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')

all_dataset = pd.merge(left=phenogeno_sample_info_all, right=WHI_sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')






# Create a new dataframe which contains the phenotype data relevant to the GWAS. First, an empty df is created and db_GaP_Subject_ID is added using form 2, as it contains basic information about the patients,
# without which we cannot control for key confounders - hence this information is essential:

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

# D100048-40


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







# In plink, the sex is denoted as: 1=male/2=female/{0,NA}. Therefore, replace the values accordingly:

#my_pheno_file[my_pheno_file['sex'] == 'M'] = 1
#my_pheno_file[my_pheno_file['sex'] == 'F'] = 2

#my_pheno_file['sex'].loc[my_pheno_file['sex-temp'] == 'F'] = 2



###################################################################################################################################################################################################






## Finally, extract patients from the mydf dataframes onto the dateset dataframes created earlier, so that only patients in the SHARE substudy are present in the phenotype files

my_pheno_file_SHARE = pd.merge(left=SHARE_dataset, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
my_pheno_file_GARNET = pd.merge(left=GARNET_dataset, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
my_pheno_file_WHIMS = pd.merge(left=WHIMS_dataset, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')




#my_pheno_file_all = pd.merge(left=all_dataset, right=my_pheno_file, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
#my_pheno_file_all_pancan = my_pheno_file_all[my_pheno_file_all['PAN_CAN'] == 1.0].copy()
#my_pheno_file_all_pancan['case'] = 2


## Rename dbgap sample id to FIID


my_pheno_file_SHARE = my_pheno_file_SHARE.rename(columns={"SAMPLE_ID": "FID"})
my_pheno_file_GARNET = my_pheno_file_GARNET.rename(columns={"SAMPLE_ID": "FID"})
my_pheno_file_WHIMS = my_pheno_file_WHIMS.rename(columns={"SAMPLE_ID": "FID"})

my_pheno_file_SHARE['IID'] = my_pheno_file_SHARE['FID'].copy()
my_pheno_file_GARNET['IID'] = my_pheno_file_GARNET['FID'].copy()
my_pheno_file_WHIMS['IID'] = my_pheno_file_WHIMS['FID'].copy()



# Output dataframes for use in later analyses.


#my_pheno_file_SHARE.to_csv('/home/anbennett2/scratch/SHARE_phenogeno.csv', sep='\t', index=False)





SHARE_phenogeno_temp1 = my_pheno_file_SHARE[["FID", "IID", "SAMPLE_ORIGIN", "dbGaP_Subject_ID", "AGE",  "race", "HISTORY_DIABETES", "SPANISH_RACE", "BLACK", "PANCREATITIS", "AGE_DIAGNOSED", "DECEASED", "AGE_DEATH", "ENDWHIDY", "AGE_END_FOLLOW","PAN_CAN", "PAN_CAN_LOCATION", "TUMOUR_BEHAVIOUR", "DIAGNOSIS_STATUS", "LATERALITY", "TUMOUR_MORPHOLOGY", "TUMOUR_GRADE", "TUMOUR_SIZE", "TUMOUR_STAGE", "MEAN_BMI", "MEAN_WHR", "PAN_CAN_MONTHS_SURVIVED", "sex", "case"]].copy()
GARNET_phenogeno_temp1 = my_pheno_file_GARNET[["FID", "IID", "SAMPLE_ORIGIN", "dbGaP_Subject_ID", "AGE",  "race", "HISTORY_DIABETES", "SPANISH_RACE", "BLACK", "PANCREATITIS", "AGE_DIAGNOSED", "DECEASED", "AGE_DEATH", "ENDWHIDY", "AGE_END_FOLLOW", "PAN_CAN", "PAN_CAN_LOCATION", "TUMOUR_BEHAVIOUR", "DIAGNOSIS_STATUS", "LATERALITY", "TUMOUR_MORPHOLOGY", "TUMOUR_GRADE", "TUMOUR_SIZE", "TUMOUR_STAGE", "MEAN_BMI", "MEAN_WHR", "PAN_CAN_MONTHS_SURVIVED", "sex", "case"]].copy()
WHIMS_phenogeno_temp1 = my_pheno_file_WHIMS[["FID", "IID", "SAMPLE_ORIGIN", "dbGaP_Subject_ID", "AGE",  "race", "HISTORY_DIABETES", "SPANISH_RACE", "BLACK", "PANCREATITIS", "AGE_DIAGNOSED", "DECEASED", "AGE_DEATH", "ENDWHIDY", "AGE_END_FOLLOW","PAN_CAN", "PAN_CAN_LOCATION", "TUMOUR_BEHAVIOUR", "DIAGNOSIS_STATUS", "LATERALITY", "TUMOUR_MORPHOLOGY", "TUMOUR_GRADE", "TUMOUR_SIZE", "TUMOUR_STAGE", "MEAN_BMI", "MEAN_WHR", "PAN_CAN_MONTHS_SURVIVED", "sex", "case"]].copy()


GARNET_phenogeno = pd.merge(left= GARNET_geno_samples[['FID']], right=GARNET_phenogeno_temp1, how='left', left_on='FID', right_on='FID')
WHIMS_phenogeno = pd.merge(left= WHIMS_geno_samples[['FID']], right=WHIMS_phenogeno_temp1, how='left', left_on='FID', right_on='FID')





GARNET_phenogeno = GARNET_phenogeno.fillna('nan')
WHIMS_phenogeno = WHIMS_phenogeno.fillna('nan')



GARNET_phenofile = pd.merge(left=GARNET_phenogeno[["FID", "IID",]], right=pan_cases[["FID", "case"]], how='left', left_on='FID', right_on='FID')
GARNET_phenofile['case'] = GARNET_phenofile['case'].fillna(-9)


GARNET_phenofile.drop_duplicates(subset=['FID'])


my_pheno_file.drop_duplicates(subset=['dbGaP_Subject_ID'])
SHARE_dataset.drop_duplicates(subset=['dbGaP_Subject_ID'])
df.drop_duplicates(subset=['brand'])


WHIMS_dataset_temp2.drop_duplicates(subset=['FID'])


#"PAN_CAN"







df1['Pheno'] = np.where(df2[df2['PAN_CAN'] == 1.0], '2', df1['Pheno'])



GARNET_geno_samples

df1=GARNET_geno_samples.copy()

df2=GARNET_phenogeno.copy()


df=df1['Pheno'].loc[GARNET_phenogeno['PAN_CAN'] == '1.0'] = '2'

outc_cancer_rel4[outc_cancer_rel4['PANCREAS'] == 1.0]
df2[df2['PAN_CAN'] == 1.0]
GARNET_phenofile[GARNET_phenofile['case'] == 2]

GARNET_phenogeno[GARNET_phenogeno['case'] == 2]

my_pheno_file[my_pheno_file]
# Create new df with only covariates


#
#/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI/GARNET_dataset


SHARE_covar = SHARE_phenogeno_temp1.copy()

GARNET_covar = GARNET_phenogeno.copy()
WHIMS_covar = GARNET_phenogeno.copy()


# 1=unaffected (control), 2=affected (case) -9 = NA

########################


pheno_out_dir = "/home/anbennett2/scratch/datasets/processed_data/dbgap/WHI"

SHARE_covar.to_csv(os.path.join(pheno_out_dir, "SHARE_covar.tsv"), sep='\t', index=False)
GARNET_covar.to_csv(os.path.join(pheno_out_dir, "GARNET_covar.tsv"), sep='\t', index=False)
WHIMS_covar.to_csv(os.path.join(pheno_out_dir, "WHIMS_covar.tsv"), sep='\t', index=False)



SHARE_phenofile.to_csv(os.path.join(pheno_out_dir, "SHARE_dataset_phenogeno.tsv"), sep='\t', index=False)
GARNET_phenofile.to_csv(os.path.join(pheno_out_dir, "GARNET_dataset_phenogeno.tsv"), sep='\t', index=False)
WHIMS_phenofile.to_csv(os.path.join(pheno_out_dir, "WHIMS_dataset_phenogeno.tsv"), sep='\t', index=False)
