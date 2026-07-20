library(tidyverse)
library(arrow)

agua_mineral <- read_parquet('dados/agua_mineral.parquet')

agua_mineral

# Fazendo uma análise exploratória inicial
agua_mineral |>
  select(-valor_rs) |>
  pivot_wider(
    names_from = embalagem,
    values_from = litros
  )

agua_mineral |>
  ggplot(aes(ano, litros, fill = embalagem, group = embalagem)) +
  geom_col()


agua_mineral |>
  count(ano, embalagem, wt = litros) |>
  ggplot(aes(ano, n, color = embalagem, group = embalagem)) +
  geom_line()

# saber como quais uf são os maiores produtores
# ver também por regiões: sul, sudeste, centro-oeste, norte, nordeste
agua_mineral |>
  count(ano, embalagem, uf, wt = litros) |>
  ggplot(aes(ano, n, color = embalagem, group = embalagem)) +
  geom_line() +
  facet_wrap(~uf, ncol = 3)

# saber o valor do litro por uf, depois fazer o nacional,
# ver a inflação no período, e comparar se o valor aumentou ou foi o valor inflacionado.
agua_mineral |>
  filter(
    embalagem %in% c('Garrafa plástica', 'Garrafão')
  ) |>
  mutate(
    valor_por_l = valor_rs / litros
  )

# fazer previsão de água embalada até 2030, usando modelos de previsão temporal
# usar arima, prophet, e demais modelos que achar interessante,
# pode usar o tidymodels ou modeltime
