  library(readODS)
  library(data.table)
  library(dplyr)
  library(tibble)
  library(readr)
    
  conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
  #farmacs <- readRDS('~idiap/projects/scorewater/build.data/farmacsSCOREwater2019.rds')
  groups <- readRDS('~idiap/projects/scorewater/build.data/groupsSCOREwater2019.rds')
  demography <- read_ods('~idiap/projects/scorewater/demografia_cat_2019.ods')
    
  # Ajuntar per codi scensal, condicio, provincia i municipi
  conditions <- conditions[conditions$poblacio_prevalent >= 0, ] # Algunes files tenien valors negatius de poblacio prevalent, em decidit treure'ls
  conditions$cm<-NULL
  conditions$ip2011<- NULL
  conditions$casos_incidents<-NULL
  conditions$poblacio_incident<-NULL
  
  casos <- conditions %>% 
    group_by(condicio, provincia, municipi, edat, sexe) %>%
    summarize_if(is.numeric, sum, na.rm = T)
 
  
  poblacio <-casos %>% 
    group_by(provincia, municipi, edat, sexe) %>% 
    summarize_if(is.numeric, max, na.rm = T)
  poblacio$casos_prevalents <- NULL
  casos$poblacio_prevalent<-NULL
  
  conditions_gral <- left_join(casos, poblacio)
# Generar taula amb les poblacions prevalents de cada municipi
  poblaciototal <- conditions %>% 
    group_by(scensal, provincia, municipi, edat, sexe) %>%
    summarize_if(is.numeric, max, na.rm = T)
  poblaciototal <- poblaciototal %>% 
    group_by(provincia, municipi) %>% 
    summarise_if(is.numeric, sum, na.rm = T)
  poblaciototal$provincia <- NULL
  poblaciototal$casos_prevalents <- NULL

  
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
  
  conditions_gral <- merge(poblaciototal, conditions_gral)
  

  
  
  #########################################################################################################################################################
  # Ajuntar per codi scensal, condicio, provincia i municipi
  groups <- groups[groups$poblacio_prevalent >= 0, ] # Algunes files tenien valors negatius de poblacio prevalent, em decidit treure'ls
  groups$cm<-NULL
  groups$ip2011<- NULL
  groups$casos_incidents<-NULL
  groups$poblacio_incident<- NULL
  
  casos <- groups %>% 
    group_by(grup_ICD10MC, subgrup, provincia, municipi, edat, sexe) %>%
    summarize_if(is.numeric, sum, na.rm = T)
  
  
  poblacio <- casos %>% 
    group_by(provincia, municipi, edat, sexe) %>%
    summarize_if(is.numeric, max, na.rm = T)
  poblacio$casos_prevalents <- NULL
  casos$poblacio_prevalent <- NULL
  
  groups_gral <- left_join(casos, poblacio)
  
  # Generar taula amb les poblacions prevalents de cada municipi
  poblaciototal <- groups %>% 
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
  
  setDT(groups_gral)
  onlymales = groups_gral[sexe == 'H', .(grup_ICD10MC, subgrup, sexe, edat, casos_prevalents, 
                                             poblacio_prevalent, provincia, municipi)]
  
  onlyfemales = groups_gral[sexe == 'D', .(grup_ICD10MC, subgrup, sexe, edat, casos_prevalents, 
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
  
  
  groups_gral <- rbind(onlymales, onlyfemales)
  
  
  # Calcul prevalencies (casos prevalents/poblacio prevalent)
  
  groups_gral <- transform(groups_gral, prevalence = casos_prevalents / poblacio_prevalent)
  
  
  # Estandaditzar -> prev * pes
  
  groups_gral <- transform(groups_gral, stand. = prevalence * weights)
  
  groups_gral <- groups_gral %>% 
    group_by(provincia, municipi, grup_ICD10MC, subgrup) %>%
    summarize_if(is.numeric, sum, na.rm = T)
  groups_gral$poblacio_prevalent <- NULL
  groups_gral$weights <- NULL
  groups_gral$prevalence <- NULL
  
  groups_gral <- merge(poblaciototal, groups_gral)
  
  sd(conditions_gral$stand.) # <- 0.04246162 
  
  sd(groups_gral$stand.) # <- 0.04688586
  

  
  ##########################################################
  
load('~idiap/projects/scorewater/build.data/conditions_municipi.RData')
conditions_gral_municipi$provincia <- NULL
conditions_gral_municipi$condicio <- NULL
conditions_gral_municipi$casos_prevalents <- NULL
conditions_gral_municipi$casos_incidents<- NULL
conditions_gral_municipi$poblacio_incident <- NULL
conditions_gral_municipi$poblacio_prevalent <- NULL
conditions_gral <- merge(conditions_gral, conditions_gral_municipi)
conditions_gral = conditions_gral[!duplicated(conditions_gral), ]
conditions_gral$perc_censat <- (conditions_gral$poblacio_prevalent/conditions_gral$poblacio_real)*100

load('~idiap/projects/scorewater/build.data/groups_municipi.RData')
groups_gral_municipi$provincia  <- NULL
groups_gral_municipi$subgrup <- NULL
groups_gral_municipi$casos_prevalents <- NULL
groups_gral_municipi$casos_incidents<- NULL
groups_gral_municipi$poblacio_incident <- NULL
groups_gral_municipi$poblacio_prevalent <- NULL
groups_gral <- merge(groups_gral, groups_gral_municipi)
groups_gral = groups_gral[!duplicated(groups_gral), ]
groups_gral$perc_censat <- (groups_gral$poblacio_prevalent/groups_gral$poblacio_real)*100

save(conditions_gral, file = '~idiap/projects/scorewater/build.data/conditions_standardized.RData')
save(groups_gral, file = '~idiap/projects/scorewater/build.data/groups_standardized.RData')
