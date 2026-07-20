# Anuário Mineral Brasileiro (AMB) — ANM

Produção mineral declarada **por UF e substância**, série anual de 2010 a 2025.

**Status: quatro artigos escritos. Os dois primeiros foram revisados e aprovados
pelo Théo em 2026-07-19, prontos para agendamento (o agendamento é dele). Os
artigos 3 e 4 aguardam revisão.** Ver *Estado atual*, no fim.

## Fonte

Origem primária: **Relatório Anual de Lavra (RAL)** — declaração da própria
mineradora, com ajustes e depurações da ANM. Catálogo: <https://dadosabertos.anm.gov.br/AMB/>

| Recurso | URL |
|---|---|
| Produção bruta | `https://dadosabertos.anm.gov.br/AMB/Producao_Bruta.csv` |
| Produção beneficiada | `https://dadosabertos.anm.gov.br/AMB/Producao_Beneficiada.csv` |
| Água mineral | `https://dadosabertos.anm.gov.br/AMB/Agua_Mineral_Producao.csv` |

Atualização **diária**. Codificação **Windows-1252 (CP-1252)**.

## O snapshot é a matéria-prima, não o CSV

A ANM reescreve esses arquivos todo dia. Um download sem data não é um dado —
é um boato. Por isso `dados_brutos/` guarda **pastas datadas** com checksum:

```
dados_brutos/2026-07-18/          os 3 CSVs + metadados, como estavam nesse dia
dados_brutos/2026-07-18.sha256    checksum de cada arquivo
```

Nunca sobrescrever uma pasta de snapshot. Cada novo download vira uma pasta nova.
É a comparação entre elas que sustenta o projeto.

## O recorte

"Análise da mineração brasileira" seria um projeto fraco aqui: não há domínio de
mineração para sustentar a interpretação, e o tema não conversa com resíduos,
saneamento e gestão pública.

O que justifica o projeto é a natureza do dado — **série declaratória reescrita
diariamente**. O número de 2015 publicado hoje não é o número de 2015 publicado
em 2016. Isso é um caso de **memória institucional de dados**, respondível com
estatística e governança, sem geologia.

**Pergunta central:** quanto a produção oficialmente registrada de um ano muda
depois que o ano acabou — e a revisão é ruído simétrico ou viés numa direção?

Verificável de duas formas: (a) comparando snapshots ao longo do tempo — este
acervo começa em 2026-07-18; (b) comparando com os PDFs históricos do AMB, que
trazem os valores **como publicados à época**.

## O que o perfil dos dados mostrou

Série 2010–2025, 16 anos completos, sem lacunas de ano. Todos os 27 UFs presentes
em todo ano na bruta e na água mineral. Sem valores nulos e **sem negativos**.

| Arquivo | Linhas | Colunas | Substâncias | UFs |
|---|---|---|---|---|
| `Producao_Bruta.csv` | 6.312 | 14 | 56 | 27 |
| `Producao_Beneficiada.csv` | 3.978 | 18 | 52 | 26 |
| `Agua_Mineral_Producao.csv` | 432 | 17 | 1 | 27 |

## Armadilhas confirmadas no dado

**É UF, não município.** A produção municipal (~2.700 municípios, ~175
substâncias) é um conjunto **separado** da ANM, não este. Isso enfraquece o
gancho direto com repasse de CFEM, que é municipal — se esse ângulo interessar,
precisa do outro conjunto.

**`(Ano, UF, Substância)` NÃO é chave única.** 72 chaves duplicadas na bruta, 29
na beneficiada, por **duas causas distintas com regras de agregação opostas**:

- *Óxido contido.* O mesmo minério declarado uma vez por óxido — Columbita-Tantalita
  com `Ta2O5` e com `Nb2O5`. **Não há regra única:** em 10 dos 39 grupos desse tipo
  `rom_t` e `venda_rs` são idênticos nas duas linhas (somar duplica a tonelagem);
  nos outros 29 diferem (somar é correto). Só afeta metálicos.
- *Registros distintos sem dimensão exportada.* 33 grupos na bruta com
  `contido_indicacao` vazio e quantidades diferentes — produções separadas
  colapsadas na mesma chave. Somar é adequado.

Os artigos atuais só tratam não-metálicos, onde ocorre apenas o segundo caso.
A versão completa está em `dicionario_de_dados.qmd`.

> **O bloqueio dos metálicos é menor do que as 72 chaves sugerem.** Restringindo a
> 2025, sobram **3 grupos duplicados, todos Columbita-Tantalita** (medido em
> 2026-07-19). Recortes de ano recente podem incluir metálicos tratando só esse caso.

**Bruta e beneficiada não somam.** São estágios do mesmo minério.

**Acre não existe na beneficiada.** Presente na bruta, ausente na beneficiada nos
16 anos. Provável ausência real de usina, não falha — mas confirmar antes de
tratar como zero.

**A água mineral é boa demais.** Exatamente 27 UFs × 16 anos = 432 linhas, zero
duplicata, zero nulo. Grade perfeita significa que os zeros são preenchidos:
zero pode ser "não produziu" ou "não declarou". São coisas diferentes.

**Os metadados erram o delimitador.** A ficha afirma "valores separados por ponto
e vírgula"; o arquivo é separado por **vírgula**, com campos entre aspas e
decimal também em vírgula. Ler com `sep=";"` falha silenciosamente.

**Valores carregam lixo de ponto flutuante.** `2400373,5300000003` na origem.
Arredondar antes de comparar snapshots, ou toda linha vai parecer "revisada".

**Muitos zeros estruturais.** Ex.: `Quantidade Contido` é zero em 4.547 das 6.312
linhas da bruta — só faz sentido para metálicos.

**Reais nominais.** 15 anos sem deflacionar não são comparáveis. A série de valor
de venda salta de R$ 2,2 bi (2010) para R$ 10,9 bi (2025); boa parte disso é preço
e câmbio, não volume.

**2025 parece completo** (R$ 10,9 bi, +10,4% sobre 2024 — não é o degrau para
baixo típico de ano parcial). Mas é o ano-base mais recente numa base declaratória:
é justamente o que mais deve se mover nos próximos snapshots.

## Plano editorial: um artigo por conjunto? Não.

**Água mineral — SIM, e é por onde começar.** É o menor arquivo e o mais forte.
Único analiticamente limpo (432 linhas, grade perfeita, zero duplicata, sem o
problema de contido); único que toca o domínio de resíduos sólidos, porque é
quebrado **por embalagem**; e o único que cabe em 3h/semana. Garrafão retornável
caiu de 75,7% para 70,0% do volume e a garrafa plástica de uso único subiu de
21,6% para 28,4% (+6,8 p.p.). O garrafão sai a R$ 0,19/litro contra R$ 1,34 da
garrafa plástica — **7x** — o que explica a migração e liga água mineral a
plástico de uso único.

**Produção bruta — SIM, mas reenquadrada.** Não como "mineração brasileira", e sim
partindo dos **insumos da construção civil**: areia, rochas britadas e argilas,
que fazem ponte com RCC, problema concreto de SLU.

> **Reenquadrado de novo durante a apuração.** Ao abrir a série apareceu um erro
> grande demais para virar rodapé (SC/brita 2025 — ver *Estado atual*), e o artigo
> virou peça metodológica de auditoria com os agregados como caso. O gancho com RCC
> continua disponível para um texto futuro.

Cuidado com `Valor Venda` na bruta — ela engana: Ferro aparece com só 10,4% do
valor de 2025, porque quase todo minério de ferro é transferido para beneficiamento
em vez de vendido bruto. O valor grande está na beneficiada.

> **Medido em 2026-07-19, e é pior do que parecia.** Venda declarada em 2025:
> **R$ 10,9 bi na bruta contra R$ 280,1 bi na beneficiada** — a bruta contém 3,7%
> do dinheiro do setor. Em MG, 97,7% do valor está na beneficiada; no PA, 99,7%.
> Qualquer ranking de UF por valor feito na bruta erra por uma ordem de grandeza.

**Produção beneficiada — NÃO como artigo próprio.** 51 das 52 substâncias também
estão na bruta. Não é outra história, é o mesmo minério num estágio posterior.
Serve como tabela de apoio da bruta, não como texto separado.

### Painel interativo? Não agora.

Contra: a ANM **já publica painéis interativos** do setor mineral — competir com o
painel da própria agência, com dado pior, é briga perdida. E o volume não pede
painel: 432 linhas de água mineral cabem em dois gráficos estáticos bem-feitos.
Painel também custa manutenção contínua e envelhece mal num portfólio.

A exceção defensável é um painel que a ANM **não pode** ter: um *rastreador de
revisão*, mostrando quanto cada ano-base se moveu entre snapshots. Mas isso exige
vários snapshots — não dá para fazer agora.

### A anomalia de 2024 é o gancho, não um problema

Em 2024 o garrafão desaba para 60,4% e a plástica salta para 38,4%; em 2025 volta
para 70,0%/28,4%. O volume nacional sobe +28,9% em 2024 e cai −16,6% em 2025.
A causa está concentrada em **SP: 3,6 → 6,4 → 3,4 bilhões de litros** — sobe 77% e
volta para abaixo do ponto de partida. SP responde por ~80% do salto nacional.

Consumo de água não faz isso. É artefato declaratório — e é exatamente a tese do
projeto aparecendo dentro do menor arquivo do conjunto. O artigo de água mineral
já nasce com o caso concreto que a tese precisa.

## Estado atual

Site Quarto/R construído sobre o snapshot `2026-07-18`, renderizando limpo.

```
code/01_ler.R              CP-1252 + decimal vírgula -> parquet, com validação
code/02_ipca.R             IPCA (BCB/SGS 433) -> deflator anual em dados/ipca.parquet
code/tema.R                paleta validada para daltonismo + tema ggplot + tabela_amb() (gt)
index.qmd                  o que é a base e por que o snapshot importa
dicionario_de_dados.qmd    colunas e armadilhas
artigos/01-agua-mineral.qmd        migração garrafão -> descartável
artigos/02-auditoria-agregados.qmd roteiro de auditoria, caso SC/brita
artigos/03-preco-real.qmd          preço real x nominal, e efeito de composição
artigos/04-valor-por-tonelada.qmd  valor por tonelada, por substância e por UF
```

Rodar: `Rscript code/01_ler.R && Rscript code/02_ipca.R && quarto render`.

**`dados_brutos/<data>/` guarda mais de uma fonte.** O snapshot da ANM
(`2026-07-18`) e o do IPCA (`2026-07-19`) são pastas datadas irmãs, com datas
diferentes porque foram baixados em dias diferentes. Cada script filtra pelo
arquivo-chave que espera — `01_ler.R` exige `Producao_Bruta.csv`, `02_ipca.R`
exige `ipca-sgs-433.json`. Sem esse filtro, pegar "a pasta mais recente" escolhe
a fonte errada.

**Tags no `categories:` do YAML** (acrescentadas em 2026-07-19), como nos demais
projetos — o Quarto as renderiza logo abaixo do subtítulo. O vocabulário é
compartilhado de propósito; só `mineração` e `inflação` nasceram aqui:

| artigo | tags |
|---|---|
| 01 água mineral | dados abertos · resíduos sólidos · série histórica · mineração |
| 02 auditoria | mão na massa · método · qualidade de dado · mineração |
| 03 preço real | método · série histórica · inflação · mineração |
| 04 valor/tonelada | dados abertos · qualidade de dado · método · mineração |

Reaproveitados de `Relatorios_slu` e `Cargos_executivo_federal`: *dados abertos,
setor público, série histórica, resíduos sólidos, coleta seletiva, mão na massa,
método, extração de dados, qualidade de dado, gestão de pessoas*. **Conferir essa
lista antes de criar tag nova** — duas tags para a mesma ideia quebram a navegação
no site.

**Gráficos são interativos via `ggiraph`, não plotly** (trocado em 2026-07-19).
Os nove gráficos dos quatro artigos têm tooltip por ponto e realce de série ao
passar o mouse. O helper `interativo()` em `code/tema.R` centraliza as opções.

> **Por que não plotly.** Não é preferência — é medição. `ggplotly()` **descarta
> `subtitle` e `caption`**; só o `title` sobrevive (testado em 2026-07-19). O caption
> de todo gráfico daqui carrega a data do snapshot, que é a premissa inteira do
> projeto. O `ggiraph` renderiza o próprio ggplot em SVG, então tema, paleta
> validada para daltonismo, rótulos diretos e caption chegam intactos.

> **Custo conhecido: 18,6 MB de fontes que ninguém baixa.** O `ggiraph` anexa as
> fontes Liberation (`site_libs/liberation-{sans,serif,mono}`) como dependência
> HTML. Os SVGs daqui saem com `font-family: system-ui` e **nenhum elemento
> referencia as Liberation**, então o navegador não busca os `.ttf` — `@font-face`
> é preguiçoso. O custo é de disco e de deploy, não do leitor. Tentei desligar com
> `gdtools::font_set_auto()` e **não funciona** (medido: continua em 20 MB); não
> deixei o código morto no `tema.R`. Se o peso incomodar no repo do site, a saída é
> podar `site_libs/liberation-*` no passo de build.

**Tabelas usam `gt`, não `kable`** (trocado em 2026-07-19). O helper `tabela_amb()`
em `code/tema.R` aplica as mesmas tintas do tema dos gráficos; `fmt_br()` e
`fmt_pct_br()` cuidam do separador de milhar ponto e decimal vírgula num lugar só.
Os números vão crus para o `gt` — a formatação deixou de ser string colada com
`paste0()`, que é o que permite destacar linhas (a de SC, nos artigos de auditoria).
Sem fontes externas: nada de `google_font()`, para o site não depender de rede.

O artigo 2 mudou de enquadramento durante a apuração. Ia ser sobre agregados da
construção civil; virou **peça metodológica de auditoria**, porque a série de
rochas britadas de 2025 contém um erro grande demais para ser rodapé: **SC declara
1.136 Mt contra 38,4 Mt em 2024** — a maior linha de ROM dos 16 anos, maior que o
ferro de MG, com venda subindo só 2x. Isso também evita que os dois artigos
terminem na mesma conclusão de "o dado é ruim": o 1 é substantivo, o 2 é método.

## Próximos passos

1. Revisão do Théo nos artigos 3 e 4.
2. **Pauta ainda não escrita:** previsão até 2030 apenas como *demonstração de
   fragilidade*, nunca como previsão publicada — incluir 2024 move a projeção de
   18,4 para 30,1 bi L e alarga o IC95% para [19,2 ; 41,1]. Só faz sentido depois
   que a série tiver crédito, e o artigo 2 já ocupa o nicho metodológico.
2. `code/02_baixar.R` — automatizar o download carimbado (hoje o snapshot foi manual).
3. Resolver as 33 duplicatas residuais da bruta (não afetam os artigos atuais,
   que só tratam não-metálicos).
4. Baixar 2–3 PDFs históricos do AMB para o par publicado-então × aberto-agora.
5. Segundo snapshot, para medir a revisão diretamente.
6. Transformar em código os quatro testes de auditoria do artigo 2 — hoje eles
   existem só como prosa, e deveriam rodar contra todo snapshot novo.

## Notas de ambiente

**R e Quarto não estão no PATH.** Estão instalados, mas invocá-los exige caminho
completo. No Git Bash:

```bash
export PATH="/c/Program Files/R/R-4.5.2/bin/x64:/c/Program Files/Quarto/bin:$PATH"
```

Versões usadas: R 4.5.2, Quarto 1.9.36. Pacotes presentes: `dplyr`, `ggplot2`,
`arrow`, `readr`, `scales`, `tidyr`, `knitr`, `stringr`, `rprojroot`.

**O pandoc embutido no RStudio está corrompido.**
`C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools\pandoc.exe` tem 120,6 MB
contra ~232 MB dos binários íntegros — download truncado. O Windows recusa executá-lo
(*Exec format error*), e renderizar de dentro do RStudio falha com:

```
'CreateProcess' falhou ao executar '...\RStudio\...\tools\pandoc.exe --version'
```

Não é erro do documento: pela linha de comando `quarto render` sempre funcionou,
porque fora do RStudio `RSTUDIO_PANDOC` vem vazio. Contorno aplicado em
`C:\Users\theoa\.Renviron` (criado em 2026-07-19):

```
RSTUDIO_PANDOC=C:/Program Files/Quarto/bin/tools
```

Exige reiniciar a sessão do R. Correção definitiva: reinstalar o RStudio.
Atenção: o `rmarkdown` escolhe a versão mais alta que encontra, então o preview
acaba usando o pandoc avulso 3.9.0.2 enquanto `quarto render` usa o 3.8.3 do
Quarto — se a saída divergir entre os dois, a causa é essa.

**Abrir o `.Rproj` antes do `.qmd`.** Abrir `artigos/01-agua-mineral.qmd` direto no
RStudio faz ele rodar `quarto preview 01-agua-mineral.qmd` de dentro de `artigos/`,
sem saber que existe um projeto. Como o `_quarto.yml` está na raiz, o Quarto muda o
diretório de execução para lá e o nome nu deixa de resolver:

```
Error in rmarkdown:::abs_path(input) :
  The file '01-agua-mineral.qmd' does not exist.
```

O arquivo existe — o que não existe é *naquele* diretório. Abrir
`anuario_mineral_brasileiro.Rproj` primeiro resolve. Pela linha de comando,
`quarto render` na raiz sempre funcionou.

**A API do dados.gov.br devolve 401 e o portal é SPA.** As URLs dos recursos vieram
do `metadados-amb.ods`, não do portal. Para conferir recursos novos, abrir o ODS —
não tentar raspar a página.

**Há duas pastas parecidas em `Site/`, e isso é uma armadilha:**

| Pasta | Conteúdo |
|---|---|
| `Projetos_dados_abertos/` | os projetos de verdade — `Cargos_executivo_federal` e este |
| `projeto_dados_abertos/` | só 3 PDFs de relatório anual do SLU |

Este projeto está na **primeira**. Em disco Windows, dois nomes que diferem só por
maiúscula e um "s" são frágeis; pode ter vindo de conflito de sincronização do
OneDrive. Vale consolidar.

---

## Como reproduzir

### 1. Dependências

```r
pak::pak("theoadepaula/theoviz")   # paleta, tabelas gt, formatação pt-BR
```

Mais `arrow`, `dplyr`, `tidyr`, `ggplot2`, `ggiraph`, `scales`, `gt`.
R 4.5.2, Quarto 1.9.

### 2. Dados brutos — **versionados**, ao contrário dos outros projetos

Aqui os snapshots datados **ficam no repositório** (1,7 MB). Não é insumo
descartável: a ANM reescreve os CSVs todo dia, então o snapshot **é** a
matéria-prima, e é a comparação entre snapshots que sustenta a tese do projeto.

```
dados_brutos/2026-07-18/        os 3 CSVs da ANM, como estavam nesse dia
dados_brutos/2026-07-18.sha256  checksum de cada arquivo
```

Nunca sobrescreva uma pasta de snapshot — cada download novo vira pasta nova.

Para conferir um snapshot:

```bash
cd dados_brutos && sha256sum -c 2026-07-18.sha256
```

### 3. Rodar

```bash
Rscript code/01_ler.R      # CP-1252 + decimal vírgula -> parquet, com validação
Rscript code/02_ipca.R     # IPCA (BCB/SGS 433) -> deflator anual
quarto render
```

⚠️ **Abra o `.Rproj` antes de qualquer `.qmd`** no RStudio — abrir o `.qmd`
direto faz o Quarto rodar de dentro de `artigos/` e o caminho deixa de resolver.
Pela linha de comando, `quarto render` na raiz sempre funciona.

### 4. Pendência conhecida

Não há ainda `code/07_conferir_prosa.R` — o script que afirma contra o dado os
números citados em texto corrido, como os outros dois projetos têm. É pendência
aberta, registrada no `CONTEXTO-PROJETO.md`, e deve existir antes de publicar.
