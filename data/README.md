# Dados do tutorial

O arquivo analítico utilizado pelos módulos é identificado como:

```text
data/dados_gblup.csv
```

## Origem dos dados

O conjunto analítico deriva do **SoyNAM (Soybean Nested Association Mapping)**.
A conferência de proveniência realizada para este projeto utilizou os arquivos
públicos `X.csv` e `Y.csv` disponibilizados por Sagae et al. no conjunto de
dados associado ao estudo sobre kernels ambientais em predição genômica:

- Dryad: [doi:10.5061/dryad.2fqz6133v](https://doi.org/10.5061/dryad.2fqz6133v)
- repositório de origem: [vsagae/impact-ec](https://github.com/vsagae/impact-ec)

O vetor `yield` de `dados_gblup.csv` corresponde exatamente, na mesma ordem,
aos 1.379 registros de produtividade do ambiente `IA_2012` em `Y.csv`. Nessa
fonte, `yield` representa produtividade de grãos em **kg/ha**.

Os 4.325 SNPs do arquivo analítico também estão presentes em `X.csv`. A
comparação das chamadas genotípicas originalmente observadas confirmou que os
mesmos genótipos estão representados nos 4.325 loci; parte dos marcadores usa a
orientação oposta do alelo contado, o que corresponde à transformação
`0 <-> 2` e não altera a informação genética do locus.

## Estrutura do arquivo analítico

O conjunto utilizado neste tutorial contém:

- 1.379 indivíduos de `IA_2012`;
- uma coluna fenotípica chamada `yield`, em kg/ha;
- 4.325 colunas de SNPs;
- SNPs codificados como `0`, `1` ou `2`;
- nenhum valor ausente nos SNPs;
- nenhum marcador monomórfico na matriz analítica final.

A primeira etapa do tutorial descreve essas características diretamente a
partir do arquivo e mostra como o fenótipo e a matriz de marcadores são
organizados para as análises seguintes.

## Preparação anterior ao tutorial

`dados_gblup.csv` é tratado como o **arquivo analítico final de entrada**. O
tutorial não refaz o controle de qualidade ou a imputação que antecederam sua
obtenção.

A auditoria de proveniência confirmou a correspondência do fenótipo, dos
indivíduos e dos 4.325 loci com os dados SoyNAM de referência. Entretanto, a
sequência histórica exata de filtros que reduziu o conjunto genotípico de
referência aos 4.325 SNPs e o algoritmo utilizado para preencher as chamadas
genotípicas ausentes **não foram reconstruídos integralmente**. Por esse motivo,
este repositório não atribui limiares específicos de MAF, missingness ou um
método específico de imputação à geração de `dados_gblup.csv` sem evidência
documental adicional.

Essa limitação de proveniência não modifica as análises apresentadas no
tutorial, que partem explicitamente do arquivo analítico final já codificado e
sem valores ausentes.

## Redistribuição

Os arquivos públicos de referência possuem sua própria documentação e seus
próprios termos de disponibilização. O arquivo derivado `dados_gblup.csv` não é
versionado neste repositório enquanto os termos aplicáveis à redistribuição
dessa versão analítica não forem formalmente estabelecidos. Por isso,
`data/dados_gblup.csv` permanece listado no `.gitignore`.

Essa separação permite manter público o pipeline analítico e os resultados do
estudo sem redistribuir desnecessariamente uma cópia derivada dos dados.