# Contexto do projeto — Anuário Mineral Brasileiro (ANM)

> Ponto de entrada do projeto. O [`README.md`](README.md) é o manual técnico
> (como reproduzir, o que cada script faz, notas de ambiente); **este arquivo é o
> porquê** — as decisões, o que foi descartado e o que está pendente.

---

## 1. O que é e para que serve

Produção mineral declarada **por UF e substância**, série anual 2010–2025, a
partir dos dados abertos do Anuário Mineral Brasileiro da ANM. Alimenta **quatro
artigos** no site. **Não tem painel, e isso é decisão, não pendência** (ver §2).

Fonte: <https://dadosabertos.anm.gov.br/AMB/> — origem primária é o Relatório
Anual de Lavra (RAL), declaração da própria mineradora com depuração da ANM.

✅ **Sem cuidado de contexto.** Diferente de `Relatorios_slu` (que analisa o
próprio órgão do Théo) e de `Cargos_executivo_federal` (que toca pessoal do
Executivo federal), aqui não há vínculo funcional nem risco sob a Lei 840. É o
projeto mais confortável dos três para publicar, e por isso serve bem como peça
de abertura de qualquer série.

---

## 2. Decisões tomadas

### O recorte — por que mineração, sem entender de mineração

"Análise da mineração brasileira" seria um projeto fraco: não há domínio
geológico para sustentar a interpretação, e o tema não conversa com resíduos,
saneamento e gestão pública.

O que justifica o projeto é **a natureza do dado**, não o assunto: é uma série
declaratória **reescrita diariamente**. O número de 2015 publicado hoje não é o
número de 2015 publicado em 2016. Isso é **memória institucional de dados** —
respondível com estatística e governança, sem geologia.

> **Pergunta central:** quanto a produção oficialmente registrada de um ano muda
> depois que o ano acabou — e a revisão é ruído simétrico ou viés numa direção?

### O snapshot é a matéria-prima, não o CSV

A ANM reescreve os arquivos todo dia. **Um download sem data não é um dado, é um
boato.** Por isso `dados_brutos/` guarda pastas datadas com checksum
(`2026-07-18/` + `2026-07-18.sha256`), e **nunca se sobrescreve um snapshot** —
cada download novo vira pasta nova. É a comparação entre elas que sustenta o
projeto inteiro.

Consequência para os artigos: **o `caption` de todo gráfico carrega a data do
snapshot.** Perder o caption quebraria a premissa — é por isso que o
`ggplotly()` foi reprovado aqui (ver abaixo).

⚠️ `dados_brutos/<data>/` guarda **mais de uma fonte** — o snapshot da ANM
(2026-07-18) e o do IPCA (2026-07-19) são pastas irmãs com datas diferentes.
Cada script filtra pelo arquivo-chave que espera. Pegar "a pasta mais recente"
escolhe a fonte errada.

### Sobre os artigos

- Quatro artigos em `.qmd` com R (regra fixa do site).
- **Tabelas em `gt`** via o tema canônico; **gráficos interativos em `ggiraph`**,
  como o `Cargos_executivo_federal`. Helpers em
  [`code/tema.R`](code/tema.R): `interativo()`, `tabela_amb()`, `fmt_br()`.
- ❌ **`ggplotly()` reprovado por medição, não por gosto** (2026-07-19): descarta
  `subtitle` e `caption` — só o `title` sobrevive. Como o caption carrega a data
  do snapshot, usá-lo destruiria a premissa do projeto.
- **Paleta validada para daltonismo**; os três slots são mecanismo de segurança,
  não escolha estética. O rosa fica abaixo de 3:1 de contraste sobre fundo
  branco, então **todo gráfico traz rótulo direto** — a identidade da série nunca
  depende só da cor.
- **Caminhos normalizados para `here::here()` em 2026-07-19.** Antes o projeto
  usava `rprojroot::find_rstudio_root_file()`, divergindo dos outros dois. Nove
  ocorrências em oito arquivos. Não reintroduzir `rprojroot`.
- **Tags reaproveitadas** dos outros projetos; só `mineração` e `inflação`
  nasceram aqui. Conferir a lista do README antes de criar tag nova — duas tags
  para a mesma ideia quebram a navegação no site.

### Por que NÃO tem painel

Decisão consciente, e vale manter:

- **A ANM já publica painéis interativos** do setor mineral. Competir com a
  própria agência, com dado pior, é briga perdida.
- **O volume não pede painel.** 432 linhas de água mineral cabem em dois
  gráficos estáticos bem-feitos.
- Painel custa manutenção contínua e envelhece mal num portfólio.

> **A exceção defensável** é um painel que a ANM *não pode* ter: um **rastreador
> de revisão**, mostrando quanto cada ano-base se moveu entre snapshots. Exige
> vários snapshots — impossível hoje, com um só. É a razão para continuar
> baixando snapshots datados mesmo sem uso imediato.

### Por que a beneficiada não virou artigo próprio

51 das 52 substâncias da beneficiada também estão na bruta. Não é outra
história — é o mesmo minério num estágio posterior. Serve como tabela de apoio,
não como texto separado.

---

## 3. Os achados, em uma linha cada

1. **A água mineral trocou de embalagem.** Garrafão retornável cai de 75,7% para
   70,0% do volume; a garrafa plástica de uso único sobe de 21,6% para 28,4%
   (+6,8 p.p.). O garrafão sai a R$ 0,19/litro contra R$ 1,34 da plástica —
   **7×** —, o que explica a migração e liga água mineral a plástico descartável.
2. **A anomalia de 2024 é a tese aparecendo no menor arquivo.** Garrafão desaba
   para 60,4% e volta para 70,0% em 2025; o volume nacional sobe 28,9% e cai
   16,6%. A causa concentra-se em **SP: 3,6 → 6,4 → 3,4 bilhões de litros**, ~80%
   do salto nacional. Consumo de água não faz isso — é artefato declaratório.
3. **SC declara 1.136 Mt de rochas britadas em 2025** contra 38,4 Mt em 2024: a
   maior linha de ROM dos 16 anos, maior que o ferro de MG, com venda subindo só
   2×. Erro grande demais para virar rodapé — virou o artigo 2.
4. **A produção bruta contém só 3,7% do dinheiro do setor.** R$ 10,9 bi na bruta
   contra R$ 280,1 bi na beneficiada (2025). Em MG, 97,7% do valor está na
   beneficiada; no PA, 99,7%. **Qualquer ranking de UF por valor feito na bruta
   erra por uma ordem de grandeza.**
5. **Reais nominais enganam em 15 anos.** A série de valor salta de R$ 2,2 bi
   (2010) para R$ 10,9 bi (2025) — boa parte é preço e câmbio, não volume.

---

## 4. Armadilhas do dado

Detalhe em [`dicionario_de_dados.qmd`](dicionario_de_dados.qmd). O essencial:

- **É UF, não município.** A produção municipal é um conjunto **separado** da
  ANM. Isso enfraquece o gancho com repasse de CFEM, que é municipal.
- **`(Ano, UF, Substância)` não é chave única** — 72 duplicatas na bruta, 29 na
  beneficiada, por duas causas com **regras de agregação opostas** (óxido contido
  × registros distintos). Só afeta metálicos; os artigos atuais tratam só
  não-metálicos. Restringindo a 2025 sobram 3 grupos, todos Columbita-Tantalita.
- **Bruta e beneficiada não somam.** São estágios do mesmo minério.
- **Acre não existe na beneficiada** nos 16 anos. Provável ausência real de
  usina — confirmar antes de tratar como zero.
- **A água mineral é boa demais.** 27 UFs × 16 anos = 432 linhas, grade perfeita.
  Grade perfeita significa zeros preenchidos: zero pode ser "não produziu" ou
  "não declarou", que são coisas diferentes.
- **Os metadados erram o delimitador** — a ficha diz ponto e vírgula, o arquivo é
  vírgula. Ler com `sep=";"` falha em silêncio.
- **Lixo de ponto flutuante na origem** (`2400373,5300000003`). Arredondar antes
  de comparar snapshots, ou toda linha parece "revisada".
- **2025 parece completo, mas é o que mais deve se mover.** É o ano-base mais
  recente numa base declaratória.

---

## 5. Estado do trabalho

### Pronto
- [x] Snapshot `2026-07-18` baixado com checksum; IPCA em `2026-07-19`
- [x] Pipeline em R: `01_ler.R` (CP-1252 + decimal vírgula → parquet, com
      validação) e `02_ipca.R` (BCB/SGS 433 → deflator anual)
- [x] Quatro artigos em `.qmd`, com `gt` e `ggiraph`, renderizando limpo
- [x] **Artigos 1 e 2 revisados e aprovados pelo Théo** em 2026-07-19
- [x] Tema alinhado ao canônico (`_comum/tema_tabelas_gt.R`) via `tabela_amb()`
- [x] Caminhos normalizados para `here::here()` (2026-07-19)
- [x] `CONTEXTO-PROJETO.md` — este arquivo (criado 2026-07-19; o projeto era o
      único dos três sem ponto de entrada)

### Aguardando
- [ ] **Revisão do Théo nos artigos 3 e 4.** Depois disso, agendar.

### Pendências abertas
- [ ] **`code/07_conferir_prosa.R`** — o projeto ainda não afirma contra o dado os
      números que os artigos citam em texto corrido. É exigência do padrão
      (`docs/CONTEXTO-SITE.md` §9.2) e o `Relatorios_slu` é o modelo.
- [ ] `code/02_baixar.R` — automatizar o download carimbado (hoje foi manual).
- [ ] Resolver as 33 duplicatas residuais da bruta (não afetam os artigos atuais).
- [ ] Baixar 2–3 PDFs históricos do AMB, para o par publicado-então ×
      aberto-agora.
- [ ] **Segundo snapshot**, para medir a revisão diretamente — é o que destrava a
      tese central e o único painel defensável.
- [ ] Transformar em código os quatro testes de auditoria do artigo 2; hoje
      existem só como prosa, e deveriam rodar contra todo snapshot novo.

### Pauta registrada, deliberadamente não escrita
Previsão até 2030 **apenas como demonstração de fragilidade**, nunca como
previsão publicada: incluir 2024 move a projeção de 18,4 para 30,1 bi L e alarga
o IC95% para [19,2 ; 41,1]. Só faz sentido depois que a série tiver crédito — e o
artigo 2 já ocupa o nicho metodológico.

---

## 6. O que NÃO dá para fazer com esta base

- **Nada municipal** — nem CFEM, nem recorte territorial fino. Exige o outro
  conjunto da ANM.
- **Nenhum ranking de UF por valor a partir da bruta** — erra por ordem de
  grandeza (achado 4).
- **Nenhuma soma entre bruta e beneficiada.**
- **Nenhuma afirmação sobre revisão de série ainda** — a tese central do projeto
  só é verificável com o segundo snapshot. Hoje ela aparece por evidência
  indireta (a anomalia de SP), não por medição direta.

---

## 7. Onde está cada coisa

| O que | Onde |
|---|---|
| Manual técnico, reprodução, notas de ambiente | [`README.md`](README.md) |
| Colunas e armadilhas | [`dicionario_de_dados.qmd`](dicionario_de_dados.qmd) |
| Scripts, na ordem | `code/01_ler.R`, `code/02_ipca.R` |
| Tema, paleta e helpers | `code/tema.R` |
| Artigos | `artigos/*.qmd` |
| Snapshots datados + checksum | `dados_brutos/<data>/` |
| HTML para revisão | `_site/` |

---

## 8. ⚠️ Onde o site realmente vive

Esta pasta do OneDrive **não é o site**. O site é um projeto Astro em
`C:\Users\theoa\dev\theoalbuquerque-site`, deliberadamente fora do OneDrive.

### Como este projeto entra no site

**Nada é transferido antes da aprovação do Théo** — hoje faltam os artigos 3 e 4.

Pelo plano de migração de 2026-07-19, este projeto vira **repo público próprio**
(`anuario-mineral-brasileiro`), e o site recebe só o necessário:

```
artigos/<slug>.qmd   →  <repo-site>\quarto\posts\<slug>\index.qmd
dados/*.parquet      →  <repo-site>\quarto\_dados\anuario\
                        (só parquet; dados_brutos NÃO vai — 1,7 MB de snapshots
                         ficam no repo público, com o script de download)
```

Sem painel, não há nada a copiar para `public/apps/`.

O tema deixa de ser arquivo e vira **pacote R** (`theoviz`), instalado por
`pak::pak()`. Quando isso acontecer, o `source()` do `_comum` em `code/tema.R`
sai e vira `library(theoviz)`.

Render local — o Cloudflare não roda R. **R e Quarto não estão no PATH**; veja a
receita no `README.md`, seção "Notas de ambiente".
