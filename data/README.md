# Data

Place the analytical dataset at:

```text
data/dados_gblup.csv
```

Expected structure:

- 1,379 rows;
- one phenotype column named `yield`;
- 4,325 SNP columns;
- SNP values coded as 0, 1, or 2;
- no missing SNP values in the validated analytical file.

The original SoyNAM resource used a 5K SNP panel, but the analytical file used
in this project contains 4,325 SNP columns.

Before making the repository public, confirm whether the data file itself may
be redistributed under the terms of the original source. If redistribution is
not allowed, keep the CSV local and document the source/download procedure here.
