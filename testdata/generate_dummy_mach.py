#!/usr/bin/env python3
"""Write a tiny synthetic MaCH/minimac dosage dataset for Canary smoke tests.

Cohort prefixes are coined toy names, not real studies. File names follow
convert-mac-module.sh: PREFIX + chrN + a letter + .dose.* / .info.
Each .dose line is FID->IID MLDOSE <one dosage per SNP>.
Each .info file is a MaCH mlinfo header (SNP Al1 Al2 Freq1 MAF Quality Rsq)
plus one row per SNP. Rsq is column 7.

Every SNP ID is colon-delimited chr:pos or chr:pos:ref:alt so
correct-plinkfiles.sh can fill numeric chromosome and position. There are
no rs IDs.

ZYQLOT has two input groups so concatenation is exercised. NULDRA and JIVCAL
are smaller second datasets that share some SNPs and differ on others, for
combine-datasets-module.sh.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
from pathlib import Path

CHROMS = range(1, 23)

# Dummy letter immediately after the chromosome number (convert-mac-module.sh
# requires [a-z] there so chr1 does not also match chr10–chr19). This is not
# an ancestry or study code.
PANEL_TAG = "q"

# Coined toy prefixes. These are invented strings, not the name or acronym of
# a real cohort, biobank, or dbGaP study.
PRIMARY = "ZYQLOT"
SECOND = "NULDRA"
THIRD = "JIVCAL"

# (snp_id_template, al1, al2, rsq, role)
# Templates may contain {chrom}, {pos_*}, {al1}, {al2}.
PRIMARY_SNPS = (
    ("{chrom}:{pos_keep}", "A", "G", 0.95, "keep_chrpos"),
    ("{chrom}:{pos_lq08}", "C", "T", 0.55, "lq08"),
    ("{chrom}:{pos_lq03}", "A", "T", 0.10, "lq03"),
    ("{chrom}:{pos_keep2}:{al1}:{al2}", "G", "C", 0.99, "keep_chrpos_alleles"),
)

SECOND_SNPS = (
    ("{chrom}:100000", "A", "G", 0.95, "shared_keep"),
    ("{chrom}:200000", "C", "T", 0.50, "shared_lq08"),
    ("{chrom}:410000", "A", "C", 0.93, "second_only_keep"),
    ("{chrom}:610000", "G", "T", 0.20, "second_only_lq03"),
)

THIRD_SNPS = (
    ("{chrom}:100000", "A", "G", 0.96, "shared_keep"),
    ("{chrom}:200000", "C", "T", 0.52, "shared_lq08"),
    ("{chrom}:510000", "T", "A", 0.91, "third_only_keep"),
    ("{chrom}:710000", "A", "G", 0.99, "third_only_keep"),
)

PRIMARY_G1 = ("ZYQLOT01", "ZYQLOT02", "ZYQLOT03")
PRIMARY_G2 = ("ZYQLOT04", "ZYQLOT05")
SECOND_SAMPLES = ("NULDRA01", "NULDRA02", "NULDRA03")
THIRD_SAMPLES = ("JIVCAL01", "JIVCAL02")

SNP_ID_RE = re.compile(r"^[0-9]+:[0-9]+(?::[ACGT]:[ACGT])?$")
FORBIDDEN_NAME_RE = re.compile(
    r"(\bSHARE\b|\bWHIMS\b|\bGARNET\b|\bWHI\b|dbGaP|phs[0-9]|Framingham|"
    r"UK[ _-]?Biobank|1000[ _-]?Genomes|\bGTEx\b|\bTOPMed\b|\bMESA\b|\bARIC\b)",
    re.IGNORECASE,
)


def _snp_id(template: str, chrom: int, al1: str = "", al2: str = "") -> str:
    sid = template.format(
        chrom=chrom,
        pos_keep=100000 + chrom,
        pos_lq08=200000 + chrom,
        pos_lq03=300000 + chrom,
        pos_keep2=400000 + chrom,
        al1=al1,
        al2=al2,
    )
    if not SNP_ID_RE.match(sid):
        raise ValueError(f"toy SNP ID is not chr:pos or chr:pos:ref:alt: {sid!r}")
    return sid


# Near 0/1/2 so PLINK 1 hard-calling during combine-datasets-module.sh
# does not turn most dummy dosages into missing genotypes.
_HARD_CALLS = ("0.00", "1.00", "2.00")


def _dosage(sample_idx: int, snp_idx: int, chrom: int) -> str:
    return _HARD_CALLS[(sample_idx + snp_idx + chrom) % 3]


def _write_info(path: Path, chrom: int, snps: tuple) -> None:
    lines = ["SNP\tAl1\tAl2\tFreq1\tMAF\tQuality\tRsq\n"]
    for template, al1, al2, rsq, _role in snps:
        sid = _snp_id(template, chrom, al1, al2)
        freq = 0.25
        maf = 0.25
        quality = max(rsq, 0.5)
        lines.append(f"{sid}\t{al1}\t{al2}\t{freq:.2f}\t{maf:.2f}\t{quality:.2f}\t{rsq:.2f}\n")
    path.write_text("".join(lines))


def _write_dose(path: Path, chrom: int, samples: tuple[str, ...], snps: tuple) -> None:
    lines = []
    for s_idx, sample in enumerate(samples):
        dosages = [_dosage(s_idx, snp_idx, chrom) for snp_idx in range(len(snps))]
        # MaCH mldose: first token is FID->IID, second is MLDOSE, then dosages.
        lines.append(f"{sample}->{sample} MLDOSE " + " ".join(dosages) + "\n")
    path.write_text("".join(lines))


def _write_pheno_covar(out_dir: Path, prefix: str, samples: tuple[str, ...]) -> None:
    pheno = ["FID\tIID\tcase\n"]
    covar = ["FID\tIID\tPC1\tPC2\tPC3\tAGE\trace\n"]
    for i, sample in enumerate(samples):
        # PLINK: 1 = control, 2 = case. First sample is a case.
        case = 2 if i == 0 else 1
        pheno.append(f"{sample}\t{sample}\t{case}\n")
        covar.append(
            f"{sample}\t{sample}\t{0.01 * (i + 1):.2f}\t{0.02 * (i + 1):.2f}\t"
            f"{0.03 * (i + 1):.2f}\t{50 + i}\t1\n"
        )
    out_dir.joinpath(f"{prefix}_pheno.tsv").write_text("".join(pheno))
    out_dir.joinpath(f"{prefix}_covar.tsv").write_text("".join(covar))


def _write_dataset(
    root: Path,
    prefix: str,
    groups: list[tuple[str, tuple[str, ...]]],
    snps: tuple,
) -> None:
    ds_dir = root / prefix
    all_samples: list[str] = []
    for group_idx, (group_name, samples) in enumerate(groups):
        gdir = ds_dir / group_name
        gdir.mkdir(parents=True, exist_ok=True)
        all_samples.extend(samples)
        batch = "ab"[group_idx]
        for chrom in CHROMS:
            stem = f"{prefix}chr{chrom}{PANEL_TAG}"
            _write_dose(gdir / f"{stem}.dose.{batch}", chrom, samples, snps)
            _write_info(gdir / f"{stem}.info", chrom, snps)
    _write_pheno_covar(ds_dir, prefix, tuple(all_samples))


def _assert_no_forbidden_names(root: Path) -> None:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        rel = str(path.relative_to(root))
        if FORBIDDEN_NAME_RE.search(rel):
            raise ValueError(f"forbidden study-like name in generated path: {rel}")
        text = path.read_text(errors="replace")
        if FORBIDDEN_NAME_RE.search(text):
            raise ValueError(f"forbidden study-like name in generated file: {rel}")
        if path.suffix == ".info":
            for line in text.splitlines()[1:]:
                sid = line.split("\t", 1)[0]
                if not SNP_ID_RE.match(sid):
                    raise ValueError(f"non chr:pos SNP ID in {rel}: {sid!r}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-o",
        "--out",
        type=Path,
        default=Path(__file__).resolve().parent / "dummy-mach",
        help="Directory that will contain ZYQLOT, NULDRA, and JIVCAL input folders.",
    )
    args = parser.parse_args()
    out = args.out
    os.makedirs(out, exist_ok=True)

    # Replace the current toy trees. Also delete leftover folders from an
    # earlier dummy that used real study names as prefixes.
    for name in (
        PRIMARY,
        SECOND,
        THIRD,
        "SHARE",
        "GARNET",
        "WHIMS",
        "WHI",
    ):
        shutil.rmtree(out / name, ignore_errors=True)
    (out / "MANIFEST.txt").unlink(missing_ok=True)

    _write_dataset(
        out,
        PRIMARY,
        [("group_a", PRIMARY_G1), ("group_b", PRIMARY_G2)],
        PRIMARY_SNPS,
    )
    _write_dataset(
        out,
        SECOND,
        [("group_a", SECOND_SAMPLES)],
        SECOND_SNPS,
    )
    _write_dataset(
        out,
        THIRD,
        [("group_a", THIRD_SAMPLES)],
        THIRD_SNPS,
    )

    manifest = out / "MANIFEST.txt"
    manifest.write_text(
        "\n".join(
            [
                "Canary toy MaCH/minimac dosage data (coined prefixes, not real studies).",
                "",
                "ZYQLOT: 2 groups, 5 samples (ZYQLOT01–03 in group_a, ZYQLOT04–05 in group_b),",
                "        22 chromosomes, 4 SNPs/chr (2 keep chr:pos, 1 Rsq 0.55, 1 Rsq 0.10).",
                "        One keep SNP is chr:pos:ref:alt; none are rs IDs.",
                "NULDRA: 1 group, 3 samples, 22 chr, 4 SNPs/chr (2 shared with JIVCAL, 2 unique).",
                "JIVCAL: 1 group, 2 samples, 22 chr, 4 SNPs/chr (2 shared with NULDRA, 2 unique).",
                "",
                "Names match convert-mac-module.sh (letter immediately after the chromosome number).",
                f"Written under: {out}",
                "",
            ]
        )
    )
    _assert_no_forbidden_names(out)
    print(f"Wrote dummy MaCH files under {out}")


if __name__ == "__main__":
    main()
