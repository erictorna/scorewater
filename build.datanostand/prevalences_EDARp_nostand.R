library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

# Generar taula amb dades de INE
poblacio_barcelona <- read.csv('~idiap/projects/scorewater/poblacio_real_barcelona_2019.csv', sep = '\t')
poblacio_lleida <- read.csv('~idiap/projects/scorewater/poblacio_real_lleida_2019.csv', sep = '\t')
poblacio_girona <- read.csv('~idiap/projects/scorewater/poblacio_real_girona_2019.csv', sep = '\t')
poblacio_tarragona <- read.csv('~idiap/projects/scorewater/poblacio_real_tarragona_2019.csv', sep = '\t')
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

############### EDARS petites ##############################
EDARSpetites <- read.csv('~idiap/projects/scorewater/EDARS_un_municipi.csv', sep = ';')

conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')

EDARSpetites$Codi_municipi = stringr::str_pad(EDARSpetites$Codi_municipi, 6, side = "left", pad = 0)
setDT(EDARSpetites)
setDT(poblacio_total)

codis_municipis = conditions %>% 
  dplyr::select(scensal, municipi)

edarspetites = EDARSpetites %>% 
  dplyr::select(CODI.Sistema, Municipi.EDAR) %>% 
  dplyr::rename(
    municipi = Municipi.EDAR,
    codi_edar = CODI.Sistema
  )
edarspetites = left_join(edarspetites, codis_municipis)

# Llista amb les edars de les que no tenim informacio d'almenys un codi censal que la forma
edars_noinfo <- edarspetites[rowSums(is.na(edarspetites)) > 0,]
edars_noinfo <- edars_noinfo$codi_edar

edarspetites = edarspetites[complete.cases(edarspetites), ]

############ Taula amb EDARs grans #########################

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

edars = left_join(edars, codis_municipis)

# Llista de les edars en que ens falta almenys informacio d'un codi censal que la forma
edars_noinfo2 <- edars[rowSums(is.na(edars)) > 0,]
edars_noinfo <- c(edars_noinfo, edars_noinfo2$codi_edar)
edars_noinfo <- unique(edars_noinfo)

# Ajuntar taula edars petites amb grans
edars = rbind(edars, edarspetites)
edars = edars %>% distinct()
edars$municipi<-NULL

# Agafar nomes les condicions que volem de la taula original
conditions = conditions[conditions$condicio=='Obesity' | conditions$condicio=='Colon cancer' | conditions$condicio=='Thyroid function',]
conditions = conditions %>% 
  group_by(scensal, condicio) %>% 
  summarize_if(is.numeric, sum) %>% 
  dplyr::select(scensal, condicio, casos_prevalents, poblacio_prevalent)

# Taula amb la poblacio real de cada edar
poblacioedars = left_join(edars, poblacio_total)
poblacioedars = poblacioedars %>% 
  group_by(codi_edar) %>% 
  summarize_if(is.numeric, sum)

# Taula amb casos i poblacio prevalent de cada edar
edars = left_join(edars, conditions)
edars[is.na(edars)] <- 0

edarscasos = edars %>% 
  group_by(codi_edar, condicio) %>% 
  summarize_if(is.numeric, sum)

edarspoblacio = edarscasos %>% 
  group_by(codi_edar) %>% 
  summarize_if(is.numeric, max)

edarscasos$poblacio_prevalent<-NULL
edarspoblacio$casos_prevalents<-NULL
edars = left_join(edarscasos, edarspoblacio)

# Afegir la poblacio segons ine

edars = left_join(edars, poblacioedars)

# Calcular percentatge censat i prevalences

edars = edars %>% 
  mutate(
    perc_censat = (poblacio_prevalent/poblacio_real)*100,
    prev = (casos_prevalents/poblacio_prevalent)*100
  )

setDT(edars)
edars = edars[edars$poblacio_prevalent!=0 & edars$casos_prevalents!=0]
conditions = conditions[conditions$condicio=='Obesity' | conditions$condicio=='Colon cancer' | conditions$condicio=='Thyroid function',]
save(edars, edars_noinfo, file = '~idiap/projects/scorewater/build.datanostand/edarsp+g.RData')

