parms <- list(
  
  gasolina = list(
    c0 = 0.4,
    c1 = 0.4,
    c2 = 0.2,
    c3 = 1 - 0.4 - 0.4 - 0.2,
    p1 = 0.35,
    p2 = 0.13,
    p4 = 0.11,
    p5 = 0.17,
    p3 = 1 - 0.35 - 0.13 - 0.11 - 0.17
  ),
  
  planoDeSaude = list(
    a = 0.6
  ),
  
  energiaEletrica = list(
    a_itaipu = 0.086,
    a_energia = 0.086,
    c1 = 0.08,
    c2 = 0.4,
    c3 = 0.42,
    c4 = 1 - 0.08 - 0.4 - 0.42,
    c_itaipu_1 = 0.1,
    c_itaipu_2 = 0.35,
    c_itaipu_3 = 0.42,
    c_itaipu_4 = 1 - 0.1 - 0.35 - 0.42
  ),
  
  produtosFarmaceuticos = list(
    c_rep_1 = 0.1,
    c_rep_2 = 0.8,
    c_rep_3 = 0.05,
    c_rep_4 = 1 - 0.1 - 0.8 - 0.05
  ),
  
  aguaEsgoto = list(
    c1 = 0.19,
    c2 = 0.50,
    c3 = 0.09,
    c4 = 1 - 0.19 - 0.50 - 0.09
  ),
  
  gasBotijao = list(
    c0 = 0.0,
    c1 = 0.2,
    c2 = 0.2,
    c3 = 0.2,
    c4 = 0.2,
    c5 = 0.2,
    p1 = 0.32,
    p4 = 0.0,
    p5 = 0.51,
    p3 = 1 - 0.32 - 0.51 - 0.51
  ),
  
  onibusUrbano = list(
    c1 = 0.75,
    c2 = 0.2,
    c3 = 0.05,
    c4 = 1 - 0.75 - 0.2 - 0.05
  ),
  
  onibusIntermunicipal = list(
    c1 = 0.55,
    c2 = 0.14,
    c3 = 0.18,
    c4 = 1 - 0.55 - 0.14 - 0.18
  ),
  
  oleoDiesel = list(
    c0 = 0.3,
    c1 = 0.4,
    c2 = 0.3,
    c3 = 1 - 0.3 - 0.4 - 0.3,
    p1 = 0.468,
    p2 = 0.125,
    p4 = 0.05,
    p5 = 0.184,
    p3 = 1 - 0.468 - 0.125 - 0.05 - 0.184
  ),
  
  taxi = list(
    c1 = 0.48,
    c2 = 0.31,
    c3 = 0.04,
    c4 = 1 - 0.48 - 0.31 - 0.04
  ),
  
  gasEncanado = list(
    beta_1 = 0.55,
    beta_2 = 0.05,
    beta_3 = 0.25
  ),
  
  onibusInterestadual = list(
    c1 = 0.17,
    c2 = 0.02,
    c3 = 0.06,
    c4 = 1 - 0.17 - 0.02 - 0.06
  ),
  
  pedagio = list(
    c1 = 0.22,
    c2 = 0.04,
    c3 = 0.42,
    c4 = 1 - 0.22 - 0.04 - 0.42
  ),
  
  metroTrem = list(
    beta_1 = 0.5,
    beta_2 = 0.1,
    beta_3 = 0.2,
    gamma_1 = 0.1,
    gamma_2 = 0.05,
    gamma_3 = 0.05
  ),
  
  aviao = list(
    c1 = 0.38,
    c2 = 0.58,
    c3 = 0.04,
    c4 = 1 - 0.38 - 0.58 - 0.04
  ),
  
  transporteEscolar = list(
    c1 = 0.17,
    c2 = 0.83,
    c3 = 0,
    c4 = 1 - 0.17 - 0.83 - 0
  )
)