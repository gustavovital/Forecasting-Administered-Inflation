# Estimation MCI ====
rm(list = ls())
library(mFilter)
library(lmtest)
library(sandwich)
library(vars)
library(svars)


data_MCI <- readRDS('data/data_quarter_d.rds') %>% 
  drop_na()

y_gap <- hpfilter(data_MCI$pib, freq = 1600)$cycle

data_MCI$y_gap <- y_gap

# Hiato do câmbio nominal
data_MCI$ptax_gap <- hpfilter(data_MCI$ptax, freq = 1600)$cycle

# Estimações ====

# Curva IS
is_eq <- lm(y_gap ~ lag(y_gap, 1) + lag(y_gap, 2) + r, data = data_MCI)
# is_eq <- lm(y_gap ~  lag(y_gap, 2) + r, data = data_MCI)
# is_eq <- lm(y_gap ~  lag(y_gap, 2) + lag(r, 1), data = data_MCI)
is_eq <- lm(y_gap ~  0 + lag(y_gap, 2) + lag(r, 1) + lag(r, 4), data = data_MCI)
summary(is_eq)

coeftest(is_eq, vcov = NeweyWest(is_eq, lag = 4))

# Curva de Phillips
phillips_eq <- lm(p_livre ~ exp + lag(y_gap, 3) + ptax_gap, data = data_MCI)
phillips_eq <- lm(p_livre ~ 0 + exp + y_gap + lag(ptax_gap, 2), data = data_MCI)
summary(phillips_eq)

coeftest(phillips_eq, vcov = NeweyWest(phillips_eq, lag = 4))
# Regra de Taylor
taylor_eq <- lm(i ~ exp + y_gap + lag(i, 1), data = data_MCI)
taylor_eq <- lm(i ~ 0 + lag(exp, 3) + lag(y_gap, 1) + lag(i, 3), data = data_MCI)
summary(taylor_eq)

coeftest(taylor_eq, vcov = NeweyWest(taylor_eq, lag = 4))

# VARS models ====
var_model <- VAR(data_MCI[, c("y_gap","p_livre","i")],
                 p = 2, type = "const",
                 exogen = data_MCI[, c("exp","ptax_gap")])

amat <- matrix(c(
  1,   0,   0,
  NA,  1,   0,
  0,  NA,  1
), nrow = 3, byrow = TRUE)

svar <- SVAR(var_model, Amat = amat, estmethod = "direct")

