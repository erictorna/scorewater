library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
barris  <- readRDS('~idiap/projects/scorewater/seccions_censals_barris.rds')
besos  <- readRDS('~idiap/projects/scorewater/seccions_censals_besos.rds')
demography <- read_ods('~idiap/projects/scorewater/demografia_cat_2019.ods')

conditions = conditions[conditions$condicio=='Obesity' | conditions$condicio=='Colon cancer' | conditions$condicio=='Thyroid function',]
conditions = conditions %>% distinct()
conditions<- conditions %>% 
  select(scensal, condicio, sexe, edat, casos_prevalents, poblacio_prevalent)
barris <- barris %>% 
  dplyr::rename(
    scensal = Sc2020
  ) %>% 
  select(Zona, scensal)
barris = barris %>%  distinct()

barris = merge(conditions, barris)
barris = barris %>% distinct()


casos = barris %>% 
  group_by(Zona, condicio, sexe, edat) %>% 
  summarize_if(is.numeric, sum, na.rm = T)


poblacio = casos %>% 
  group_by(Zona, sexe, edat) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacio$casos_prevalents<-NULL
casos$poblacio_prevalent<-NULL

barris = left_join(casos, poblacio)

barris$prevalence <- barris$casos_prevalents/barris$poblacio_prevalent

# Càlcul pes
maleweight <- c()
count = 1

while (count <= 17) {
  pes = as.numeric(demography[count + 2, 5]) / as.numeric(demography[20,8]) 
  maleweight <- c(maleweight, pes)
  count = count + 1
}

femaleweight <- c()
count = 1

while (count <= 17) {
  pes = as.numeric(demography[count + 2, 6]) / as.numeric(demography[20,8]) 
  femaleweight <- c(femaleweight, pes)
  count = count + 1
}

edat <- c('0-5', '5-10', '10-15', '15-20', '20-25', '25-30', '30-35', '35-40', '40-45','45-50', '50-55','55-60', '60-65','65-70', '70-75', '75-80', '80+')

maletable = data.frame(edat, maleweight)
femaletable = data.frame(edat, femaleweight)

setDT(barris)
onlymales = barris[sexe == 'H', .(Zona, condicio, sexe, edat, casos_prevalents, 
                                       poblacio_prevalent, prevalence)]

onlyfemales = barris[sexe == 'D', .(Zona, condicio, sexe, edat, casos_prevalents, 
                                         poblacio_prevalent, prevalence)]


onlymales = merge(onlymales, maletable, by = 'edat')


onlyfemales = merge(onlyfemales, femaletable, by = 'edat')

onlymales = onlymales %>% 
  dplyr::rename(
    weights = maleweight
  )


onlyfemales = onlyfemales %>% 
  dplyr::rename(
    weights = femaleweight
  )


barris <- rbind(onlymales, onlyfemales)
barris$prev <- barris$prevalence*barris$weights
barris = barris %>% 
  group_by(Zona, condicio) %>% 
  summarize_if(is.numeric, sum, na.rm = T)
barris$poblacio_prevalent[barris$Zona == 'Carmel'] <- 26488
barris$poblacio_prevalent[barris$Zona == 'Poblenou'] <- 8372
barris$poblacio_prevalent[barris$Zona == 'St. Gervasi'] <- 5265

#################################################################################33

besos <- besos %>% 
  dplyr::rename(
    scensal = codi_sc
  ) %>% 
  select(scensal)
besos = besos %>%  distinct()

besos = merge(conditions, besos)
besos = besos %>% distinct()


casos = besos %>% 
  group_by(condicio, sexe, edat) %>% 
  summarize_if(is.numeric, sum, na.rm = T)


poblacio = casos %>% 
  group_by(sexe, edat) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacio$casos_prevalents<-NULL
casos$poblacio_prevalent<-NULL

besos = left_join(casos, poblacio)

besos$prevalence <- besos$casos_prevalents/besos$poblacio_prevalent

setDT(besos)
onlymales = besos[sexe == 'H', .(condicio, sexe, edat, casos_prevalents, 
                                  poblacio_prevalent, prevalence)]

onlyfemales = besos[sexe == 'D', .(condicio, sexe, edat, casos_prevalents, 
                                    poblacio_prevalent, prevalence)]


onlymales = merge(onlymales, maletable, by = 'edat')


onlyfemales = merge(onlyfemales, femaletable, by = 'edat')

onlymales = onlymales %>% 
  dplyr::rename(
    weights = maleweight
  )


onlyfemales = onlyfemales %>% 
  dplyr::rename(
    weights = femaleweight
  )
besos <- rbind(onlymales, onlyfemales)
besos$prev <- besos$prevalence*besos$weights
besos = besos %>% 
  group_by(condicio) %>% 
  summarize_if(is.numeric, sum, na.rm = T)
barrisbesos = rbind(barris, besos)
barrisbesos[is.na(barrisbesos)] <- 'Besos'
barrisbesos$poblacio_prevalent[barrisbesos$Zona == 'Besos'] <- 943790
barrisbesos$casos_prevalents<-NULL
barrisbesos$prevalence<-NULL
barrisbesos$weights<-NULL

setDT(barrisbesos)
z <- qnorm(0.975)
barrisbesos[, `:=`(prev_inf = (prev + z^2/(2*poblacio_prevalent) - z*sqrt(prev*(1 - prev)/poblacio_prevalent + z^2/(4*poblacio_prevalent^2)))/(1 + z^2/poblacio_prevalent),
                   prev_sup = (prev + z^2/(2*poblacio_prevalent) + z*sqrt(prev*(1 - prev)/poblacio_prevalent + z^2/(4*poblacio_prevalent^2)))/(1 + z^2/poblacio_prevalent))]
barrisbesos$prev <- round(barrisbesos$prev*100, 2)
barrisbesos$prev_inf <- round(barrisbesos$prev_inf*100, 2)
barrisbesos$prev_sup <- round(barrisbesos$prev_sup*100, 2)

barrisbesos = barrisbesos %>% 
  dplyr::rename(
    prevalence = prev
  )
save(barrisbesos, file = '~idiap/projects/scorewater/build.data/barrisbesos.RData')
