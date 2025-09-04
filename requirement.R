library(tidyverse)
library(BETS)
library(sidrar)
library(ipeadatar)
library(rbcb)
library(fredr)
library(stringr)
library(stringi)

source("~/Documents/fred_api.R")

g_series <- function(codigo, nome) {
  get_series(codigo, start_date = "2009-12-01") %>%
    rename(date = date, !!nome := !!sym(as.character(codigo))) %>%
    mutate(date = floor_date(date, "month")) %>%
    arrange(date)
}

create_lags <- function(data, var_name, lags = 4) {
  for (i in 1:lags) {
    data <- data %>%
      mutate(!!paste0(var_name, "_lag", i) := dplyr::lag(!!sym(var_name), i))
  }
  return(data)
}