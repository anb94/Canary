#!/usr/bin/env bash
# Smoke-test convert-mac-module.sh, correct-plinkfiles.sh, and
# combine-datasets-module.sh on the synthetic MaCH files from
# generate_dummy_mach.py.
#
# Prerequisites on PATH: gawk, dose2plink, plink2, plink (1.9).
# Does not build the Singularity image.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTDIR="$(cd "$(dirname "$0")" && pwd)"
GEN="${TESTDIR}/dummy-mach"
WORK="${TESTDIR}/work"
REPORT="${WORK}/smoke-test-report.txt"
CONVERT="${ROOT}/convert-mac-module.sh"
CORRECT="${ROOT}/correct-plinkfiles.sh"
COMBINE="${ROOT}/combine-datasets-module.sh"

PASS=0
FAIL=0
notes=()

log() {
  printf '%s\n' "$*" | tee -a "${REPORT}"
}

check() {
  local desc="$1"
  shift
  if "$@"; then
    log "PASS  ${desc}"
    PASS=$((PASS + 1))
    return 0
  else
    log "FAIL  ${desc}"
    FAIL=$((FAIL + 1))
    return 0
  fi
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "ERROR: '$1' is not on PATH. ${2:-}"
    exit 2
  fi
}

rm -rf "${WORK}"
mkdir -p "${WORK}"
: > "${REPORT}"

log "Canary dummy-data smoke test"
log "repo: ${ROOT}"
log "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
log ""

need_cmd gawk "convert-mac-module.sh and the later scripts call gawk, not awk."
need_cmd dose2plink "compile from canary-container.def (anb94/plink-ng dose2plink.c, gcc -lz)."
need_cmd plink2 "used by correct-plinkfiles.sh and combine-datasets-module.sh."
need_cmd plink "PLINK 1.9, used by combine-datasets-module.sh --merge-list."

log "tools:"
log "  gawk      $(gawk --version | head -1)"
log "  dose2plink $(dose2plink -h 2>&1 | head -1 || true)"
log "  plink     $(plink --version 2>/dev/null | head -1)"
log "  plink2    $(plink2 --version 2>/dev/null | head -1)"
log ""

python3 "${TESTDIR}/generate_dummy_mach.py" -o "${GEN}"

# --- convert-mac-module.sh (SHARE, two consent groups, chr 1–22) ---
log ""
log "=== convert-mac-module.sh SHARE ==="
set +e
"${CONVERT}" -h >/tmp/canary-convert-help.txt 2>&1
help_rc=$?
set -e
check "convert-mac -h prints usage" grep -q "convert-mac-module.sh -c DIR" /tmp/canary-convert-help.txt
if [[ "${help_rc}" -ne 0 ]]; then
  notes+=("convert-mac-module.sh -h exits ${help_rc} (help is wired to exit 1).")
fi

mkdir -p "${WORK}/SHARE"
set +e
"${CONVERT}" \
  -c "${GEN}/SHARE/consentgroup1" \
  -c "${GEN}/SHARE/consentgroup2" \
  -n SHARE \
  -o "${WORK}/SHARE" \
  > "${WORK}/SHARE/convert.log" 2>&1
convert_rc=$?
set -e
check "convert-mac-module.sh exits 0 on SHARE dummy data" test "${convert_rc}" -eq 0
if [[ "${convert_rc}" -ne 0 ]]; then
  log "----- convert.log (tail) -----"
  tail -n 80 "${WORK}/SHARE/convert.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "SHARE_chr1.dose through SHARE_chr22.dose exist" \
  test -f "${WORK}/SHARE/SHARE_chr1.dose" -a -f "${WORK}/SHARE/SHARE_chr22.dose"
check "SHARE_chr1.info through SHARE_chr22.info exist" \
  test -f "${WORK}/SHARE/SHARE_chr1.info" -a -f "${WORK}/SHARE/SHARE_chr22.info"
check "SHARE_allchr.pdat exists" test -f "${WORK}/SHARE/SHARE_allchr.pdat"
check "SHARE_allchr.pfam exists" test -f "${WORK}/SHARE/SHARE_allchr.pfam"
check "SHARE_allchr.tsv is a copy of the pfam" test -f "${WORK}/SHARE/SHARE_allchr.tsv"

# Concatenation: 3 + 2 samples. A chr1 glob that also matched chr10 would yield 10.
c1_n=$(wc -l < "${WORK}/SHARE/SHARE_chr1.dose")
c10_n=$(wc -l < "${WORK}/SHARE/SHARE_chr10.dose")
check "chr1 dose has 5 sample rows (not chr10 mixed in)" test "${c1_n}" -eq 5
check "chr10 dose has 5 sample rows" test "${c10_n}" -eq 5
check "concatenated chr1 dose contains SHARE01 and SHARE04" \
  grep -q "SHARE01->SHARE01" "${WORK}/SHARE/SHARE_chr1.dose"
check "concatenated chr1 dose contains consent-group-2 sample SHARE04" \
  grep -q "SHARE04->SHARE04" "${WORK}/SHARE/SHARE_chr1.dose"

# Info is copied from the first consent group only.
check "chr1 info matches consentgroup1 (copied, not rebuilt)" \
  cmp -s "${GEN}/SHARE/consentgroup1/SHAREchr1aa.info" "${WORK}/SHARE/SHARE_chr1.info"

# QC log: info rows = 5 (header+4 SNPs), dose columns = 6 (FID->IID, MLDOSE, 4 dosages).
check "QC log has 22 chromosome lines" \
  test "$(grep -c "^Chromosome" "${WORK}/SHARE/SHARE_qc-checklength.log")" -eq 22
check "QC log reports chr1 info 5 rows and dose 6 columns" \
  grep -q "Chromosome '1' info has '5' rows and dose has '6' columns" \
    "${WORK}/SHARE/SHARE_qc-checklength.log"

# LQ filters (GNU awk): the info header is skipped because "Rsq" is not < 0.3.
lq03=$(grep -c . "${WORK}/SHARE/SHARE_all_chr_lq03_snps.txt")
lq08=$(grep -c . "${WORK}/SHARE/SHARE_all_chr_lq08_snps.txt")
lqall=$(grep -c . "${WORK}/SHARE/SHARE_all_chr_lq_all_snps.txt")
check "lq03 list has 22 lines (one Rsq<0.3 SNP per chromosome)" test "${lq03}" -eq 22
check "lq08 list has 44 lines (two Rsq<0.8 SNPs per chromosome)" test "${lq08}" -eq 44
check "combined LQ list is lq03+lq08 (66 lines)" test "${lqall}" -eq 66
check "lq03 does not include the info header token SNP" \
  test "$(grep -cx "SNP" "${WORK}/SHARE/SHARE_all_chr_lq03_snps.txt" || true)" -eq 0
check "lq03 contains a chr:pos SNP with Rsq 0.10" \
  grep -qx "1:300001" "${WORK}/SHARE/SHARE_all_chr_lq03_snps.txt"
check "lq08 contains a chr:pos SNP with Rsq 0.55" \
  grep -qx "1:200001" "${WORK}/SHARE/SHARE_all_chr_lq08_snps.txt"
check "high-Rsq chr:pos SNP is not in lq08" \
  test "$(grep -cx "1:100001" "${WORK}/SHARE/SHARE_all_chr_lq08_snps.txt" || true)" -eq 0

# pdat: 1 header + 22*4 SNP rows. pfam: 5 samples, dose2plink sex=1, pheno=-9.
pdat_n=$(wc -l < "${WORK}/SHARE/SHARE_allchr.pdat")
pfam_n=$(wc -l < "${WORK}/SHARE/SHARE_allchr.pfam")
check "allchr.pdat has 89 lines (header + 88 SNPs)" test "${pdat_n}" -eq 89
check "allchr.pfam has 5 samples" test "${pfam_n}" -eq 5
check "pdat starts with SNP A1 A2 header" \
  test "$(head -1 "${WORK}/SHARE/SHARE_allchr.pdat" | cut -f1-3)" = $'SNP\tA1\tA2'
check "pdat contains chr:pos SNP 1:100001" \
  grep -q $'^1:100001\t' "${WORK}/SHARE/SHARE_allchr.pdat"
check "pdat contains rsID rs01001" \
  grep -q $'^rs01001\t' "${WORK}/SHARE/SHARE_allchr.pdat"

# --- correct-plinkfiles.sh (single dataset) ---
log ""
log "=== correct-plinkfiles.sh SHARE ==="
cp "${GEN}/SHARE/SHARE_pheno.tsv" "${WORK}/SHARE/"
cp "${GEN}/SHARE/SHARE_covar.tsv" "${WORK}/SHARE/"

set +e
"${CORRECT}" -d "${WORK}/SHARE" -n SHARE > "${WORK}/SHARE/correct.log" 2>&1
correct_rc=$?
set -e
check "correct-plinkfiles.sh exits 0 on SHARE dummy data" test "${correct_rc}" -eq 0
if [[ "${correct_rc}" -ne 0 ]]; then
  log "----- correct.log (tail) -----"
  tail -n 80 "${WORK}/SHARE/correct.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "SHARE_plink1_temp1_updated.bed exists" test -f "${WORK}/SHARE/SHARE_plink1_temp1_updated.bed"
check "SHARE_plink1_temp1_updated.bim exists" test -f "${WORK}/SHARE/SHARE_plink1_temp1_updated.bim"
check "SHARE_plink1_temp1_updated.fam exists" test -f "${WORK}/SHARE/SHARE_plink1_temp1_updated.fam"

if [[ -f "${WORK}/SHARE/SHARE_plink1_temp1_updated.bim" ]]; then
  bim_n=$(wc -l < "${WORK}/SHARE/SHARE_plink1_temp1_updated.bim")
  # 88 SNPs minus 44 LQ (22 lq08-only + 22 lq03) = 44 kept (22 chr:pos high + 22 rs).
  check "updated bim has 44 variants (LQ SNPs excluded)" test "${bim_n}" -eq 44
  check "chr:pos correction set chr=1 pos=100001 for 1:100001" \
    grep -q $'^1\t1:100001\t0\t100001\t' "${WORK}/SHARE/SHARE_plink1_temp1_updated.bim"
  # rsIDs have no colon, so the gawk split leaves an empty position field.
  rs_line=$(grep $'\trs01001\t' "${WORK}/SHARE/SHARE_plink1_temp1_updated.bim" || true)
  check "rs01001 remains in the updated bim" test -n "${rs_line}"
  if [[ -n "${rs_line}" ]]; then
    rs_chr=$(printf '%s\n' "${rs_line}" | cut -f1)
    rs_pos=$(printf '%s\n' "${rs_line}" | cut -f4)
    if [[ "${rs_chr}" == "rs01001" && -z "${rs_pos}" ]]; then
      log "PASS  rsID chr/pos correction left chrom=rs01001 and empty POS (expected for non chr:pos IDs)"
      PASS=$((PASS + 1))
    else
      log "FAIL  rsID chr/pos correction: expected chrom=rs01001 empty POS, got chrom='${rs_chr}' pos='${rs_pos}'"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

if [[ -f "${WORK}/SHARE/SHARE_plink1_temp1_updated.fam" ]]; then
  fam_n=$(wc -l < "${WORK}/SHARE/SHARE_plink1_temp1_updated.fam")
  check "updated fam has 5 samples" test "${fam_n}" -eq 5
  check "phenotype case status reached the fam (SHARE01 is case 2)" \
    grep -q $'^SHARE01\tSHARE01\t0\t0\t1\t2$' "${WORK}/SHARE/SHARE_plink1_temp1_updated.fam"
fi

# --- combine-datasets-module.sh (GARNET + WHIMS) ---
log ""
log "=== convert-mac + combine-datasets-module.sh GARNET/WHIMS ==="
mkdir -p "${WORK}/GARNET" "${WORK}/WHIMS" "${WORK}/WHI"
set +e
"${CONVERT}" -c "${GEN}/GARNET/consentgroup1" -n GARNET -o "${WORK}/GARNET" \
  > "${WORK}/GARNET/convert.log" 2>&1
garnet_rc=$?
"${CONVERT}" -c "${GEN}/WHIMS/consentgroup1" -n WHIMS -o "${WORK}/WHIMS" \
  > "${WORK}/WHIMS/convert.log" 2>&1
whims_rc=$?
set -e
check "convert-mac GARNET exits 0" test "${garnet_rc}" -eq 0
check "convert-mac WHIMS exits 0" test "${whims_rc}" -eq 0
cp "${GEN}/GARNET/GARNET_pheno.tsv" "${GEN}/GARNET/GARNET_covar.tsv" "${WORK}/GARNET/"
cp "${GEN}/WHIMS/WHIMS_pheno.tsv" "${GEN}/WHIMS/WHIMS_covar.tsv" "${WORK}/WHIMS/"

set +e
"${COMBINE}" \
  -d "${WORK}/GARNET" \
  -d "${WORK}/WHIMS" \
  -n WHI \
  -o "${WORK}/WHI" \
  > "${WORK}/WHI/combine.log" 2>&1
combine_rc=$?
set -e
check "combine-datasets-module.sh exits 0" test "${combine_rc}" -eq 0
if [[ "${combine_rc}" -ne 0 ]]; then
  log "----- combine.log (tail) -----"
  tail -n 100 "${WORK}/WHI/combine.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "merged WHI_temp2_updated.bed exists" test -f "${WORK}/WHI/WHI_temp2_updated.bed"
check "merged WHI_temp2_updated.bim exists" test -f "${WORK}/WHI/WHI_temp2_updated.bim"
check "merged WHI_temp2_updated.fam exists" test -f "${WORK}/WHI/WHI_temp2_updated.fam"

if [[ -f "${WORK}/WHI/WHI_sharedsnps.tsv" ]]; then
  shared_n=$(wc -l < "${WORK}/WHI/WHI_sharedsnps.tsv")
  # 22 chr x 2 shared SNPs (keep + lq08)
  check "shared SNP list has 44 rows" test "${shared_n}" -eq 44
fi

if [[ -f "${WORK}/WHI/WHI_lq_all_snps.txt" ]]; then
  # convert concatenates lq03+lq08, so Rsq<0.3 SNPs appear twice. combine then
  # uses sort | uniq -u, which DROPS any line that is not unique.
  uniq_u_n=$(wc -l < "${WORK}/WHI/WHI_lq_all_snps.txt")
  log "NOTE  combined LQ list (sort | uniq -u) has ${uniq_u_n} lines"
  notes+=("combine-datasets-module.sh builds WHI_lq_all_snps.txt with 'uniq -u' (unique lines only). Lines that appear more than once are dropped. The plink2 import actually excludes each dataset's own *_lq_all_snps.txt, so this combined list is unused.")
fi

if [[ -f "${WORK}/WHI/WHI_temp2_updated.bim" ]]; then
  merge_n=$(wc -l < "${WORK}/WHI/WHI_temp2_updated.bim")
  log "NOTE  merged bim variant count: ${merge_n}"
  # Shared keep SNP should be present and have chr/pos filled.
  check "merged bim contains shared SNP 1:100000 with chr/pos filled" \
    grep -q $'^1\t1:100000\t0\t100000\t' "${WORK}/WHI/WHI_temp2_updated.bim"
  check "merged bim does not contain GARNET-only SNP 1:410000" \
    test "$(grep -c $'\t1:410000\t' "${WORK}/WHI/WHI_temp2_updated.bim" || true)" -eq 0
  check "merged bim does not contain WHIMS-only SNP 1:510000" \
    test "$(grep -c $'\t1:510000\t' "${WORK}/WHI/WHI_temp2_updated.bim" || true)" -eq 0
fi

if [[ -f "${WORK}/WHI/WHI_temp2_updated.fam" ]]; then
  merge_fam=$(wc -l < "${WORK}/WHI/WHI_temp2_updated.fam")
  check "merged fam has 5 samples (3 GARNET + 2 WHIMS)" test "${merge_fam}" -eq 5
fi

if [[ -f "${WORK}/WHI/WHI_temp2_updated.bed" ]]; then
  plink --bfile "${WORK}/WHI/WHI_temp2_updated" --missing --out "${WORK}/WHI/whi-missing" --allow-no-sex \
    > "${WORK}/WHI/missing.log" 2>&1 || true
  # Dummy dosages are 0/1/2, so hard-called merge should be complete.
  check "merged genotyping rate is 1 (hard calls from 0/1/2 dummy dosages)" \
    grep -Eq "genotyping rate is (exactly )?1" "${WORK}/WHI/missing.log"
fi

log ""
log "=== summary ==="
log "passed: ${PASS}"
log "failed: ${FAIL}"
if ((${#notes[@]})); then
  log ""
  log "notes:"
  for n in "${notes[@]}"; do
    log "  - ${n}"
  done
fi
log ""
log "artifacts: ${WORK}"
log "dummy input: ${GEN}"

if [[ "${FAIL}" -ne 0 ]]; then
  exit 1
fi
exit 0
