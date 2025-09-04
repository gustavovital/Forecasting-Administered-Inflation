data_quarter_d <- tibble(date = seq.Date(as.Date("2012-01-01"), floor_date(Sys.Date(), "month"), by = "quarter"))

# Função para diferença com NAs para alinhar tamanho
safe_diff <- function(x, lag = 1) {
  c(rep(NA, lag), diff(x, lag = lag))
}

# Função para gerar coluna de diff e fazer left_join
join_diff <- function(base, serie_df, var_name, lag = 1) {
  diff_col <- serie_df %>%
    arrange(date) %>%
    mutate(!!paste0(var_name) := safe_diff(.data[[var_name]], lag = lag)) %>%
    dplyr::select(date, !!paste0(var_name))
  base %>% left_join(diff_col, by = "date")
}
# Aggregate Inflation	====

# IPCA General Index ====

ipca <- g_series(433, 'ipca') %>%
  dplyr::filter(date >= as.Date('2010-01-01')) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ipca = sum(ipca, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(ipca, by = 'date')

# IPCA - Free Prices	====

ipca_free <- g_series(11428, 'ipca_free') %>%
  dplyr::filter(date >= as.Date('2010-01-01')) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ipca_free = sum(ipca_free, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(ipca_free, by = 'date')

# IPCA - Administered Prices	====

ipca_adm <- g_series(4449, 'ipca_adm') %>%
  dplyr::filter(date >= as.Date('2010-01-01')) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ipca_adm = sum(ipca_adm, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(ipca_adm, by = 'date')

# Key Drivers	====

# BRL/USD Exchange Rate	====

ptax <- g_series(3696, 'ptax') %>%
  dplyr::filter(date >= as.Date('2010-01-01')) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ptax = dplyr::last(ptax),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% join_diff(ptax, 'ptax')

# Brent Crude Oil Price (USD) ====

brent <- fredr(
  series_id = "DCOILBRENTEU",
  observation_start = as.Date("2000-01-01"),
  frequency = "q"
) %>%
  transmute(
    date = floor_date(date, "quarter"),
    brent = value
  )

data_quarter_d <- data_quarter_d %>% join_diff(brent, 'brent')

# CPIAUCSL ====

uscpi <- fredr(
  series_id = "CPIAUCSL",
  observation_start = as.Date("2000-01-01"),
  frequency = "q"
) %>%
  transmute(
    date = floor_date(date, "quarter"),
    uscpi = value
  )

data_quarter_d <- data_quarter_d %>% join_diff(uscpi, 'uscpi')

# Administrated ITENS ====

adm <- sidrar::get_sidra(api = '/t/7060/n1/all/v/63/p/all/c315/7451,7482,7483,7485,7628,7629,7630,7631,7632,7635,7642,7649,7657,7659,7662,7696,7723,7728,7789,47650,47668,107657,107668/d/v63%202')

adm <- adm[, c(5, 10, 13)] # colunas necessarias 

adm <- adm %>% 
  mutate(date = ymd(paste0(`Mês (Código)`, '01')),
         item = str_remove_all(`Geral, grupo, subgrupo, item e subitem`, "[[:punct:][:digit:]]")) %>% 
  mutate(item = stri_trans_general(item, "Latin-ASCII")) %>% 
  dplyr::select(date, item, Valor)

adm <- adm %>%
  pivot_wider(names_from = item, values_from = Valor)

adm <- adm %>% 
  group_by(trimestre = floor_date(date, "quarter")) %>%
  summarise(across(-date, sum, na.rm = TRUE)) %>% 
  mutate(date = trimestre) %>% 
  dplyr::select(-trimestre)

data_quarter_d <- data_quarter_d %>% left_join(adm, by = 'date')


# Dummies and other ====

data_quarter_d$ipca_acum <- zoo::rollapplyr(
  data = data_quarter_d$ipca,
  width = 4,
  FUN = function(x) sum(x, na.rm = FALSE),
  fill = NA
)

data_quarter_d <- data_quarter_d %>% 
  mutate(dummy_Q1 = ifelse(quarter(data_quarter_d$date) == 1, 1, 0)) %>% 
  mutate(dummy_Q2 = ifelse(quarter(data_quarter_d$date) == 2, 1, 0)) %>% 
  mutate(dummy_Q3 = ifelse(quarter(data_quarter_d$date) == 3, 1, 0)) %>% 
  mutate(dummy_Q4 = ifelse(quarter(data_quarter_d$date) == 4, 1, 0))

saveRDS(data_quarter_d, 'data/data_quarter_d_NA.rds')

data_quarter_d$VALOR = 'Actual'


data_quarter_d <- data_quarter_d %>% 
  na.exclude()

saveRDS(data_quarter_d, 'data/data_quarter_d.rds')
