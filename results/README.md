# Resultados primários

Esta pasta contém as tabelas primárias de desempenho utilizadas nos módulos de
predição genômica e aumento de dados.

## Arquivos

- `04_baseline_results.csv` — 120 resultados do GBLUP com somente indivíduos
  reais: 30 repetições × T25, T50, T75 e T100;
- `06_da_results.csv` — 360 resultados do GBLUP com aumento de dados: 30
  repetições × três tamanhos reais × quatro regras de Mixup.

## Organização das análises

Esses dois arquivos concentram as medidas obtidas para cada combinação do
desenho experimental. A partir deles, os módulos calculam diretamente:

- médias e desvios-padrão;
- diferenças pareadas entre tamanhos de treinamento;
- comparação entre aumento de dados e o mesmo conjunto real;
- diferenças em relação a T100;
- intervalos de confiança e testes TOST com correção de Nadeau-Bengio.

Dessa forma, os arquivos em `results/` representam os resultados elementares de
cada cenário, enquanto as estatísticas derivadas permanecem explícitas no código
dos módulos correspondentes.