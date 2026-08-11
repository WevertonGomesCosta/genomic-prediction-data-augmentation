# Resultados versionados

Esta pasta contém apenas os resultados primários necessários para reconstruir
o tutorial sem repetir os ajustes computacionalmente caros.

## Arquivos mantidos

- `04_baseline_results.csv` — resultados dos 120 ajustes GBLUP usando somente indivíduos reais;
- `06_da_results.csv` — resultados completos dos 360 ajustes de Data Augmentation.

## Regra do tutorial

Os arquivos acima são as fontes canônicas dos resultados. Tabelas derivadas,
como médias, desvios-padrão, diferenças contra T100, comparações DA versus real
e resultados do TOST, são calculadas diretamente nos respectivos `.Rmd`.

Isso evita manter múltiplos CSVs que representam apenas transformações dos
mesmos resultados primários e permite que o leitor acompanhe no próprio
tutorial como cada conclusão é obtida.

## Reprodução pesada

Os módulos 4 e 6 mostram o código completo dos ajustes, mas usam
`RUN_MODELS <- FALSE` por padrão para que o site possa ser reconstruído sem
refazer 480 modelos BGLR.

Ao reproduzir os modelos do zero, os checkpoints locais são gravados em
`output/checkpoints/`. Depois da execução completa, os resultados finais são
gravados nos respectivos arquivos de `results/`.
