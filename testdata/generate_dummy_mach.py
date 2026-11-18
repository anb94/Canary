#!/usr/bin/env python3
"""Write a tiny synthetic MaCH/minimac dosage dataset for Canary smoke tests.

File names follow convert-mac-module.sh: PREFIX + chrN + a letter + .dose.cK / .info.
Each .dose line is FID->IID MLDOSE <one dosage per SNP>.
Each .info file is a MaCH mlinfo header (SNP Al1 Al2 Freq1 MAF Quality Rsq)
plus one row per SNP. Rsq is column 7.

SHARE has two consent groups so concatenation is exercised. GARNET and WHIMS
are smaller second datasets that share some SNPs and differ on others, for
combine-datasets-module.sh.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path

CHROMS = range(1, 23)

# (snp_id_template, al1, al2, rsq, role)
# snp_id_template may contain {chrom}.
SHARE_SNPS = (
    ("{chrom}:{pos_keep}", "A", "G", 0.95, "keep_chrpos"),
    ("{chrom}:{pos_lq08}", "C", "T", 0.55, "lq08"),
    ("{chrom}:{pos_lq03}", "A", "T", 0.10, "lq03"),
    ("rs{chrom:02d}001", "G", "C", 0.99, "keep_rs"),
)

# Shared high-quality and shared low-quality SNPs use the same ID and alleles
# in GARNET and WHIMS. Unique SNPs differ.
GARNET_SNPS = (
    ("{chrom}:100000", "A", "G", 0.95, "shared_keep"),
    ("{chrom}:200000", "C", "T", 0.50, "shared_lq08"),
    ("{chrom}:410000", "A", "C", 0.93, "garnet_only_keep"),
    ("rs{chrom}G", "G", "T", 0.20, "garnet_only_lq03"),
)

WHIMS_SNPS = (
    ("{chrom}:100000", "A", "G", 0.96, "shared_keep"),
    ("{chrom}:200000", "C", "T", 0.52, "shared_lq08"),
    ("{chrom}:510000", "T", "A", 0.91, "whims_only_keep"),
    ("rs{chrom}W", "A", "G", 0.99, "whims_only_keep"),
)

SHARE_C1 = ("SHARE01", "SHARE02", "SHARE03")
SHARE_C2 = ("SHARE04", "SHARE05")
GARNET_SAMPLES = ("GARNET01", "GARNET02", "GARNET03")
WHIMS_SAMPLES = ("WHIMS01", "WHIMS02")


def _snp_id(template: str, chrom: int) -> str:
    return template.format(
        chrom=chrom,
        pos_keep=100000 + chrom,
        pos_lq08=200000 + chrom,
        pos_lq03=300000 + chrom,
    )


# Near 0/1/2 so PLINK 1 hard-calling during combine-datasets-module.sh
# does not turn most dummy dosages into missing genotypes.
_HARD_CALLS = ("0.00", "1.00", "2.00")


def _dosage(sample_idx: int, snp_idx: int, chrom: int) -> str:
    return _HARD_CALLS[(sample_idx + snp_idx + chrom) % 3]


def _write_info(path: Path, chrom: int, snps: tuple) -> None:
    lines = ["SNP\tAl1\tAl2\tFreq1\tMAF\tQuality\tRsq\n"]
    for template, al1, al2, rsq, _role in snps:
        sid = _snp_id(template, chrom)
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
    ancestry: str,
    consent_groups: list[tuple[str, tuple[str, ...]]],
    snps: tuple,
) -> None:
    ds_dir = root / prefix
    all_samples: list[str] = []
    for consent_idx, (consent_name, samples) in enumerate(consent_groups, start=1):
        cdir = ds_dir / consent_name
        cdir.mkdir(parents=True, exist_ok=True)
        all_samples.extend(samples)
        for chrom in CHROMS:
            stem = f"{prefix}chr{chrom}{ancestry}"
            _write_dose(cdir / f"{stem}.dose.c{consent_idx}", chrom, samples, snps)
            _write_info(cdir / f"{stem}.info", chrom, snps)
    _write_pheno_covar(ds_dir, prefix, tuple(all_samples))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-o",
        "--out",
        type=Path,
        default=Path(__file__).resolve().parent / "dummy-mach",
        help="Directory that will contain SHARE, GARNET, and WHIMS input folders.",
    )
    args = parser.parse_args()
    out = args.out
    if out.exists():
        # Keep the tree replaceable; do not delete unrelated files.
        pass
    os.makedirs(out, exist_ok=True)

    _write_dataset(
        out,
        "SHARE",
        "aa",
        [("consentgroup1", SHARE_C1), ("consentgroup2", SHARE_C2)],
        SHARE_SNPS,
    )
    _write_dataset(
        out,
        "GARNET",
        "aa",
        [("consentgroup1", GARNET_SAMPLES)],
        GARNET_SNPS,
    )
    _write_dataset(
        out,
        "WHIMS",
        "aa",
        [("consentgroup1", WHIMS_SAMPLES)],
        WHIMS_SNPS,
    )

    manifest = out / "MANIFEST.txt"
    manifest.write_text(
        "\n".join(
            [
                "Canary dummy MaCH/minimac dosage data",
                "",
                "SHARE: 2 consent groups, 5 samples (SHARE01–SHARE03 in c1, SHARE04–SHARE05 in c2),",
                "       22 chromosomes, 4 SNPs/chr (1 keep chr:pos, 1 Rsq 0.55, 1 Rsq 0.10, 1 keep rsID).",
                "GARNET: 1 consent group, 3 samples, 22 chr, 4 SNPs/chr (2 shared with WHIMS, 2 unique).",
                "WHIMS:  1 consent group, 2 samples, 22 chr, 4 SNPs/chr (2 shared with GARNET, 2 unique).",
                "",
                "Names match convert-mac-module.sh (letter immediately after the chromosome number).",
                f"Written under: {out}",
                "",
            ]
        )
    )
    print(f"Wrote dummy MaCH files under {out}")


if __name__ == "__main__":
    main()
