library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

EDARSpetites <- read.csv('~idiap/projects/scorewater/EDARS_un_municipi.csv', sep = ';')

conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
# farmacs <- readRDS('~idiap/projects/scorewater/build.data/farmacsSCOREwater2019.rds')
# groups <- readRDS('~idiap/projects/scorewater/build.data/groupsSCOREwater2019.rds')
demography <- read_ods('~idiap/projects/scorewater/demografia_cat_2019.ods')

EDARSpetites$Codi_municipi = stringr::str_pad(EDARSpetites$Codi_municipi, 6, side = "left", pad = 0)

conditionsEDARpetites <- conditions[conditions$municipi %in% EDARSpetites$Municipi.EDAR,]
# groupsEDARpetites <- groups[groups$municipi %in% EDARSpetites$Municipi.EDAR,]
# farmacsEDARpetites <- farmacs[farmacs$municipi %in% EDARSpetites$Municipi.EDAR,]
# save(farmacsEDARpetites, file = '~idiap/projects/scorewater/build.data/farmacsEDARSp.RData')

# Ajuntar per codi scensal, condicio, provincia i municipi
conditionsEDARpetites <- conditionsEDARpetites[conditionsEDARpetites$poblacio_prevalent >= 0, ] # Algunes files tenien valors negatius de poblacio prevalent, em decidit treure'ls
conditionsEDARpetites$cm<-NULL
conditionsEDARpetites$ip2011<- NULL
conditionsEDARpetites$casos_incidents<-NULL
conditionsEDARpetites$poblacio_incident<- NULL

casos <- conditionsEDARpetites %>% 
  group_by(condicio, provincia, municipi, edat, sexe) %>%
  summarize_if(is.numeric, sum, na.rm = T)


poblacio <- casos %>% 
  group_by(provincia, municipi, edat, sexe) %>%
  summarize_if(is.numeric, sum, na.rm = T)
poblacio$casos_prevalents<- NULL
casos$poblacio_prevalent<- NULL

conditions_gral <- left_join(casos, poblacio)
# Generar taula amb les poblacions prevalents de cada municipi
poblaciototal <- conditionsEDARpetites %>% 
  group_by(scensal, provincia, municipi, edat, sexe) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblaciototal <- poblaciototal %>% 
  group_by(provincia, municipi) %>% 
  summarise_if(is.numeric, sum, na.rm = T)
poblaciototal$provincia <- NULL
poblaciototal$casos_prevalents <- NULL
poblaciototal$casos_incidents <- NULL
poblaciototal$poblacio_incident <- NULL

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

setDT(conditions_gral)
onlymales = conditions_gral[sexe == 'H', .(condicio, sexe, edat, casos_prevalents, 
                                           poblacio_prevalent, provincia, municipi)]

onlyfemales = conditions_gral[sexe == 'D', .(condicio, sexe, edat, casos_prevalents, 
                                             poblacio_prevalent, provincia, municipi)]


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


conditions_gral <- rbind(onlymales, onlyfemales)


# Calcul prevalencies (casos prevalents/poblacio prevalent)

conditions_gral <- transform(conditions_gral, prevalence = casos_prevalents / poblacio_prevalent)


# Estandaditzar -> prev * pes

conditions_gral <- transform(conditions_gral, stand. = prevalence * weights)

conditions_gral <- conditions_gral %>% 
  group_by(provincia, municipi, condicio) %>%
  summarize_if(is.numeric, sum, na.rm = T)
conditions_gral$poblacio_prevalent <- NULL
conditions_gral$weights <- NULL
conditions_gral$prevalence <- NULL

conditions_gral_EDARSp <- merge(poblaciototal, conditions_gral)

load('~idiap/projects/scorewater/build.data/conditions_municipi.RData')
conditions_gral_municipi$provincia <- NULL
conditions_gral_municipi$condicio <- NULL
conditions_gral_municipi$casos_prevalents <- NULL
conditions_gral_municipi$casos_incidents<- NULL
conditions_gral_municipi$poblacio_incident <- NULL
conditions_gral_EDARSp$poblacio_prevalent <- NULL
conditions_gral_EDARSp <- merge(conditions_gral_EDARSp, conditions_gral_municipi)
# conditions_gral_EDARSp = conditions_gral_EDARSp[!duplicated(conditions_gral), ]



save(conditions_gral_EDARSp, file = '~idiap/projects/scorewater/build.data/conditions_standardized_EDARSp.RData')
