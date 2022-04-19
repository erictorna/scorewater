library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
barris  <- readRDS('~idiap/projects/scorewater/seccions_censals_barris.rds')
besos  <- readRDS('~idiap/projects/scorewater/seccions_censals_besos.rds')
# demography <- read_ods('~idiap/projects/scorewater/demografia_cat_2019.ods')

conditions = conditions[conditions$condicio=='Obesity' | conditions$condicio=='Colon cancer' | conditions$condicio=='Thyroid function',]
conditions = conditions %>% distinct()
conditions<- conditions %>% 
  select(scensal, condicio, sexe, edat, casos_prevalents, poblacio_prevalent)

# mesbesos <- read.csv('~idiap/projects/scorewater/sc_with_edar.csv', sep = ';')
# mesbesos = mesbesos[mesbesos$codi_edar == 'DBSS',]
# mesbesos = mesbesos[complete.cases(mesbesos), ]
# mesbesos$codi_sc = stringr::str_pad(mesbesos$codi_sc, 10, side = "left", pad = 0)

# Barris

barris <- barris %>% 
  dplyr::rename(
    scensal = Sc2020
  ) %>% 
  select(Zona, scensal)
barris = barris %>%  distinct()

barris = merge(conditions, barris)
barris = barris %>% distinct()

casos = barris %>% 
  group_by(Zona, condicio) %>% 
  summarize_if(is.numeric, sum, na.rm = T)


poblacio = casos %>% 
  group_by(Zona) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacio$casos_prevalents<-NULL
casos$poblacio_prevalent<-NULL

barris = left_join(casos, poblacio)

barris$prevalence <- barris$casos_prevalents/barris$poblacio_prevalent

# Besos

besos <- besos %>% 
  dplyr::rename(
    scensal = codi_sc
  ) %>% 
  select(scensal)
besos = besos %>%  distinct()

besos = merge(conditions, besos)
besos = besos %>% distinct()


casos = besos %>% 
  group_by(condicio) %>% 
  summarize_if(is.numeric, sum, na.rm = T)

setDT(casos)
besos <- casos[, poblacio_prevalent:= max(poblacio_prevalent),]


besos$prevalence <- besos$casos_prevalents/besos$poblacio_prevalent

barrisbesos <- rbind(barris, besos)
barrisbesos[is.na(barrisbesos)] <- 'Besos'

setDT(barrisbesos)
z <- qnorm(0.975)
barrisbesos[, `:=`(prev_inf = (prevalence + z^2/(2*poblacio_prevalent) - z*sqrt(prevalence*(1 - prevalence)/poblacio_prevalent + z^2/(4*poblacio_prevalent^2)))/(1 + z^2/poblacio_prevalent),
                   prev_sup = (prevalence + z^2/(2*poblacio_prevalent) + z*sqrt(prevalence*(1 - prevalence)/poblacio_prevalent + z^2/(4*poblacio_prevalent^2)))/(1 + z^2/poblacio_prevalent))]

barrisbesos$prevalence <- round(barrisbesos$prevalence*100, 2)
barrisbesos$prev_inf <- round(barrisbesos$prev_inf*100, 2)
barrisbesos$prev_sup <- round(barrisbesos$prev_sup*100, 2)

standdev = c(0.51, 1.99, 1.05, 0.46, 2.48, 1.17, 0.44, 1.52, 0.49, 0.49, 4.74, 1.29)
barrisbesos$stand_dev = standdev

             
save(barrisbesos, file = '~idiap/projects/scorewater/build.datanostand/barrisbesos.RData')