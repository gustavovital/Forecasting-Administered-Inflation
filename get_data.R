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

# ..............................................................................
# GET DATA ====
# ..............................................................................
# Free Prices ====
p_livre <- g_series(11428, 'p_livre') %>%
  dplyr::filter(date >= as.Date('2010-01-01')) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    p_livre = sum(p_livre, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(p_livre, by='date')

# PIB ====
pib <- g_series(29609, 'pib')  %>% 
  mutate(pib = (pib / lag(pib, 1) - 1) * 100) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    pib = sum(pib, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(pib, by='date')

# NUCI ====
nuci <- g_series(28561, 'nuci') %>%
  dplyr::filter(date >= as.Date('2007-01-01')) %>%
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    nuci = sum(nuci, na.rm = TRUE),
    .groups = "drop") 

data_quarter_d <- data_quarter_d %>% join_diff(nuci, 'nuci')

# desemprego ====
u <- get_u()

data_quarter_d <- data_quarter_d %>% join_diff(u, 'u')

# emprego formal ====
# e <- sidrar::get_sidra(
#   api = "/t/6466/n1/all/v/4097/p/all/d/v4097%201"
# ) %>%
#   dplyr::select(data = "Trimestre (Código)", e = "Valor") %>%
#   mutate(date = ym(data)) %>%
#   dplyr::select(date, e) %>%
#   arrange(date)

e <- g_series(28763, 'e') %>%
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    e = sum(e, na.rm = TRUE),
    .groups = "drop") 

data_quarter_d <- data_quarter_d %>% join_diff(e, 'e')

# selic ====
i <- ipeadatar::ipeadata("BM12_TJOVER12") %>%
  dplyr::select(date, i = value) %>%
  arrange(date) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    i = sum(i, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(i, by='date')

# expectativas ====

source('get_expectation.R')
exp <- exp %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    exp = sum(exp, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% left_join(exp, by='date')

# juros real ====
r <- tibble(date = i$date,
            r = i$i - exp$exp) 

data_quarter_d <- data_quarter_d %>% left_join(r, by= 'date') 

# r <- r %>% 
#   mutate(r = i - exp) %>% 
#   dplyr::select(date, r) %>% 
#   na.omit()
# 
# data_quarter_d <- data_quarter_d %>%  join_diff(r, 'r')

# ptax ====
ptax <- g_series(3696, 'ptax') %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ptax = sum(ptax, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% join_diff(ptax, 'ptax')

# juros externo ====
tb3ms <- fredr(
  series_id = "TB3MS",
  observation_start = as.Date("2000-01-01"),
  frequency = "m"
) %>%
  transmute(
    date = floor_date(date, "month"),
    tb3ms = value
  )

data_quarter_d <- data_quarter_d %>% join_diff(tb3ms, 'tb3ms')

# ppi ====
ppiaco <- fredr_series_observations(
  series_id         = "PPIACO",
  observation_start = as.Date("2009-12-01"),
  frequency         = "m"
) %>%
  transmute(
    date  = floor_date(date, "month"),
    ppiaco = value
  ) %>%
  filter(date >= as.Date("2009-12-01")) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    ppiaco = sum(ppiaco, na.rm = TRUE),
    .groups = "drop"
  )

data_quarter_d <- data_quarter_d %>% join_diff(ppiaco, 'ppiaco')

# risco ====
us3m <- fredr_series_observations(
  series_id         = "TB3MS",
  observation_start = as.Date("2010-01-01"),
  frequency         = "m"
) %>%
  transmute(
    date = floor_date(date, "month"),
    us3m = value
  ) %>%
  group_by(date) %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    us3m = sum(us3m, na.rm = TRUE),
    .groups = "drop"
  )

risco <- i %>%
  left_join(us3m, by = "date") %>%
  mutate(embi = (i - us3m) * 100) %>%
  dplyr::select(date, embi) %>% 
  na.exclude()

data_quarter_d <- data_quarter_d %>% left_join(risco, by='date')

# IC-BR ====
icbr <- g_series(27574, 'icbr') %>% 
  mutate(date = floor_date(date, unit = "quarter")) %>%
  group_by(date) %>%
  summarise(
    icbr = sum(icbr, na.rm = TRUE),
    .groups = "drop"
  ) 

data_quarter_d <- data_quarter_d %>% join_diff(icbr, 'icbr')

saveRDS(data_quarter_d, 'data/data_quarter_d.rds')
