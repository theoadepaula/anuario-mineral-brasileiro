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
.p <- paleta(3)
.t <- tinta()

PAL <- c(slot1 = unname(.p[["s1"]]), slot2 = unname(.p[["s2"]]),
         slot3 = unname(.p[["s3"]]))

TINTA      <- unname(.t[["forte"]])
TINTA_2    <- unname(.t[["media"]])
TINTA_MUDA <- unname(.t[["fraca"]])
GRADE      <- unname(.t[["grade"]])
EIXO       <- unname(.t[["eixo"]])

tema_amb <- function(base_size = 12) {
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

interativo <- function(p, altura = 4.2, largura = 7.5) {
  ggiraph::girafe(
    ggobj = p, width_svg = largura, height_svg = altura,
    options = list(
      # realce por serie: passar o mouse em um ponto acende a serie inteira
      ggiraph::opts_hover(css = "stroke-width:3.5;"),
      ggiraph::opts_hover_inv(css = "opacity:0.25;"),
      ggiraph::opts_tooltip(
        css = paste0(
          "background:", TINTA, ";color:#fcfcfb;padding:6px 9px;",
          "border-radius:8px;font-family:system-ui,sans-serif;font-size:12.5px;",
          "line-height:1.45;box-shadow:0 6px 20px rgba(0,0,0,.22);"
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

n_br <- function(x, dec = 1) {
  format(round(x, dec), big.mark = ".", decimal.mark = ",",
         nsmall = dec, trim = TRUE, scientific = FALSE)
}

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
tabela_amb <- function(x, nota = NULL) {
  g <- tabela_gt(x, nota = nota)
  g
}

# Formatacao numerica brasileira: separador de milhar ponto, decimal virgula.
fmt_br <- function(g, colunas, decimais = 0) {
  gt::fmt_number(g, columns = {{ colunas }}, decimals = decimais,
                 sep_mark = ".", dec_mark = ",")
}

fmt_pct_br <- function(g, colunas, decimais = 1) {
  gt::fmt_percent(g, columns = {{ colunas }}, decimals = decimais,
                  sep_mark = ".", dec_mark = ",")
}
