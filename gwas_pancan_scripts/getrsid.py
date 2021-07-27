import pandas as pd
import numpy as np

SHARE_aa_pos = pd.read_csv("/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_aa.genotype/SHARE_aa.pos", sep="\t", comment='#')
SHARE_ha_pos = pd.read_csv("/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_ha.genotype/SHARE_ha.pos", sep="\t", comment='#')
snp_annot_grch37_nodups = pd.read_csv("/home/anbennett2/scratch/snp_annot_grch37_nodups.txt", sep="\t", comment='#')
snp_annot_grch37_nodups.columns = ['CHROM', 'POS', 'ID', 'REF', 'ALT', 'CHR_POS']

SHARE_aa_rsid = pd.merge(left=SHARE_aa_pos, right=snp_annot_grch37_nodups[['CHR_POS', 'rsid']], how='left', left_on='CHR_POS', right_on='CHR_POS')
SHARE_ha_rsid = pd.merge(left=SHARE_ha_pos, right=snp_annot_grch37_nodups[['CHR_POS', 'rsid']], how='left', left_on='CHR_POS', right_on='CHR_POS')

# Create empty dataframe
df1 = pd.DataFrame()
# Copy the chromosome position column from the rsid df to the new dataframe
df1['col1'] = SHARE_aa_rsid['CHR_POS'].copy()
df1['col1'] = df1.col1.replace({":": ""},regex=True)
df1['col1'] ='id' + df1['col1'].astype(str)
df1['col2'] = SHARE_aa_rsid['rsid'].fillna(df1.col1)
SHARE_aa_rsid['all_id'] = df1['col2'].copy()

df2 = pd.DataFrame()
df2['col1'] = SHARE_ha_rsid['CHR_POS'].copy()
df2['col1'] = df2.col1.replace({":": ""},regex=True)
df2['col1'] ='id' + df2['col1'].astype(str)
df2['col2'] = SHARE_ha_rsid['rsid'].fillna(df2.col1)
SHARE_ha_rsid['all_id'] = df2['col2'].copy()



SHARE_aa_rsid.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_aa.genotype/SHARE_aa_rsid.txt', sep='\t', index=False)
SHARE_ha_rsid.to_csv('/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_ha.genotype/SHARE_ha_rsid.txt', sep='\t', index=False)

#SHARE_aa_rsid = pd.read_csv("/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_aa.genotype/SHARE_aa_rsid.txt", sep="\t", comment='#')
#SHARE_ha_rsid = pd.read_csv("/home/anbennett2/scratch/dbgap_data/WHI/combined_consentgroups/geno/WHI_SHARE_ha.genotype/SHARE_ha_rsid.txt", sep="\t", comment='#')
