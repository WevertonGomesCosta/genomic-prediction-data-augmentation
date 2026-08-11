# Dados do tutorial

O arquivo analítico utilizado pelos módulos deve ser colocado localmente em:

```text
data/dados_gblup.csv
```

## Estrutura esperada

O arquivo validado contém:

- 1.379 indivíduos;
- uma coluna fenotípica chamada `yield`;
- 4.325 colunas de SNPs;
- SNPs codificados como `0`, `1` ou `2`;
- nenhum valor ausente nos SNPs;
- nenhum marcador monomórfico no arquivo analítico final.

O recurso SoyNAM original utiliza um painel de aproximadamente 5K SNPs. Depois
do processamento que originou o arquivo usado neste projeto, 4.325 SNPs estão
presentes na matriz analítica efetivamente modelada.

## Por que o CSV não está no GitHub?

Os termos de redistribuição da fonte original devem ser confirmados antes de
publicar o arquivo analítico. Por segurança, `data/dados_gblup.csv` está listado
no `.gitignore`.

Isso não impede a reprodução do tutorial: depois de obter e preparar os dados,
basta colocar o CSV nesta pasta e executar os módulos na ordem indicada no
`README.md`.

## Primeiro passo depois de adicionar os dados

Execute:

```r
workflowr::wflow_build("analysis/01_data_audit.Rmd")
```

A Etapa 1 verifica se o arquivo possui exatamente a estrutura esperada antes de
qualquer modelagem.
