# 01_ler.R ---------------------------------------------------------------
# Le os CSVs do snapshot mais recente em dados_brutos/ e grava parquet em dados/.
#
# Os arquivos da ANM sao CP-1252, delimitados por virgula, com decimal TAMBEM em
# virgula (todos os campos vem entre aspas). A ficha de metadados afirma que o
# delimitador e ponto-e-virgula -- esta errada.
#
# Estrategia: ler tudo como texto e converter na mao. Deixar o readr adivinhar
# numero com decimal_mark = "," num arquivo delimitado por "," e pedir problema.

library(readr)
library(dplyr)
library(arrow)

RAIZ <- here::here()
setwd(RAIZ)

# --- snapshot mais recente ----------------------------------------------
snapshots <- list.dirs("dados_brutos", recursive = FALSE, full.names = FALSE)
snapshots <- snapshots[grepl("^\\d{4}-\\d{2}-\\d{2}$", snapshots)]

# Nem toda pasta datada e um snapshot da ANM: o deflator do IPCA tambem mora em
# dados_brutos/<data>/. Exigir o arquivo-chave evita escolher a pasta errada
# quando os dois foram baixados em dias diferentes.
snapshots <- snapshots[file.exists(
  file.path("dados_brutos", snapshots, "Producao_Bruta.csv")
)]
stopifnot("nenhum snapshot da ANM em dados_brutos/" = length(snapshots) > 0)
SNAP <- max(snapshots)
message("snapshot: ", SNAP)

caminho <- function(arq) file.path("dados_brutos", SNAP, arq)

# --- helpers ------------------------------------------------------------
# ",000000" -> 0 ; "2400373,5300000003" -> 2400373.53
num_br <- function(x) {
  x <- trimws(x)
  x[x %in% c("", "-")] <- NA_character_
  x <- sub("^,", "0,", x)
  as.numeric(gsub(",", ".", x, fixed = TRUE))
}

# Le como texto puro. Nomes vem por posicao: escrever os nomes originais neste
# arquivo (com acento, vindos de CP-1252) e fonte garantida de dor de encoding.
ler_texto <- function(arq) {
  read_delim(
    caminho(arq),
    delim = ",", quote = "\"", col_names = TRUE, col_types = cols(.default = col_character()),
    locale = locale(encoding = "windows-1252"), trim_ws = TRUE, progress = FALSE
  )
}

renomear <- function(df, nomes) {
  stopifnot("numero de colunas mudou na origem" = ncol(df) == length(nomes))
  setNames(df, nomes)
}

# --- producao bruta ------------------------------------------------------
bruta <- ler_texto("Producao_Bruta.csv") |>
  renomear(c(
    "ano", "uf", "classe", "substancia",
    "rom_t", "contido_qtd", "contido_unidade", "contido_indicacao",
    "venda_t", "venda_rs",
    "transformacao_t", "transformacao_rs",
    "transferencia_t", "transferencia_rs"
  )) |>
  mutate(
    ano = as.integer(ano),
    across(c(rom_t, contido_qtd, venda_t, venda_rs, transformacao_t,
             transformacao_rs, transferencia_t, transferencia_rs), num_br),
    contido_indicacao = na_if(contido_indicacao, ""),
    metalico = classe == "Metálicos"
  )

# --- producao beneficiada ------------------------------------------------
beneficiada <- ler_texto("Producao_Beneficiada.csv") |>
  renomear(c(
    "ano", "uf", "classe", "substancia",
    "producao_qtd", "producao_unidade",
    "contido_qtd", "contido_unidade", "contido_indicacao",
    "venda_qtd", "venda_unidade", "venda_rs",
    "consumo_qtd", "consumo_unidade", "consumo_rs",
    "transferencia_qtd", "transferencia_unidade", "transferencia_rs"
  )) |>
  mutate(
    ano = as.integer(ano),
    across(c(producao_qtd, contido_qtd, venda_qtd, venda_rs, consumo_qtd,
             consumo_rs, transferencia_qtd, transferencia_rs), num_br),
    contido_indicacao = na_if(contido_indicacao, "")
  )

# --- agua mineral --------------------------------------------------------
# Aqui o formato e largo: uma coluna de litros e uma de R$ por embalagem.
# Empilhar deixa o dado utilizavel.
agua_largo <- ler_texto("Agua_Mineral_Producao.csv") |>
  renomear(c(
    "ano", "uf", "classe", "substancia",
    "litros_garrafao", "litros_garrafa_plastica", "litros_garrafa_vidro",
    "litros_copo", "litros_outras",
    "rs_garrafao", "rs_garrafa_plastica", "rs_garrafa_vidro",
    "rs_copo", "rs_outras",
    "litros_indust", "rs_indust", "unidade"
  )) |>
  mutate(ano = as.integer(ano), across(starts_with(c("litros_", "rs_")), num_br))

embalagens <- c(
  garrafao          = "Garrafão",
  garrafa_plastica  = "Garrafa plástica",
  garrafa_vidro     = "Garrafa de vidro",
  copo              = "Copo",
  outras            = "Outras embalagens"
)

agua <- lapply(names(embalagens), function(k) {
  tibble(
    ano       = agua_largo$ano,
    uf        = agua_largo$uf,
    embalagem = unname(embalagens[k]),
    litros    = agua_largo[[paste0("litros_", k)]],
    valor_rs  = agua_largo[[paste0("rs_", k)]]
  )
}) |> bind_rows() |> arrange(ano, uf, embalagem)

# --- validacao ----------------------------------------------------------
stopifnot(
  "bruta: anos fora de 2010..2030"     = all(between(bruta$ano, 2010, 2030)),
  "agua: total nao bate com o largo"   = abs(sum(agua$litros) - sum(
      agua_largo$litros_garrafao, agua_largo$litros_garrafa_plastica,
      agua_largo$litros_garrafa_vidro, agua_largo$litros_copo,
      agua_largo$litros_outras)) < 1,
  "valores negativos apareceram"       = min(bruta$rom_t, na.rm = TRUE) >= 0 &&
                                         min(agua$litros, na.rm = TRUE) >= 0
)

dir.create("dados", showWarnings = FALSE)
write_parquet(bruta,       "dados/producao_bruta.parquet")
write_parquet(beneficiada, "dados/producao_beneficiada.parquet")
write_parquet(agua,        "dados/agua_mineral.parquet")
write_parquet(agua_largo,  "dados/agua_mineral_largo.parquet")
writeLines(SNAP, "dados/SNAPSHOT")

message(sprintf("ok: bruta %d | beneficiada %d | agua %d (long)",
                nrow(bruta), nrow(beneficiada), nrow(agua)))
