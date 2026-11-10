# tema.R -----------------------------------------------------------------
# Paleta e tema compartilhados pelos artigos.
#
# As cores sao os tres primeiros slots de uma paleta categorica validada para
# daltonismo (pior par adjacente: DeltaE 17.6 em protanopia; piso de visao
# normal 29.0). A ordem dos slots e o mecanismo de seguranca -- nao trocar por
# gosto. O rosa fica abaixo de 3:1 de contraste sobre fundo branco, entao todo
# grafico traz rotulo direto: a identidade da serie nunca depende so da cor.

library(ggplot2)
suppressPackageStartupMessages(library(theoviz))
source(here::here("code", "girafe_celular.R"))  # LARGURA_SVG, ajustar_textos()

RAIZ <- here::here()
dados <- function(arq) file.path(RAIZ, "dados", arq)

SNAPSHOT <- readLines(dados("SNAPSHOT"), warn = FALSE)[1]

# snapshot do deflator, gravado por code/02_ipca.R -- NA se ainda nao foi rodado
SNAPSHOT_IPCA <- if (file.exists(dados("SNAPSHOT_IPCA"))) {
  readLines(dados("SNAPSHOT_IPCA"), warn = FALSE)[1]
} else NA_character_

# Deflator: converte reais do ano para reais do ano-base (o mais recente).
# Media anual do indice, porque os valores do AMB sao fluxos do ano inteiro.
deflator <- function() {
  i <- arrow::read_parquet(dados("ipca.parquet"))
  i$fator <- i$indice[i$ano == max(i$ano)] / i$indice
  i[, c("ano", "fator")]
}

# As cores vem do pacote theoviz, fonte unica dos tres projetos -- nao literais
# aqui. Os NOMES locais sao preservados: os quatro artigos dependem deles.
#
# MODO ESCURO (2026-08-15): os artigos vao ao ar em pagina escura e ate aqui
# pediam ao theoviz as cores do modo CLARO -- o que punha figura de fundo quase
# branco dentro de pagina quase preta. Contra o chao do site (#0d1014) os slots
# medem 5,24 / 3,86 / 4,83; todos acima do piso de 3:1.
.p <- paleta(3, modo = "escuro")
.t <- tinta(modo = "escuro")

PAL <- c(slot1 = unname(.p[["s1"]]), slot2 = unname(.p[["s2"]]),
         slot3 = unname(.p[["s3"]]))

TINTA      <- unname(.t[["forte"]])
TINTA_2    <- unname(.t[["media"]])
TINTA_MUDA <- unname(.t[["fraca"]])
GRADE      <- unname(.t[["grade"]])
EIXO       <- unname(.t[["eixo"]])

# TEXTO NA COR DA SERIE (2026-11-09): o piso de 3:1 vale para marca; texto pede
# 4,5:1, e o verde s2 (#008300, 3,86:1) nao passa. O theoviz >= 0.4.0 tem
# `uso = "texto"`, que troca so o verde (#008f56, 4,60:1). Rotulo direto com a
# cor mapeada da serie: aes(colour = stage(<var>, after_scale =
# cor_texto(colour))) no geom_text -- o stage() e obrigatorio: um after_scale()
# sozinho apaga o mapeamento e o texto sai preto. Linhas, pontos e barras
# continuam em PAL.
if (packageVersion("theoviz") < "0.4.1")
  stop("code/tema.R exige theoviz >= 0.4.1 (paleta(uso = \"texto\"), num_br(), fmt_br()).")
.p_marca <- paleta(modo = "escuro")
.p_texto <- paleta(modo = "escuro", uso = "texto")
cor_texto <- function(cor) {
  i <- match(tolower(cor), tolower(.p_marca))
  ifelse(is.na(i), cor, unname(.p_texto)[i])
}

tema_amb <- function(base_size = 11) {  # 11, nao 12: ver girafe_celular.R
  theme_minimal(base_size = base_size) +
    theme(
      text             = element_text(colour = TINTA_2),
      plot.title       = element_text(colour = TINTA, face = "bold",
                                      size = rel(1.15), margin = margin(b = 4)),
      plot.subtitle    = element_text(colour = TINTA_2, size = rel(0.92),
                                      margin = margin(b = 12)),
      plot.caption     = element_text(colour = TINTA_MUDA, size = rel(0.78),
                                      hjust = 0, margin = margin(t = 12)),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      axis.text        = element_text(colour = TINTA_MUDA, size = rel(0.85)),
      axis.title       = element_blank(),
      panel.grid.major = element_line(colour = GRADE, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line.x      = element_line(colour = EIXO, linewidth = 0.4),
      legend.position  = "none",   # rotulo direto em vez de legenda
      plot.margin      = margin(6, 90, 6, 6)  # espaco a direita para os rotulos
    )
}

theme_set(tema_amb())

# Graficos interativos ----------------------------------------------------
# ggiraph, nao plotly. Motivo medido, nao preferencia: ggplotly() descarta
# subtitle e caption (testado em 2026-07-19 -- so o title sobrevive), e o
# caption de todo grafico daqui carrega a data do snapshot. Perder isso
# quebraria a premissa do projeto. O ggiraph renderiza o proprio ggplot em SVG,
# entao tema, paleta validada, rotulos diretos e caption chegam intactos.

interativo <- function(p, altura = 4.2, largura = LARGURA_SVG) {
  ggiraph::girafe(
    ggobj = ajustar_textos(p, largura), width_svg = largura, height_svg = altura,
    options = list(
      # realce por serie: passar o mouse em um ponto acende a serie inteira
      ggiraph::opts_hover(css = "stroke-width:3.5;"),
      ggiraph::opts_hover_inv(css = "opacity:0.25;"),
      # O tooltip NAO segue o TINTA/TINTA_2 do tema. Enquanto o modo era claro,
      # `background: TINTA` era tinta escura com texto quase branco por cima e
      # funcionava. Ao virar o modo, TINTA passou a ser cinza CLARO (#dde1e6) e
      # o mesmo par viraria branco sobre branco -- ilegivel. Um tooltip flutua
      # acima da figura, entao ele quer a chapa do site, nao a tinta de texto.
      ggiraph::opts_tooltip(
        css = paste0(
          "background:", site("chapa"), ";color:", site("titulo"), ";",
          "border:1px solid ", site("filete"), ";padding:7px 10px;",
          "border-radius:0;font-family:'IBM Plex Sans',system-ui,sans-serif;",
          "font-size:12.5px;line-height:1.45;"
        ),
        opacity = 1, use_fill = FALSE
      ),
      ggiraph::opts_toolbar(saveaspng = FALSE),
      ggiraph::opts_sizing(rescale = TRUE, width = 1)
    )
  )
}

# Rotulo de tooltip em portugues, com milhar ponto e decimal virgula.
dica <- function(...) paste0(...)

# Nome local preservado (os quatro artigos chamam n_br); o formato vem do
# theoviz::num_br(). Todas as chamadas passam `dec` explicito.
n_br <- function(x, dec = 1) num_br(x, dec)

# Tabelas -----------------------------------------------------------------
# O estilo e o tema CANONICO de todos os projetos, aprovado por Theo em
# 2026-07-19 e hoje no pacote `theoviz`. Nao edite o layout aqui -- edite no
# pacote, senao os projetos divergem de novo.
#
# O `tabular-nums` deste projeto foi o que sobreviveu para o canonico; o que
# mudou aqui foi perder a regua entre linhas e ganhar cabecalho a esquerda.
# Agora vem do pacote theoviz (antes: source() do _comum, que subia um nivel na
# arvore do OneDrive e quebraria ao migrar para o site).

# Nome local preservado: os quatro artigos e o dicionario chamam tabela_amb(x, nota).
#
# O `modo = "escuro"` nao e detalhe: sem ele o gt crava `background-color:
# #FFFFFF` inline, e nenhuma folha de estilo derruba estilo inline. Toda tabela
# destes artigos ia ao ar como retangulo branco no meio da pagina escura.
tabela_amb <- function(x, nota = NULL) {
  g <- tabela_gt(x, nota = nota, modo = "escuro")
  g
}

# Formatacao numerica brasileira (milhar ponto, decimal virgula): fmt_br() e
# fmt_pct_br() vem do theoviz, com a mesma assinatura das copias que moravam
# aqui -- os artigos as chamam sem mudanca.
