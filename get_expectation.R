# get expectations for next month BCB
exp <- 
  get_top5s_monthly_market_expectations('IPCA', start_date = '2009-12-01') %>% 
  filter(typeCalc == 'C')

sum_date <- function(date) {
  return(date %m+% months(12)) 
}

exp <- exp %>%
  mutate(next_year = format(date %m+% months(12), "%m/%Y")) %>%
  filter(next_year == reference_date) %>% 
  group_by(year_base = floor_date(date, "month")) %>% 
  slice_max(date) %>% 
  ungroup() %>% 
  dplyr::select(date, exp = mean) %>% 
  mutate(date = floor_date(date, 'month'))


