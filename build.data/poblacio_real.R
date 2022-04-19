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

# Carregar dades SCOREwater
conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
conditions <- conditions[conditions$poblacio_prevalent >= 1, ] 
conditions$cm<-NULL
conditions$ip2011<- NULL

# Deixar la mateixa poblacio prevalent per cada condicio
conditions_gral <- conditions %>% 
  group_by(scensal, condicio, provincia, municipi) %>%
  summarize_if(is.numeric, sum, na.rm = T)
poblacioprevalent <- conditions_gral %>% 
  group_by(scensal) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacioprevalent$casos_prevalents <- NULL
poblacioprevalent$casos_incidents <- NULL
poblacioprevalent$poblacio_incident <- NULL

# Ajuntar taula INE amb Conditions
poblacio_real <- merge(poblacio_total, poblacioprevalent)
# poblacio_real <- poblacio_real[poblacio_real$poblacio_real >= poblacio_real$poblacio_prevalent,]
conditions_gral$poblacio_prevalent<- NULL
conditions_gral_scensal <- merge(conditions_gral, poblacio_real)
conditions_gral_scensal$perc_censat <- (conditions_gral_scensal$poblacio_prevalent/conditions_gral_scensal$poblacio_real)*100

# Generar taula amb poblacio prevalent per cada munincipi
conditions_gral_municipi <- conditions_gral_scensal %>% 
  group_by(municipi, provincia, condicio) %>% 
  summarize_if(is.numeric, sum, na.rm = T)
poblacio_real_municipi <- conditions_gral_municipi %>% 
  group_by(municipi) %>% 
  summarise_if(is.numeric, max, na.rm = T)
poblacio_real_municipi$casos_prevalents <- NULL
poblacio_real_municipi$casos_incidents <- NULL
poblacio_real_municipi$poblacio_incident <- NULL
# poblacio_real_municipi$poblacio_prevalent <- NULL
poblacio_real_municipi$perc_censat <- NULL

# Ajuntar amb dades INE
conditions_gral_municipi$poblacio_real <- NULL
conditions_gral_municipi$poblacio_prevalent <- NULL
conditions_gral_municipi <- merge(conditions_gral_municipi, poblacio_real_municipi)
conditions_gral_municipi$perc_censat <- (conditions_gral_municipi$poblacio_prevalent/conditions_gral_municipi$poblacio_real)*100
conditions_gral_municipi <- conditions_gral_municipi[, c(1, 2, 3, 4, 5, 6, 9, 8, 7)]
conditions_gral_scensal <- conditions_gral_scensal[, c(1, 2, 3, 4, 5, 6, 7, 9, 8, 10)]

save(conditions_gral_municipi, file = '~idiap/projects/scorewater/build.data/conditions_municipi.RData')
save(conditions_gral_scensal, file = '~idiap/projects/scorewater/build.data/conditions_scensal.RData')

#############################################################################

# Carregar dades SCOREwater
groups <- readRDS('~idiap/projects/scorewater/build.data/groupsSCOREwater2019.rds')
groups <- groups[groups$poblacio_prevalent >= 1, ] 
groups$cm<-NULL
groups$ip2011<- NULL

# Deixar la mateixa poblacio prevalent per cada condicio
groups_gral <- groups %>% 
  group_by(scensal, subgrup, provincia, municipi) %>%
  summarize_if(is.numeric, sum, na.rm = T)
poblacioprevalent <- groups_gral %>% 
  group_by(scensal) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacioprevalent$casos_prevalents <- NULL
poblacioprevalent$casos_incidents <- NULL
poblacioprevalent$poblacio_incident <- NULL

# Ajuntar taula INE amb Conditions
poblacio_real <- merge(poblacio_total, poblacioprevalent)
poblacio_real <- poblacio_real[poblacio_real$poblacio_real >= poblacio_real$poblacio_prevalent,]
groups_gral$poblacio_prevalent<- NULL
groups_gral_scensal <- merge(groups_gral, poblacio_real)
groups_gral_scensal$perc_censat <- (groups_gral_scensal$poblacio_prevalent/groups_gral_scensal$poblacio_real)*100

# Generar taula amb poblacio prevalent per cada munincipi
groups_gral_municipi <- groups_gral_scensal %>% 
  group_by(municipi, provincia, subgrup) %>% 
  summarize_if(is.numeric, sum, na.rm = T)
poblacio_real_municipi <- groups_gral_municipi %>% 
  group_by(municipi) %>% 
  summarise_if(is.numeric, max, na.rm = T)
poblacio_real_municipi$casos_prevalents <- NULL
poblacio_real_municipi$casos_incidents <- NULL
poblacio_real_municipi$poblacio_incident <- NULL
poblacio_real_municipi$perc_censat <- NULL

# Ajuntar amb dades INE
groups_gral_municipi$poblacio_real <- NULL
groups_gral_municipi$poblacio_prevalent <- NULL
groups_gral_municipi <- merge(groups_gral_municipi, poblacio_real_municipi)
groups_gral_municipi$perc_censat <- (groups_gral_municipi$poblacio_prevalent/groups_gral_municipi$poblacio_real)*100
groups_gral_municipi <- groups_gral_municipi[, c(1, 2, 3, 4, 5, 6, 9, 8, 7)]
groups_gral_scensal <- groups_gral_scensal[, c(1, 2, 3, 4, 5, 6, 7, 10, 9, 8)]

save(groups_gral_municipi, file = '~idiap/projects/scorewater/build.data/groups_municipi.RData')
save(groups_gral_scensal, file = '~idiap/projects/scorewater/build.data/groups_scensal.RData')
