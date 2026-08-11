# Genomic Prediction with Data Augmentation

Este repositório é um tutorial reproduzível em `workflowr` para mostrar, passo a passo, como avaliar se uma amostra menor de indivíduos reais pode manter a capacidade preditiva do conjunto completo de treinamento e se Data Augmentation via Mixup consegue reduzir ainda mais a quantidade de indivíduos que precisam ser fenotipados.

## Pergunta principal

O conjunto possui 1.379 indivíduos genotipados. Em cada repetição, 276 indivíduos são separados para validação externa e os 1.103 restantes formam o conjunto completo de treinamento, chamado `T100`.

O tutorial responde duas perguntas:

1. Qual é o menor número de indivíduos reais que produz desempenho equivalente a T100?
2. Ao completar uma amostra real reduzida com pseudoindivíduos Mixup, conseguimos usar menos indivíduos reais sem perder desempenho preditivo?

## Fluxo do tutorial

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
6. Data Augmentation e comparação final
```

Cada módulo explica primeiro **o que será feito**, **por que a etapa é necessária** e **como o resultado se conecta à etapa seguinte**. O código metodologicamente relevante fica visível no próprio `.Rmd`; não são usados arquivos de funções auxiliares para esconder a lógica da análise.

## Desenho experimental

- 1.379 indivíduos genotipados;
- 4.325 SNPs;
- 276 indivíduos de validação por repetição;
- 30 repetições de holdout aleatório;
- conjuntos reais aninhados dentro de cada repetição:
  - T25 = 275 indivíduos;
  - T50 = 551 indivíduos;
  - T75 = 827 indivíduos;
  - T100 = 1.103 indivíduos;
- uma matriz genômica global `G` calculada com todos os indivíduos genotipados;
- GBLUP ajustado com `BGLR`, componente `RKHS` e `K = G`;
- 10.000 iterações MCMC e burn-in de 5.000;
- correlação preditiva como métrica principal;
- RMSE, MAE e slope de calibração como métricas complementares;
- margem de equivalência `delta = 0.05`;
- TOST com correção de Nadeau-Bengio para os holdouts repetidos.

## Data Augmentation

Os indivíduos reais e os doadores do Mixup são escolhidos aleatoriamente, sem ranking fenotípico.

Cada amostra reduzida recebe exatamente o número de pseudoindivíduos necessário para completar o tamanho de T100:

| Cenário | Reais | Sintéticos | Total |
|---|---:|---:|---:|
| T25 + DA | 275 | 828 | 1.103 |
| T50 + DA | 551 | 552 | 1.103 |
| T75 + DA | 827 | 276 | 1.103 |

As regras de mistura avaliadas são:

- `lambda = 0.5`;
- `lambda ~ Beta(0.1, 0.1)`;
- `lambda ~ Beta(0.2, 0.2)`;
- `lambda ~ Beta(0.4, 0.4)`.

## Resultado principal

Sem Data Augmentation, T75 foi a menor amostra real equivalente a T100:

```text
827 indivíduos reais ≈ 1.103 indivíduos reais
```

Nenhuma configuração de Mixup fez T25 ou T50 atingir equivalência com T100. Portanto, para as estratégias avaliadas, o Data Augmentation não reduziu o número mínimo de indivíduos reais necessário.

## Arquivos principais

```text
analysis/01_data_audit.Rmd
analysis/02_sampling_splits.Rmd
analysis/03_genomic_matrix.Rmd
analysis/04_gblup_baseline.Rmd
analysis/05_equivalence.Rmd
analysis/06_data_augmentation.Rmd
```

Os objetos intermediários leves são salvos localmente em `output/` e reutilizados pela etapa seguinte. Os resultados primários dos 120 ajustes do baseline e dos 360 ajustes de Data Augmentation são versionados em `results/`. Todas as tabelas derivadas e os testes de equivalência são reconstruídos diretamente nos `.Rmd`, permitindo acompanhar como cada conclusão é obtida sem repetir a modelagem pesada.

## Como reproduzir

Instale os pacotes necessários:

```r
install.packages("workflowr")
install.packages("BGLR")
```

Coloque o arquivo analítico em:

```text
data/dados_gblup.csv
```

Na configuração padrão, os módulos de modelagem usam os resultados pesados já auditados (`RUN_MODELS <- FALSE`). Assim, o site completo pode ser construído diretamente com:

```r
workflowr::wflow_build()
```

Esse comando constrói as páginas do tutorial que ainda estiverem desatualizadas, incluindo `analysis/index.Rmd`, e salva os HTML em `docs/`.

Se quiser reconstruir apenas os seis módulos analíticos sem abrir automaticamente a página inicial ao final, use:

```r
workflowr::wflow_build(
  c(
    "analysis/01_data_audit.Rmd",
    "analysis/02_sampling_splits.Rmd",
    "analysis/03_genomic_matrix.Rmd",
    "analysis/04_gblup_baseline.Rmd",
    "analysis/05_equivalence.Rmd",
    "analysis/06_data_augmentation.Rmd"
  ),
  view = FALSE
)
```

Nos módulos 4 e 6, o código completo dos ajustes permanece visível para fins didáticos, mas a execução pesada fica desativada por padrão. Para reproduzir os modelos do zero, altere `RUN_MODELS <- FALSE` para `TRUE` no módulo correspondente.

## Dados

O arquivo analítico não é versionado no repositório até que os termos de redistribuição da fonte original sejam confirmados. Consulte `data/README.md`.
