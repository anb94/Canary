# Toy MaCH data and Canary smoke test

This directory is a small, synthetic MaCH/minimac dosage dataset plus a runner
that exercises the conversion scripts on current `main`. It is not a substitute
for large real filesets.

The toy cohort prefixes are coined: **ZYQLOT**, **NULDRA**, **JIVCAL**, and
**ZYQMRG**. They are not the name, acronym, or nickname of a real cohort,
biobank, or dbGaP study.

## What it covers

1. `convert-mac-module.sh` on **ZYQLOT**: two input groups, chromosomes 1–22,
   concatenation, `.info` copy, Rsq 0.3 / 0.8 low-quality lists, the row/column
   QC log, `dose2plink`, and `ZYQLOT_allchr.pdat` / `.pfam`.
2. `correct-plinkfiles.sh` on that ZYQLOT output, with matching
   `ZYQLOT_pheno.tsv` and `ZYQLOT_covar.tsv`.
3. `combine-datasets-module.sh` on **NULDRA** and **JIVCAL**, which share some
   SNPs and differ on others. Merged files use the prefix **ZYQMRG**.

It does **not** build the Singularity/Apptainer image. Compile or install
`dose2plink`, PLINK 2, and PLINK 1.9 on the host (the same sources as
`canary-container.def`) and put them on `PATH`.

## Dummy layout (after generation)

| Dataset | Input groups | Samples | SNPs / chromosome |
| --- | --- | --- | --- |
| ZYQLOT | `group_a`, `group_b` | 5 (3+2) | 4 |
| NULDRA | `group_a` | 3 | 4 |
| JIVCAL | `group_a` | 2 | 4 |

Names look like `ZYQLOTchr1q.dose.a` and `ZYQLOTchr1q.info` so a search for
chromosome 1 cannot also match `chr10`–`chr19`. The letter `q` after the
chromosome number is a dummy tag required by that glob; it is not an ancestry
or study code.

Every SNP ID is `chr:pos` or `chr:pos:ref:alt`. There are no rs IDs.
`correct-plinkfiles.sh` fills chromosome and position by splitting the SNP ID
on `:`, so these IDs are what that step expects.

ZYQLOT SNPs on chromosome *N*:

- `N:(100000+N)` — Rsq 0.95, chr:pos (kept; chr/pos correction fills numeric chr and POS)
- `N:(200000+N)` — Rsq 0.55 (low-quality at 0.8)
- `N:(300000+N)` — Rsq 0.10 (low-quality at 0.3 and 0.8)
- `N:(400000+N):G:C` — Rsq 0.99, chr:pos:ref:alt (kept; correction uses the first two colon fields)

Each `.dose` line is `FID->IID MLDOSE <dosages>`. Dosages are 0, 1, or 2 so
the PLINK 1 merge in `combine-datasets-module.sh` is not dominated by missing
hard calls. `.info` is MaCH mlinfo with Rsq in column 7. Phenotype/covariate
files are not produced by convert-mac; the generator writes `PREFIX_pheno.tsv`
and `PREFIX_covar.tsv` beside each dataset’s input folder, and the runner
copies them in after conversion.

## Commands

```bash
# Once: gawk, gcc, zlib headers, then:
curl -O https://raw.githubusercontent.com/anb94/plink-ng/master/1.9/dose2plink.c
gcc dose2plink.c -lz -O2 -o dose2plink
# plus PLINK 1.9 and PLINK 2 from the URLs in canary-container.def

python3 testdata/generate_dummy_mach.py
bash testdata/run_smoke_test.sh
```

Generated input lives in `testdata/dummy-mach/`. Script output and the text
report live in `testdata/work/` (gitignored). Re-run the generator or the
smoke test at any time; both replace those trees.
