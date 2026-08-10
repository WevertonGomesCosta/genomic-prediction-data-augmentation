# Genomic Prediction with Data Augmentation

Reproducible `workflowr` project for evaluating whether a reduced random sample
of phenotyped individuals can retain genomic predictive ability, and whether
mixup-based Data Augmentation can replace part of the real training population.

## Main question

What is the minimum number of real individuals required to achieve predictive
performance equivalent to the full training pool (`T100`)?

A second question evaluates whether:

```text
reduced real sample + synthetic individuals
```

can be equivalent to:

```text
T100 = 1,103 real individuals
```

## Experimental contract

- 1,379 genotyped individuals;
- 4,325 SNPs;
- 276 external validation individuals per repetition;
- T100 = 1,103 training-pool individuals;
- 30 repeated random holdouts;
- nested real training sets:
  - T25 = 275;
  - T50 = 551;
  - T75 = 827;
  - T100 = 1,103;
- one global genomic relationship matrix `G`;
- GBLUP via `BGLR`, `RKHS`, `K = G`;
- `nIter = 10000`, `burnIn = 5000`;
- predictive correlation as the primary metric;
- RMSE, MAE, and calibration slope as complementary metrics;
- equivalence margin `delta = 0.05`;
- Nadeau-Bengio corrected repeated-holdout TOST.

## Data Augmentation contract

No phenotype ranking is used to choose real individuals or donors.

Synthetic individuals are generated from random distinct donor pairs within
the real training sample. Each reduced sample is augmented until the training
set reaches exactly T100:

| Scenario | Real | Synthetic | Total |
|---|---:|---:|---:|
| T25 + DA | 275 | 828 | 1,103 |
| T50 + DA | 551 | 552 | 1,103 |
| T75 + DA | 827 | 276 | 1,103 |

The evaluated mixup rules are:

- fixed `lambda = 0.5`;
- `lambda ~ Beta(0.1, 0.1)`;
- `lambda ~ Beta(0.2, 0.2)`;
- `lambda ~ Beta(0.4, 0.4)`.

## Workflow

1. `analysis/01_data_audit.Rmd`
2. `analysis/02_sampling_splits.Rmd`
3. `analysis/03_genomic_matrix_diagnostics.Rmd`
4. `analysis/04_gblup_baseline.Rmd`
5. `analysis/05_equivalence.Rmd`
6. `analysis/06_data_augmentation.Rmd`

## Modular execution and persistence

Approved lightweight results are versioned in `results/`, including the 120
real-only baseline fits and the equivalence analyses. Therefore these models do
not need to be refitted in a normal clone of the repository.

The large intermediate objects are local and are stored in `output/`, which is
ignored by Git. The Data Augmentation module is self-bootstrapping: before the
360 DA fits it checks whether the following objects exist:

- `output/01_data_objects.rds`;
- `output/02_splits_mestre_30rep.rds`;
- `output/03_genomic_objects.rds`.

If any of them is absent, it rebuilds only these lightweight prerequisites from
`data/dados_gblup.csv`. It does not rerun the 120-fit baseline or the genomic
relationship diagnostic page.

The heavy Data Augmentation module writes a checkpoint after each completed
fit. If execution is interrupted, rerunning the same `.Rmd` continues from the
remaining fits.

## Setup

Install the required packages:

```r
install.packages("workflowr")
install.packages("BGLR")
```

Optionally initialize `renv` after cloning:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

Place the analytical dataset at:

```text
data/dados_gblup.csv
```

## Continue directly with Data Augmentation

After the dataset is present, the definitive DA stage can be executed directly:

```r
workflowr::wflow_build(
  "analysis/06_data_augmentation.Rmd"
)
```

On the first run in a new clone, the three lightweight prerequisite objects are
created automatically. On later runs they are loaded from `output/`.

Build another individual stage with the same pattern, for example:

```r
workflowr::wflow_build("analysis/05_equivalence.Rmd")
```

Build the full site after the necessary stage artifacts exist:

```r
workflowr::wflow_build()
```

## Source data

See `data/README.md`.
