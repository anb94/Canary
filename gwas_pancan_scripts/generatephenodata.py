import pandas as pd
import numpy as np
pd.set_option('display.max_columns', 120)

# Load in the necessary files which will be used for building the phenotype dataset:
## Consent group 1

c1_form2 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht000998.v6.p3.c1.f2_rel1.HMB-IRB.txt', sep="\t", comment='#')
c1_form30 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht000999.v6.p3.c1.f30_rel2.HMB-IRB.txt',sep="\t", comment='#')
c1_form41 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht001009.v6.p3.c1.f41_rel1.HMB-IRB.txt', sep="\t", comment='#')
c1_form80 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht001019.v6.p3.c1.f80_rel1.HMB-IRB.txt', sep="\t",comment='#')

c1_outc_ct_os = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht003407.v3.p3.c1.outc_ct_os_rel4.HMB-IRB.txt', sep="\t", comment='#')
c1_outc_cancer_rel4 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht003404.v3.p3.c1.outc_cancer_rel4.HMB-IRB.txt', sep="\t", comment='#')

c1_WHI_Sample = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht001032.v8.p3.WHI_Sample.MULTI.txt', sep="\t", comment='#')
c1_WHI_Subject = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c1.HMB-IRB/PhenotypeFiles/phs000200.v11.pht000982.v8.p3.WHI_Subject.MULTI.txt', sep="\t", comment='#')
c1_746_pheno = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_1/phenogeno/geno/746/PhenotypeFiles/phs000746.v2.pht004719.v1.p3.c1.WHI_Imputation_Sample_Attributes.HMB-IRB.txt', sep="\t", comment='#')

## Consent Group 2

c2_form2 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht000998.v6.p3.c2.f2_rel1.HMB-IRB-NPU.txt', sep="\t", comment='#')
c2_form30 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht000999.v6.p3.c2.f30_rel2.HMB-IRB-NPU.txt', sep="\t", comment='#')
c2_form41 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht001009.v6.p3.c2.f41_rel1.HMB-IRB-NPU.txt', sep="\t", comment='#')
c2_form80 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht001019.v6.p3.c2.f80_rel1.HMB-IRB-NPU.txt', sep="\t",comment='#')

c2_outc_ct_os = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht003407.v3.p3.c2.outc_ct_os_rel4.HMB-IRB-NPU.txt', sep="\t", comment='#')
c2_outc_cancer_rel4 = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht003404.v3.p3.c2.outc_cancer_rel4.HMB-IRB-NPU.txt', sep="\t", comment='#')


c2_WHI_Sample = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht001032.v8.p3.WHI_Sample.MULTI.txt', sep="\t", comment='#')
c2_WHI_Subject = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/pheno/rootstudy/RootStudyConsentSet_phs000200.WHI.v11.p3.c2.HMB-IRB-NPU/PhenotypeFiles/phs000200.v11.pht000982.v8.p3.WHI_Subject.MULTI.txt', sep="\t", comment='#')
c2_746_pheno = pd.read_csv('/home/anbennett2/scratch/dbgap_data/WHI/consentgroup_2/phenogeno/geno/746/PhenotypeFiles/phs000746.v2.pht004719.v1.p3.c2.WHI_Imputation_Sample_Attributes.HMB-IRB-NPU.txt', sep="\t", comment='#')


# Next, the phenotype data must be extracted and prepared before being added to the custom dataframe.
## Extract Pancreatic Cancer patients

c1_outc_cancer_rel4.PANCREAS = c1_outc_cancer_rel4.PANCREAS.fillna(0)
c2_outc_cancer_rel4.PANCREAS = c2_outc_cancer_rel4.PANCREAS.fillna(0)

c1_pancan_occ = c1_outc_cancer_rel4[c1_outc_cancer_rel4['PANCREAS'] == 1.0]
c2_pancan_occ = c2_outc_cancer_rel4[c2_outc_cancer_rel4['PANCREAS'] == 1.0]

c1_pancan_occ.reset_index(inplace=True,drop=True)
c2_pancan_occ.reset_index(inplace=True,drop=True)

## Extract BMI and Wasit Hip Ratio from Form80 and produce a mean

c1_form80_BMI=c1_form80.groupby(by='dbGaP_Subject_ID')['BMIX'].mean()
c1_form80_BMI=pd.DataFrame(c1_form80_BMI)
c1_form80_BMI.reset_index(inplace=True)

c1_form80_WHRX=c1_form80.groupby(by='dbGaP_Subject_ID')['WHRX'].mean()
c1_form80_WHRX=pd.DataFrame(c1_form80_WHRX)
c1_form80_WHRX.reset_index(inplace=True)


c2_form80_BMI=c2_form80.groupby(by='dbGaP_Subject_ID')['BMIX'].mean()
c2_form80_BMI=pd.DataFrame(c2_form80_BMI)
c2_form80_BMI.reset_index(inplace=True)

c2_form80_WHRX=c2_form80.groupby(by='dbGaP_Subject_ID')['WHRX'].mean()
c2_form80_WHRX=pd.DataFrame(c2_form80_WHRX)
c2_form80_WHRX.reset_index(inplace=True)

# Extract samples from imputed and harmonized data: Use the WHI Sample file from the phenotypes folder to filter for only samples that are in the imputed and harmonized data:

## Consent group 1

c1_WHI_Sample_filt_746 = c1_WHI_Sample[c1_WHI_Sample.STUDY.str.match('phs000746')]
c1_WHI_Sample_filt_746.reset_index(inplace=True,drop=True)

c1_WHI_Sample_filt_746_info = c1_WHI_Sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID', 'SAMPLE_ID', 'SUBJID']]
c1_WHI_Sample_filt_746_final = c1_WHI_Sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID']]

## Consent Group 2

c2_WHI_Sample_filt_746 = c2_WHI_Sample[c2_WHI_Sample.STUDY.str.match('phs000746')]
c2_WHI_Sample_filt_746.reset_index(inplace=True,drop=True)

c2_WHI_Sample_filt_746_info = c2_WHI_Sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID', 'SAMPLE_ID', 'SUBJID']]
c2_WHI_Sample_filt_746_final = c2_WHI_Sample_filt_746[['dbGaP_Subject_ID', 'dbGaP_Sample_ID']]

## - Then, using the phenotype file which describes the genotyping samples, extract the samples which were used in the SHARE substudy. Create two share ha or aa):

## Consent Group 1

c1_746_pheno_info = c1_746_pheno[['dbGaP_Sample_ID', 'SAMPLE_ID', 'SAMPLE_ORIGIN']]

c1_746_pheno_info_SHARE = c1_746_pheno_info[c1_746_pheno_info.SAMPLE_ORIGIN.str.match('SHARE')]
c1_746_pheno_info_SHARE.reset_index(inplace=True,drop=True)

c1_746_pheno_info_SHARE_HA = c1_746_pheno_info_SHARE[c1_746_pheno_info_SHARE.SAMPLE_ORIGIN.str.match('SHARE-HA')]
c1_746_pheno_info_SHARE_HA.reset_index(inplace=True,drop=True)

c1_746_pheno_info_SHARE_AA = c1_746_pheno_info_SHARE[c1_746_pheno_info_SHARE.SAMPLE_ORIGIN.str.match('SHARE-AA')]
c1_746_pheno_info_SHARE_AA.reset_index(inplace=True, drop=True)

# Consent Group 2

c2_746_pheno_info = c2_746_pheno[['dbGaP_Sample_ID', 'SAMPLE_ID', 'SAMPLE_ORIGIN']]

c2_746_pheno_info_SHARE = c2_746_pheno_info[c2_746_pheno_info.SAMPLE_ORIGIN.str.match('SHARE')]
c2_746_pheno_info_SHARE.reset_index(inplace=True,drop=True)

c2_746_pheno_info_SHARE_HA = c2_746_pheno_info_SHARE[c2_746_pheno_info_SHARE.SAMPLE_ORIGIN.str.match('SHARE-HA')]
c2_746_pheno_info_SHARE_HA.reset_index(inplace=True, drop=True)

c2_746_pheno_info_SHARE_AA = c2_746_pheno_info_SHARE[c2_746_pheno_info_SHARE.SAMPLE_ORIGIN.str.match('SHARE-AA')]
c2_746_pheno_info_SHARE_AA.reset_index(inplace=True, drop=True)

# - Merge the above filtered dataframes from the WHI Sample and 746 pheno dataframes. This is done with a left join onto the 746_pheno_info_SHARE dfs, as these should contain only those subjects who participated in SHARE. 
# The subsequent df will be used later on when appending the phenotype information:

# Consent Group 1

c1_SHARE = pd.merge(left=c1_746_pheno_info_SHARE, right=c1_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
c1_SHARE_AA = pd.merge(left=c1_746_pheno_info_SHARE_AA, right=c1_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
c1_SHARE_HA = pd.merge(left=c1_746_pheno_info_SHARE_HA, right=c1_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')


# Consent Group 2

c2_SHARE = pd.merge(left=c2_746_pheno_info_SHARE, right=c2_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
c2_SHARE_AA = pd.merge(left=c2_746_pheno_info_SHARE_AA, right=c2_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')
c2_SHARE_HA = pd.merge(left=c2_746_pheno_info_SHARE_HA, right=c2_WHI_Sample_filt_746_final, how='left', left_on='dbGaP_Sample_ID', right_on='dbGaP_Sample_ID')


# Create a new dataframe which contains the phenotype data relevant to the GWAS. First, an empty df is created and db_GaP_Subject_ID is added using form 2, as it contains basic information about the patients,
# without which we cannot control for key confounders - hence this information is essential:

# Create empty DF with subject ID column based on form 2

c1_subject_ID = pd.DataFrame()
c1_subject_ID['dbGaP_Subject_ID'] = c1_form2['dbGaP_Subject_ID']

c2_subject_ID = pd.DataFrame()
c2_subject_ID['dbGaP_Subject_ID'] = c2_form2['dbGaP_Subject_ID']

# - Merge the necessary columns to the above dfs:

# Extract and merge the columns needed for consent group 1 

c1_mydf = pd.DataFrame()
c1_mydf['dbGaP_Subject_ID'] = c1_subject_ID['dbGaP_Subject_ID']

c1_mydf = pd.merge(left=c1_mydf, right=c1_form2[['dbGaP_Subject_ID', 'AGE', 'RACE', 'DIAB']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_form41[['dbGaP_Subject_ID','SPANISH', 'BLACK']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_form30[['dbGaP_Subject_ID', 'PANCREAT']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_outc_ct_os[['dbGaP_Subject_ID', 'PANCREASDY', 'DEATH','DEATHDY', 'ENDWHIDY', 'ENDFOLLOWDY']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_pancan_occ[['dbGaP_Subject_ID', 'PANCREAS', 'ICDCODE', 'BEHAVIOR', 'DIAGSTAT', 'LATERAL', 'MRPHHISTB', 'GRADING', 'SIZE', 'STAGE']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_form80_BMI, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_mydf = pd.merge(left=c1_mydf, right=c1_form80_WHRX[['dbGaP_Subject_ID', 'WHRX']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


# Extract and merge the columns needed for consent group 2

c2_mydf = pd.DataFrame()
c2_mydf['dbGaP_Subject_ID'] = c2_subject_ID['dbGaP_Subject_ID']

c2_mydf = pd.merge(left=c2_mydf, right=c2_form2[['dbGaP_Subject_ID', 'AGE', 'RACE', 'DIAB']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_form41[['dbGaP_Subject_ID','SPANISH', 'BLACK']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_form30[['dbGaP_Subject_ID', 'PANCREAT']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_outc_ct_os[['dbGaP_Subject_ID', 'PANCREASDY', 'DEATH','DEATHDY', 'ENDWHIDY', 'ENDFOLLOWDY']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_pancan_occ[['dbGaP_Subject_ID', 'PANCREAS', 'ICDCODE', 'BEHAVIOR', 'DIAGSTAT', 'LATERAL', 'MRPHHISTB', 'GRADING', 'SIZE', 'STAGE']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_form80_BMI[['dbGaP_Subject_ID', 'BMIX']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_mydf = pd.merge(left=c2_mydf, right=c2_form80_WHRX[['dbGaP_Subject_ID', 'WHRX']], how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')

# Clean and transform the datasets
## Rename the columns

c1_mydf = c1_mydf.rename(columns={"RACE": "race", "DIAB": "HISTORY_DIABETES", "SPANISH": "SPANISH_RACE", "PANCREAT": "PANCREATITIS", "PANCREASDY": "AGE_DIAGNOSED", "DEATH": "DECEASED", "DEATHDY": "AGE_DEATH", "ENDFOLLOWDY": "AGE_END_FOLLOW", "PANCREAS": "PAN_CAN","ICDCODE": "PAN_CAN_LOCATION","BEHAVIOR": "TUMOUR_BEHAVIOUR", "DIAGSTAT": "DIAGNOSIS_STATUS", "LATERAL": "LATERALITY", "MRPHHISTB": "TUMOUR_MORPHOLOGY", "GRADING": "TUMOUR_GRADE", "SIZE": "TUMOUR_SIZE", "STAGE": "TUMOUR_STAGE", "BMIX": "MEAN_BMI", "WHRX": "MEAN_WHR"})

c2_mydf = c2_mydf.rename(columns={"RACE": "race", "DIAB": "HISTORY_DIABETES", "SPANISH": "SPANISH_RACE", "PANCREAT": "PANCREATITIS", "PANCREASDY": "AGE_DIAGNOSED", "DEATH": "DECEASED", "DEATHDY": "AGE_DEATH", "ENDFOLLOWDY": "AGE_END_FOLLOW", "PANCREAS": "PAN_CAN","ICDCODE": "PAN_CAN_LOCATION","BEHAVIOR": "TUMOUR_BEHAVIOUR", "DIAGSTAT": "DIAGNOSIS_STATUS", "LATERAL": "LATERALITY", "MRPHHISTB": "TUMOUR_MORPHOLOGY", "GRADING": "TUMOUR_GRADE", "SIZE": "TUMOUR_SIZE", "STAGE": "TUMOUR_STAGE", "BMIX": "MEAN_BMI", "WHRX": "MEAN_WHR"})


# Transform the columns as required for the analysis. Further information can be found within the WHI_SHARE_phenovariables_plan.xml file in the project directory.

##  Convert age days enrolled from diagnosis to age diagnosed

c1_mydf.AGE_DIAGNOSED = c1_mydf.AGE + (c1_mydf.AGE_DIAGNOSED / 365)
c2_mydf.AGE_DIAGNOSED = c2_mydf.AGE + (c2_mydf.AGE_DIAGNOSED / 365)

##Convert days till death to age of death in years

c1_mydf.AGE_DIAGNOSED = c1_mydf.AGE + (c1_mydf.AGE_DIAGNOSED / 365)
c2_mydf.AGE_DIAGNOSED = c2_mydf.AGE + (c2_mydf.AGE_DIAGNOSED / 365)

## Calculate number of months survived with pancreatic cancer

c1_mydf['PAN_CAN_MONTHS_SURVIVED'] = (c1_mydf.AGE_DEATH - c1_mydf.AGE_DIAGNOSED) * 12
c2_mydf['PAN_CAN_MONTHS_SURVIVED'] = (c2_mydf.AGE_DEATH - c2_mydf.AGE_DIAGNOSED) * 12

## Convert the number of days till end follow up to their age at end of follow up

c1_mydf.AGE_END_FOLLOW = c1_mydf.AGE+(c1_mydf.AGE_END_FOLLOW / 365)
c2_mydf.AGE_END_FOLLOW = c2_mydf.AGE+(c2_mydf.AGE_END_FOLLOW / 365)

## Finally, extract patients from the mydf dataframes onto the SHARE dataframes created earlier, so that only patients in the SHARE substudy are present in the phenotype files

c1_SHARE_AA_pheno = pd.merge(left=c1_SHARE_AA, right=c1_mydf, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c1_SHARE_HA_pheno = pd.merge(left=c1_SHARE_HA, right=c1_mydf, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')


c2_SHARE_AA_pheno = pd.merge(left=c2_SHARE_AA, right=c2_mydf, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')
c2_SHARE_HA_pheno = pd.merge(left=c2_SHARE_HA, right=c2_mydf, how='left', left_on='dbGaP_Subject_ID', right_on='dbGaP_Subject_ID')

# Modift col names

## Add column denoting sex:

c1_SHARE_AA_pheno['sex'] = 'F'
c1_SHARE_HA_pheno['sex'] = 'F'

c2_SHARE_AA_pheno['sex'] = 'F'
c2_SHARE_HA_pheno['sex'] = 'F'


## Rename dbgap sample id to scanid

c1_SHARE_AA_pheno = c1_SHARE_AA_pheno.rename(columns={"dbGaP_Sample_ID": "FIID"})
c1_SHARE_HA_pheno = c1_SHARE_HA_pheno.rename(columns={"dbGaP_Sample_ID": "FIID"})

c2_SHARE_AA_pheno = c2_SHARE_AA_pheno.rename(columns={"dbGaP_Sample_ID": "FIID"})
c2_SHARE_HA_pheno = c2_SHARE_HA_pheno.rename(columns={"dbGaP_Sample_ID": "FIID"})

# Combine the consent groups

cb_SHARE_AA_pheno = pd.concat([c1_SHARE_AA_pheno, c2_SHARE_AA_pheno], axis=0)
cb_SHARE_HA_pheno = pd.concat([c1_SHARE_HA_pheno, c2_SHARE_HA_pheno], axis=0)

# Output dataframes for use in later analyses.

c1_SHARE_AA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/c1_SHARE_AA_pheno_full.csv', sep='\t', index=False)
c1_SHARE_HA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/c1_SHARE_HA_pheno_full.csv', sep='\t', index=False)

c2_SHARE_AA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/c2_SHARE_AA_pheno_full.csv', sep='\t', index=False)
c2_SHARE_HA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/c2_SHARE_HA_pheno_full.csv', sep='\t', index=False)

cb_SHARE_AA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/cb_SHARE_AA_pheno_full.csv', sep='\t', index=False)
cb_SHARE_HA_pheno.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/cb_SHARE_HA_pheno_full.csv', sep='\t', index=False)


# Create new df with only covariates

SHARE_aa_covar = cb_SHARE_AA_pheno[["FIID", "FIID", "AGE", "HISTORY_DIABETES", "PANCREATITIS", "MEAN_BMI", "MEAN_WHR"]].copy()
SHARE_ha_covar = cb_SHARE_HA_pheno[["FIID", "FIID", "AGE", "HISTORY_DIABETES", "PANCREATITIS", "MEAN_BMI", "MEAN_WHR"]].copy()

SHARE_aa_covar.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/SHARE_aa_covar.csv', sep='\t', index=False)
SHARE_ha_covar.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/pheno/plink/SHARE_ha_covar.csv', sep='\t', index=False)