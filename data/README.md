# Dados do tutorial

O arquivo analítico utilizado pelos módulos é identificado como:

```text
data/dados_gblup.csv
```

## Estrutura esperada

O conjunto analítico utilizado neste estudo contém:

- 1.379 indivíduos;
- uma coluna fenotípica chamada `yield`;
- 4.325 colunas de SNPs;
- SNPs codificados como `0`, `1` ou `2`;
- nenhum valor ausente nos SNPs;
- nenhum marcador monomórfico na matriz analítica final.

A primeira etapa do tutorial descreve essas características diretamente a
partir do arquivo e mostra como o fenótipo e a matriz de marcadores são
organizados para as análises seguintes.

## Origem e preparação dos dados

A fonte original do conjunto, o procedimento completo de preparação e a
sequência de filtros que resultaram nos 1.379 indivíduos e 4.325 SNPs ainda
devem ser documentados de forma verificável antes da versão final do projeto.
Por esse motivo, esta página não atribui uma origem específica ao arquivo sem a
respectiva referência e descrição metodológica.

## Redistribuição

O arquivo analítico não é versionado no repositório enquanto a origem, o
procedimento de preparação e os termos de redistribuição não estiverem
formalmente documentados. Por isso, `data/dados_gblup.csv` permanece listado no
`.gitignore`.

Essa separação permite manter no repositório o pipeline analítico e os
resultados do estudo sem publicar um conjunto de dados cuja condição de
redistribuição ainda precisa ser confirmada.