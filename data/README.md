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

## Reutilização e versionamento

Os dados de referência utilizados neste projeto são publicados no Dryad sob
**CC0 (Creative Commons Zero)**. Esse instrumento permite reutilização,
modificação, compartilhamento e redistribuição dos dados. A citação da fonte
permanece recomendada como prática acadêmica:

- Sagae et al., conjunto de dados Dryad:
  [doi:10.5061/dryad.2fqz6133v](https://doi.org/10.5061/dryad.2fqz6133v)
- política de reutilização do Dryad:
  [How to reuse Dryad data](https://datadryad.org/help/guides/reuse)

O arquivo local `data/dados_gblup.csv` continua não versionado e permanece no
`.gitignore`. Essa decisão é **organizacional e de proveniência**, e não uma
restrição de licença: o arquivo representa a entrada analítica local cuja
sequência histórica exata de filtragem e imputação não foi reconstruída
integralmente.

Para tornar o tutorial reprodutível a partir do estado já auditado, objetos
derivados necessários às etapas seguintes são versionados em `output/`,
incluindo `output/01_data_objects.rds`. Esses objetos devem ser interpretados
como derivados analíticos dos dados SoyNAM de referência e permanecem sujeitos
à documentação de proveniência e às limitações descritas acima.
