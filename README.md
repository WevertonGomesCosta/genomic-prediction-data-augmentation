# Predição genômica com aumento de dados

Este repositório apresenta um tutorial didático em `workflowr` sobre predição
genômica com GBLUP, redução do tamanho da amostra real e aumento de dados
(*Data Augmentation*) via Mixup.

O objetivo é acompanhar o raciocínio analítico passo a passo: compreender os
dados, definir treinamento e validação, construir a matriz de relacionamento
genômico, avaliar o GBLUP com diferentes tamanhos de amostra e, por fim,
verificar se pseudoindivíduos podem reduzir a quantidade de indivíduos reais
necessários para manter o desempenho preditivo.

## Perguntas do estudo

O conjunto analítico possui 1.379 indivíduos genotipados. Em cada repetição, 276
indivíduos são separados para validação externa e os 1.103 restantes formam o
conjunto completo de treinamento, denominado `T100`.

O tutorial responde duas perguntas principais:

1. Qual é o menor número de indivíduos reais que produz desempenho praticamente
   equivalente a T100?
2. Ao completar uma amostra real reduzida com pseudoindivíduos Mixup, é possível
   utilizar menos indivíduos reais sem perder desempenho preditivo?

## Pipeline analítico

```text
Dados
  ↓
1. Auditoria dos dados
  ↓
2. Amostragem e conjuntos aninhados
  ↓
3. Matriz de relacionamento genômico G
  ↓
4. GBLUP com dados reais
  ↓
5. Equivalência com T100
  ↓
6. Aumento de dados com Mixup e comparação final
```

Cada módulo apresenta primeiro a pergunta científica e a motivação da etapa.
Depois, o código é mostrado em blocos curtos e comentados, seguido pela
interpretação dos resultados. A lógica metodológica permanece visível nos
próprios `.Rmd`, sem funções auxiliares que escondam as etapas principais.

## Desenho experimental

- 1.379 indivíduos genotipados;
- 4.325 SNPs;
- 276 indivíduos de validação por repetição;
- 30 repetições de validação externa aleatória;
- conjuntos reais aninhados em cada repetição:
  - T25 = 275 indivíduos;
  - T50 = 551 indivíduos;
  - T75 = 827 indivíduos;
  - T100 = 1.103 indivíduos;
- matriz genômica global `G` calculada com os 1.379 indivíduos genotipados;
- GBLUP ajustado com `BGLR`, componente `RKHS` e `K = G`;
- 10.000 iterações MCMC e período de *burn-in* de 5.000;
- correlação preditiva como métrica principal;
- RMSE, MAE e inclinação de calibração como métricas complementares;
- margem de equivalência `delta = 0.05`, definida como uma margem prática
  específica deste estudo;
- TOST com correção de Nadeau-Bengio para as repetições de validação externa.

## Aumento de dados com Mixup

Os indivíduos reais e os pares de doadores são selecionados aleatoriamente,
sem ranking fenotípico.

Cada amostra reduzida recebe exatamente o número de pseudoindivíduos necessário
para completar o tamanho de T100:

| Cenário | Reais | Sintéticos | Total |
|---|---:|---:|---:|
| T25 + DA | 275 | 828 | 1.103 |
| T50 + DA | 551 | 552 | 1.103 |
| T75 + DA | 827 | 276 | 1.103 |

O peso de cada doador é controlado por `lambda`. Foram avaliadas quatro regras:

- `lambda = 0.5`;
- `lambda ~ Beta(0.1, 0.1)`;
- `lambda ~ Beta(0.2, 0.2)`;
- `lambda ~ Beta(0.4, 0.4)`.

As distribuições Beta são simétricas e possuem média 0,5. Como os três valores
de `alpha` são menores que 1, as distribuições favorecem pesos próximos de 0 e
1 em diferentes intensidades, permitindo avaliar pseudoindivíduos mais ou menos
próximos de um dos doadores.

## Resultado principal

Sem aumento de dados, T75 foi a menor amostra real equivalente a T100:

```text
827 indivíduos reais ≈ 1.103 indivíduos reais
```

Nenhuma configuração de Mixup tornou T25 ou T50 equivalente a T100. Portanto,
para as estratégias avaliadas, o aumento de dados não reduziu o número mínimo
de indivíduos reais necessário.

## Módulos do tutorial

```text
analysis/01_data_audit.Rmd
analysis/02_sampling_splits.Rmd
analysis/03_genomic_matrix.Rmd
analysis/04_gblup_baseline.Rmd
analysis/05_equivalence.Rmd
analysis/06_data_augmentation.Rmd
```

Os objetos intermediários usados entre etapas são armazenados em `output/`. As
tabelas primárias de desempenho estão em `results/`, enquanto resumos,
diferenças pareadas, figuras e testes de equivalência são calculados diretamente
nos módulos correspondentes.

## Pacotes utilizados

Os principais pacotes empregados no tutorial são:

- `workflowr` — organização e apresentação do tutorial;
- `BGLR` — ajuste do modelo genômico;
- `ggplot2` — construção das figuras;
- `ggthemes` — identidade visual baseada no tema GDocs.

## Dados

O arquivo analítico esperado pelos módulos é:

```text
data/dados_gblup.csv
```

A estrutura esperada do arquivo e a situação atual da documentação de origem e
redistribuição estão descritas em `data/README.md`.