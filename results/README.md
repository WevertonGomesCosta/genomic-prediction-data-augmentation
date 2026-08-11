# Resultados versionados

Esta pasta contém apenas resultados leves necessários para reconstruir o
tutorial sem repetir os ajustes computacionalmente caros.

## Arquivos mantidos

- `04_baseline_results.csv` — 120 ajustes GBLUP usando somente indivíduos reais;
- `06_da_summary.csv` — resumo auditado dos 360 ajustes de Data Augmentation,
  incluindo desempenho médio, comparação com o mesmo tamanho real e
  equivalência com T100;
- `06_da_checkpoint_sha256.txt` — hash SHA-256 do checkpoint completo de 360
  ajustes usado para produzir o resumo final.

## Por que não guardar várias tabelas derivadas?

Tabelas como médias do baseline, diferenças contra T100 e resultados do TOST
são calculadas diretamente nos respectivos `.Rmd`. Isso evita manter múltiplos
CSVs que representam apenas transformações do mesmo resultado primário.

O checkpoint completo do Data Augmentation é produzido localmente durante a
execução e pode ser regenerado pelo código tutorial. Seu hash é versionado para
preservar a rastreabilidade do arquivo que foi auditado antes da refatoração.

## Reprodução pesada

Os módulos 4 e 6 mostram o código completo dos ajustes, mas usam
`RUN_MODELS <- FALSE` por padrão para que o site possa ser reconstruído sem
refazer 480 modelos BGLR.

Ao reproduzir os modelos do zero, os checkpoints locais são gravados em
`output/checkpoints/` e permanecem fora do Git.
