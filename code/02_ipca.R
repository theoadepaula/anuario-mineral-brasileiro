# 02_ipca.R ---------------------------------------------------------------
# Le o snapshot datado do IPCA (BCB/SGS serie 433, variacao mensal %) e grava
# um deflator anual em dados/ipca.parquet.
#
# Por que serie 433 e nao um numero-indice pronto: a 433 e a variacao mensal
# oficial, a partir da qual o indice e reconstruido aqui de forma explicita.
# O leitor pode conferir cada passo sem depender de qual base o IBGE usou.
#
# Por que MEDIA anual do indice, e nao o valor de dezembro: os valores do AMB
# sao FLUXOS acumulados ao longo do ano (venda do ano inteiro), nao estoques
# medidos em 31/12. Deflacionar fluxo pelo indice de dezembro superestima a
# correcao. A media do indice ao longo dos 12 meses e o deflator adequado.

library(dplyr)
library(jsonlite)
library(arrow)

RAIZ <- here::here()

# snapshot mais recente que contenha o arquivo do IPCA
pastas <- list.dirs(file.path(RAIZ, "dados_brutos"), recursive = FALSE)
pastas <- pastas[file.exists(file.path(pastas, "ipca-sgs-433.json"))]
if (!length(pastas)) stop("Nenhum snapshot com ipca-sgs-433.json em dados_brutos/")
snap <- sort(basename(pastas), decreasing = TRUE)[1]
arq  <- file.path(RAIZ, "dados_brutos", snap, "ipca-sgs-433.json")

message("IPCA: lendo snapshot ", snap)

bruto <- fromJSON(arq)

mensal <- bruto |>
  transmute(
    ano = as.integer(substr(data, 7, 10)),
    mes = as.integer(substr(data, 4, 5)),
    var = as.numeric(valor)
  ) |>
  arrange(ano, mes)

# indice encadeado a partir do primeiro mes da serie baixada
mensal$indice <- cumprod(1 + mensal$var / 100)

# so anos completos: um ano parcial daria media enviesada para os meses baixos
completos <- mensal |> count(ano) |> filter(n == 12) |> pull(ano)

ipca <- mensal |>
  filter(ano %in% completos) |>
  group_by(ano) |>
  summarise(indice = mean(indice), .groups = "drop")

stopifnot(
  nrow(ipca) > 10,
  all(diff(ipca$indice) > 0),          # IPCA acumulado nunca cai no periodo
  !any(is.na(ipca$indice))
)

dir.create(file.path(RAIZ, "dados"), showWarnings = FALSE)
write_parquet(ipca, file.path(RAIZ, "dados", "ipca.parquet"))
writeLines(snap, file.path(RAIZ, "dados", "SNAPSHOT_IPCA"))

message("IPCA: ", nrow(ipca), " anos completos (", min(ipca$ano), "-", max(ipca$ano), ")")
