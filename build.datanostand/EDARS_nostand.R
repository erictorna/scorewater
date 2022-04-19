library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

edars <- read.csv('~idiap/projects/scorewater/sc_with_edar.csv', sep = ';')

edars <- edars[edars$codi_edar=='DBER' | edars$codi_edar=='DGVC' | edars$codi_edar=='DGRA' |  edars$codi_edar=='DIGU' | edars$codi_edar=='DMAN' | edars$codi_edar=='DMAS' |edars$codi_edar=='DMRT' |edars$codi_edar=='DRSS' |edars$codi_edar=='DLDM' |  edars$codi_edar=='DTRS' | edars$codi_edar=='DSLL' |edars$codi_edar=='DTRP' |  edars$codi_edar=='DCER' |edars$codi_edar=='DBBL' |edars$codi_edar=='DMAT' |edars$codi_edar=='DBAL' |edars$codi_edar=='DVAL' |edars$codi_edar=='DFAL' |edars$codi_edar=='DMLN' |edars$codi_edar=='DAMP' |edars$codi_edar=='DGAN' |edars$codi_edar=='DBSS',]            
edars = edars[complete.cases(edars), ]
edars$codi_sc = stringr::str_pad(edars$codi_sc, 10, side = "left", pad = 0)
setDT(edars)

edars = edars %>% 
  dplyr::select(codi_sc,codi_edar) %>% 
  dplyr::rename(
    scensal = codi_sc
  )
edars$scensal = as.character(edars$scensal)
setwd("/home/idiap/projects/scorewater/build.datanostand")
load('conditions_censal_nostand.RData')

edars = left_join(edars, conditions_gral_censal)

edars = edars %>% 
  group_by(scensal, codi_edar, municipi) %>% 
  summarize_if(is.numeric, max)


# edarsNA <- edars[rowSums(is.na(edars)) > 0,]
edars$perc_censat<-NULL
edars$poblacio_real<-NULL
library(dplyr)
library(data.table)

poblacio_barcelona <- read.csv('~idiap/projects/scorewater/poblacio_real_barcelona_2019.csv', sep = '\t')
poblacio_lleida <- read.csv('~idiap/projects/scorewater/poblacio_real_lleida_2019.csv', sep = '\t')
poblacio_girona <- read.csv('~idiap/projects/scorewater/poblacio_real_girona_2019.csv', sep = '\t')
poblacio_tarragona <- read.csv('~idiap/projects/scorewater/poblacio_real_tarragona_2019.csv', sep = '\t')

# Generar taula amb dades de INE
poblacio_total <- rbind(poblacio_barcelona, poblacio_girona, poblacio_lleida, poblacio_tarragona)
poblacio_total <- poblacio_total[poblacio_total$País.de.nacimiento == 'Total Población', ]
poblacio_total <- poblacio_total[poblacio_total$Sexo == 'Ambos Sexos', ]
poblacio_total <- poblacio_total[poblacio_total$Sección != 'TOTAL',]
poblacio_total$Sexo <- NULL
poblacio_total$País.de.nacimiento<- NULL
poblacio_total$Total <- as.numeric(gsub('[[:punct:]]+', '', poblacio_total$Total))

poblacio_total<-poblacio_total %>%
  dplyr::rename(
    scensal = Sección,
    poblacio_real = Total
  )

edars = left_join(edars, poblacio_total)
edars$municipi<-NULL
edars$prev<-NULL
edars$casos_prevalents<-NULL
edars[is.na(edars)] <- 0
edarstotals = edars %>%
  group_by(codi_edar) %>%
  summarize_if(is.numeric, sum) %>%
  mutate(perc_censat = poblacio_prevalent/poblacio_real)

##################################
edars <- read.csv('~idiap/projects/scorewater/sc_with_edar.csv', sep = ';')

edars <- edars[edars$codi_edar=='DBER' | edars$codi_edar=='DGVC' | edars$codi_edar=='DGRA' |  edars$codi_edar=='DIGU' | edars$codi_edar=='DMAN' | edars$codi_edar=='DMAS' |edars$codi_edar=='DMRT' |edars$codi_edar=='DRSS' |edars$codi_edar=='DLDM' |  edars$codi_edar=='DTRS' | edars$codi_edar=='DSLL' |edars$codi_edar=='DTRP' |  edars$codi_edar=='DCER' |edars$codi_edar=='DBBL' |edars$codi_edar=='DMAT' |edars$codi_edar=='DBAL' |edars$codi_edar=='DVAL' |edars$codi_edar=='DFAL' |edars$codi_edar=='DMLN' |edars$codi_edar=='DAMP' |edars$codi_edar=='DGAN' |edars$codi_edar=='DBSS',]            
edars = edars[complete.cases(edars), ]
edars$codi_sc = stringr::str_pad(edars$codi_sc, 10, side = "left", pad = 0)
setDT(edars)

edars = edars %>% 
  dplyr::select(codi_sc,codi_edar) %>% 
  dplyr::rename(
    scensal = codi_sc
  )
edars$scensal = as.character(edars$scensal)
setwd("/home/idiap/projects/scorewater/build.datanostand")
load('conditions_censal_nostand.RData')

edars = left_join(edars, conditions_gral_censal)

edars = edars %>% 
  dplyr::select(scensal, codi_edar, condicio, casos_prevalents)
edars = edars[complete.cases(edars)]
edars = edars %>% 
  group_by(codi_edar, condicio) %>% 
  summarize_if(is.numeric, sum)
edars = left_join(edars, edarstotals)
edars = edars %>% distinct()
edars = edars[edars$condicio=='Obesity' | edars$condicio=='Colon cancer' | edars$condicio=='Thyroid function',]
save(edars, file = '~idiap/projects/scorewater/build.datanostand/edars_nostand.RData')

