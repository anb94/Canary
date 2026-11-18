# Dummy MaCH data and Canary smoke test

This directory is a small, synthetic MaCH/minimac dosage dataset plus a runner
that exercises the conversion scripts on current `main`. It is not a substitute
for WHI-scale files.

## What it covers

1. `convert-mac-module.sh` on **SHARE**: two consent groups, chromosomes 1–22,
   concatenation, `.info` copy, Rsq 0.3 / 0.8 low-quality lists, the row/column
   QC log, `dose2plink`, and `SHARE_allchr.pdat` / `.pfam`.
2. `correct-plinkfiles.sh` on that SHARE output, with matching
   `SHARE_pheno.tsv` and `SHARE_covar.tsv`.
3. `combine-datasets-module.sh` on **GARNET** and **WHIMS**, which share some
   SNPs and differ on others.

It does **not** build the Singularity/Apptainer image. Compile or install
`dose2plink`, PLINK 2, and PLINK 1.9 on the host (the same sources as
`canary-container.def`) and put them on `PATH`.

## Dummy layout (after generation)

| Dataset | Consent groups | Samples | SNPs / chromosome |
| --- | --- | --- | --- |
| SHARE | `consentgroup1`, `consentgroup2` | 5 (3+2) | 4 |
| GARNET | `consentgroup1` | 3 | 4 |
| WHIMS | `consentgroup1` | 2 | 4 |

Names look like `SHAREchr1aa.dose.c1` and `SHAREchr1aa.info` so a search for
chromosome 1 cannot also match `chr10`–`chr19`.

SHARE SNPs on chromosome *N*:

- `N:(100000+N)` — Rsq 0.95, chr:pos ID (kept; chr/pos correction should fill)
- `N:(200000+N)` — Rsq 0.55 (low-quality at 0.8)
- `N:(300000+N)` — Rsq 0.10 (low-quality at 0.3 and 0.8)
- `rsN001` — Rsq 0.99, rs ID (kept; chr/pos correction cannot parse it)

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
