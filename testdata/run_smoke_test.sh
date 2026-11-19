#!/usr/bin/env bash
# Smoke-test convert-mac-module.sh, correct-plinkfiles.sh, and
# combine-datasets-module.sh on the synthetic MaCH files from
# generate_dummy_mach.py.
#
# Toy prefixes (ZYQLOT, NULDRA, JIVCAL, ZYQMRG) are coined and are not
# real study names.
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

PRIMARY=ZYQLOT
SECOND=NULDRA
THIRD=JIVCAL
MERGED=ZYQMRG

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

# Every remaining .bim row must have a numeric chromosome, a colon-delimited
# SNP ID, and a numeric POS. correct-plinkfiles.sh fills those fields by
# splitting the ID on ':'; rs IDs would leave chrom=rs… and a blank POS.
bim_chr_pos_clean() {
  local bim="$1"
  gawk 'BEGIN{FS="\t"; bad=0}
    $1 !~ /^[0-9]+$/ { print "non-numeric chrom: " $0; bad=1 }
    $2 !~ /^[0-9]+:[0-9]+/ { print "ID is not chr:pos…: " $0; bad=1 }
    $2 ~ /^rs/ { print "rs ID: " $0; bad=1 }
    $4 !~ /^[0-9]+$/ { print "non-numeric or blank POS: " $0; bad=1 }
    END{ exit bad }' "${bim}"
}

rm -rf "${WORK}"
mkdir -p "${WORK}"
: > "${REPORT}"

log "Canary dummy-data smoke test"
log "repo: ${ROOT}"
log "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
log "toy prefixes: ${PRIMARY} (convert+correct), ${SECOND}+${THIRD} (combine), ${MERGED} (merge output)"
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

check "generated tree has no leftover dirs from the earlier branded dummy" \
  test ! -e "${GEN}/SHARE" -a ! -e "${GEN}/GARNET" -a ! -e "${GEN}/WHIMS" -a ! -e "${GEN}/WHI"
no_rs_ids_in_info() {
  ! grep -R --include='*.info' -q '^rs' "${GEN}"
}
check "generated .info files contain no rs SNP IDs" no_rs_ids_in_info

# --- convert-mac-module.sh (ZYQLOT, two groups, chr 1–22) ---
log ""
log "=== convert-mac-module.sh ${PRIMARY} ==="
set +e
"${CONVERT}" -h >/tmp/canary-convert-help.txt 2>&1
help_rc=$?
set -e
check "convert-mac -h prints usage" grep -q "convert-mac-module.sh -c DIR" /tmp/canary-convert-help.txt
if [[ "${help_rc}" -ne 0 ]]; then
  notes+=("convert-mac-module.sh -h exits ${help_rc} (help is wired to exit 1).")
fi

mkdir -p "${WORK}/${PRIMARY}"
set +e
"${CONVERT}" \
  -c "${GEN}/${PRIMARY}/group_a" \
  -c "${GEN}/${PRIMARY}/group_b" \
  -n "${PRIMARY}" \
  -o "${WORK}/${PRIMARY}" \
  > "${WORK}/${PRIMARY}/convert.log" 2>&1
convert_rc=$?
set -e
check "convert-mac-module.sh exits 0 on ${PRIMARY} dummy data" test "${convert_rc}" -eq 0
if [[ "${convert_rc}" -ne 0 ]]; then
  log "----- convert.log (tail) -----"
  tail -n 80 "${WORK}/${PRIMARY}/convert.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "${PRIMARY}_chr1.dose through ${PRIMARY}_chr22.dose exist" \
  test -f "${WORK}/${PRIMARY}/${PRIMARY}_chr1.dose" -a -f "${WORK}/${PRIMARY}/${PRIMARY}_chr22.dose"
check "${PRIMARY}_chr1.info through ${PRIMARY}_chr22.info exist" \
  test -f "${WORK}/${PRIMARY}/${PRIMARY}_chr1.info" -a -f "${WORK}/${PRIMARY}/${PRIMARY}_chr22.info"
check "${PRIMARY}_allchr.pdat exists" test -f "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat"
check "${PRIMARY}_allchr.pfam exists" test -f "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pfam"
check "${PRIMARY}_allchr.tsv is a copy of the pfam" test -f "${WORK}/${PRIMARY}/${PRIMARY}_allchr.tsv"

# Concatenation: 3 + 2 samples. A chr1 glob that also matched chr10 would yield 10.
c1_n=$(wc -l < "${WORK}/${PRIMARY}/${PRIMARY}_chr1.dose")
c10_n=$(wc -l < "${WORK}/${PRIMARY}/${PRIMARY}_chr10.dose")
check "chr1 dose has 5 sample rows (not chr10 mixed in)" test "${c1_n}" -eq 5
check "chr10 dose has 5 sample rows" test "${c10_n}" -eq 5
check "concatenated chr1 dose contains ZYQLOT01 from group_a" \
  grep -q "ZYQLOT01->ZYQLOT01" "${WORK}/${PRIMARY}/${PRIMARY}_chr1.dose"
check "concatenated chr1 dose contains ZYQLOT04 from group_b" \
  grep -q "ZYQLOT04->ZYQLOT04" "${WORK}/${PRIMARY}/${PRIMARY}_chr1.dose"

# Info is copied from the first input group only.
check "chr1 info matches group_a (copied, not rebuilt)" \
  cmp -s "${GEN}/${PRIMARY}/group_a/${PRIMARY}chr1q.info" "${WORK}/${PRIMARY}/${PRIMARY}_chr1.info"

# QC log: info rows = 5 (header+4 SNPs), dose columns = 6 (FID->IID, MLDOSE, 4 dosages).
check "QC log has 22 chromosome lines" \
  test "$(grep -c "^Chromosome" "${WORK}/${PRIMARY}/${PRIMARY}_qc-checklength.log")" -eq 22
check "QC log reports chr1 info 5 rows and dose 6 columns" \
  grep -q "Chromosome '1' info has '5' rows and dose has '6' columns" \
    "${WORK}/${PRIMARY}/${PRIMARY}_qc-checklength.log"

# LQ filters (GNU awk): the info header is skipped because "Rsq" is not < 0.3.
lq03=$(grep -c . "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq03_snps.txt")
lq08=$(grep -c . "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq08_snps.txt")
lqall=$(grep -c . "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq_all_snps.txt")
check "lq03 list has 22 lines (one Rsq<0.3 SNP per chromosome)" test "${lq03}" -eq 22
check "lq08 list has 44 lines (two Rsq<0.8 SNPs per chromosome)" test "${lq08}" -eq 44
check "combined LQ list is lq03+lq08 (66 lines)" test "${lqall}" -eq 66
check "lq03 does not include the info header token SNP" \
  test "$(grep -cx "SNP" "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq03_snps.txt" || true)" -eq 0
check "lq03 contains a chr:pos SNP with Rsq 0.10" \
  grep -qx "1:300001" "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq03_snps.txt"
check "lq08 contains a chr:pos SNP with Rsq 0.55" \
  grep -qx "1:200001" "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq08_snps.txt"
check "high-Rsq chr:pos SNP is not in lq08" \
  test "$(grep -cx "1:100001" "${WORK}/${PRIMARY}/${PRIMARY}_all_chr_lq08_snps.txt" || true)" -eq 0

# pdat: 1 header + 22*4 SNP rows. pfam: 5 samples, dose2plink sex=1, pheno=-9.
pdat_n=$(wc -l < "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat")
pfam_n=$(wc -l < "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pfam")
check "allchr.pdat has 89 lines (header + 88 SNPs)" test "${pdat_n}" -eq 89
check "allchr.pfam has 5 samples" test "${pfam_n}" -eq 5
check "pdat starts with SNP A1 A2 header" \
  test "$(head -1 "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat" | cut -f1-3)" = $'SNP\tA1\tA2'
check "pdat contains chr:pos SNP 1:100001" \
  grep -q $'^1:100001\t' "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat"
check "pdat contains chr:pos:ref:alt SNP 1:400001:G:C" \
  grep -q $'^1:400001:G:C\t' "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat"
check "pdat contains no rs SNP IDs" \
  test "$(grep -c $'^rs' "${WORK}/${PRIMARY}/${PRIMARY}_allchr.pdat" || true)" -eq 0

# --- correct-plinkfiles.sh (single dataset) ---
log ""
log "=== correct-plinkfiles.sh ${PRIMARY} ==="
cp "${GEN}/${PRIMARY}/${PRIMARY}_pheno.tsv" "${WORK}/${PRIMARY}/"
cp "${GEN}/${PRIMARY}/${PRIMARY}_covar.tsv" "${WORK}/${PRIMARY}/"

set +e
"${CORRECT}" -d "${WORK}/${PRIMARY}" -n "${PRIMARY}" > "${WORK}/${PRIMARY}/correct.log" 2>&1
correct_rc=$?
set -e
check "correct-plinkfiles.sh exits 0 on ${PRIMARY} dummy data" test "${correct_rc}" -eq 0
if [[ "${correct_rc}" -ne 0 ]]; then
  log "----- correct.log (tail) -----"
  tail -n 80 "${WORK}/${PRIMARY}/correct.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "${PRIMARY}_plink1_temp1_updated.bed exists" test -f "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.bed"
check "${PRIMARY}_plink1_temp1_updated.bim exists" test -f "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.bim"
check "${PRIMARY}_plink1_temp1_updated.fam exists" test -f "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.fam"

if [[ -f "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.bim" ]]; then
  bim="${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.bim"
  bim_n=$(wc -l < "${bim}")
  # 88 SNPs minus 44 LQ (22 lq08-only + 22 lq03) = 44 kept (22 chr:pos + 22 chr:pos:ref:alt).
  check "updated bim has 44 variants (LQ SNPs excluded)" test "${bim_n}" -eq 44
  check "chr:pos correction set chr=1 pos=100001 for 1:100001" \
    grep -q $'^1\t1:100001\t0\t100001\t' "${bim}"
  check "chr:pos:ref:alt correction set chr=1 pos=400001 for 1:400001:G:C" \
    grep -q $'^1\t1:400001:G:C\t0\t400001\t' "${bim}"
  check "updated bim has numeric chr, colon ID, and numeric POS on every row" \
    bim_chr_pos_clean "${bim}"
  check "updated bim contains no rs IDs and no blank POS" \
    test "$(gawk 'BEGIN{FS="\t"; n=0} $2 ~ /^rs/ || $4 == "" { n++ } END{ print n }' "${bim}")" -eq 0
fi

if [[ -f "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.fam" ]]; then
  fam_n=$(wc -l < "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.fam")
  check "updated fam has 5 samples" test "${fam_n}" -eq 5
  check "phenotype case status reached the fam (ZYQLOT01 is case 2)" \
    grep -q $'^ZYQLOT01\tZYQLOT01\t0\t0\t1\t2$' "${WORK}/${PRIMARY}/${PRIMARY}_plink1_temp1_updated.fam"
fi

# --- combine-datasets-module.sh (NULDRA + JIVCAL) ---
log ""
log "=== convert-mac + combine-datasets-module.sh ${SECOND}/${THIRD} ==="
mkdir -p "${WORK}/${SECOND}" "${WORK}/${THIRD}" "${WORK}/${MERGED}"
set +e
"${CONVERT}" -c "${GEN}/${SECOND}/group_a" -n "${SECOND}" -o "${WORK}/${SECOND}" \
  > "${WORK}/${SECOND}/convert.log" 2>&1
second_rc=$?
"${CONVERT}" -c "${GEN}/${THIRD}/group_a" -n "${THIRD}" -o "${WORK}/${THIRD}" \
  > "${WORK}/${THIRD}/convert.log" 2>&1
third_rc=$?
set -e
check "convert-mac ${SECOND} exits 0" test "${second_rc}" -eq 0
check "convert-mac ${THIRD} exits 0" test "${third_rc}" -eq 0
cp "${GEN}/${SECOND}/${SECOND}_pheno.tsv" "${GEN}/${SECOND}/${SECOND}_covar.tsv" "${WORK}/${SECOND}/"
cp "${GEN}/${THIRD}/${THIRD}_pheno.tsv" "${GEN}/${THIRD}/${THIRD}_covar.tsv" "${WORK}/${THIRD}/"

set +e
"${COMBINE}" \
  -d "${WORK}/${SECOND}" \
  -d "${WORK}/${THIRD}" \
  -n "${MERGED}" \
  -o "${WORK}/${MERGED}" \
  > "${WORK}/${MERGED}/combine.log" 2>&1
combine_rc=$?
set -e
check "combine-datasets-module.sh exits 0" test "${combine_rc}" -eq 0
if [[ "${combine_rc}" -ne 0 ]]; then
  log "----- combine.log (tail) -----"
  tail -n 100 "${WORK}/${MERGED}/combine.log" | tee -a "${REPORT}"
  log "------------------------------"
fi

check "merged ${MERGED}_temp2_updated.bed exists" test -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.bed"
check "merged ${MERGED}_temp2_updated.bim exists" test -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.bim"
check "merged ${MERGED}_temp2_updated.fam exists" test -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.fam"

if [[ -f "${WORK}/${MERGED}/${MERGED}_sharedsnps.tsv" ]]; then
  shared_n=$(wc -l < "${WORK}/${MERGED}/${MERGED}_sharedsnps.tsv")
  # 22 chr x 2 shared SNPs (keep + lq08)
  check "shared SNP list has 44 rows" test "${shared_n}" -eq 44
fi

if [[ -f "${WORK}/${MERGED}/${MERGED}_lq_all_snps.txt" ]]; then
  # convert concatenates lq03+lq08, so Rsq<0.3 SNPs appear twice. combine then
  # uses sort | uniq -u, which DROPS any line that is not unique.
  uniq_u_n=$(wc -l < "${WORK}/${MERGED}/${MERGED}_lq_all_snps.txt")
  log "NOTE  combined LQ list (sort | uniq -u) has ${uniq_u_n} lines"
  notes+=("combine-datasets-module.sh builds ${MERGED}_lq_all_snps.txt with 'uniq -u' (unique lines only). Lines that appear more than once are dropped. The plink2 import actually excludes each dataset's own *_lq_all_snps.txt, so this combined list is unused.")
fi

if [[ -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.bim" ]]; then
  merge_bim="${WORK}/${MERGED}/${MERGED}_temp2_updated.bim"
  merge_n=$(wc -l < "${merge_bim}")
  log "NOTE  merged bim variant count: ${merge_n}"
  check "merged bim contains shared SNP 1:100000 with chr/pos filled" \
    grep -q $'^1\t1:100000\t0\t100000\t' "${merge_bim}"
  check "merged bim does not contain NULDRA-only SNP 1:410000" \
    test "$(grep -c $'\t1:410000\t' "${merge_bim}" || true)" -eq 0
  check "merged bim does not contain JIVCAL-only SNP 1:510000" \
    test "$(grep -c $'\t1:510000\t' "${merge_bim}" || true)" -eq 0
  check "merged bim has numeric chr, colon ID, and numeric POS on every row" \
    bim_chr_pos_clean "${merge_bim}"
fi

if [[ -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.fam" ]]; then
  merge_fam=$(wc -l < "${WORK}/${MERGED}/${MERGED}_temp2_updated.fam")
  check "merged fam has 5 samples (3 NULDRA + 2 JIVCAL)" test "${merge_fam}" -eq 5
fi

if [[ -f "${WORK}/${MERGED}/${MERGED}_temp2_updated.bed" ]]; then
  plink --bfile "${WORK}/${MERGED}/${MERGED}_temp2_updated" --missing --out "${WORK}/${MERGED}/merge-missing" --allow-no-sex \
    > "${WORK}/${MERGED}/missing.log" 2>&1 || true
  # Dummy dosages are 0/1/2, so hard-called merge should be complete.
  check "merged genotyping rate is 1 (hard calls from 0/1/2 dummy dosages)" \
    grep -Eq "genotyping rate is (exactly )?1" "${WORK}/${MERGED}/missing.log"
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
