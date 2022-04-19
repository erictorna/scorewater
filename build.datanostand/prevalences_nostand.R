library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

conditions <- readRDS('~idiap/projects/scorewater/build.data/conditionsSCOREwater2019.rds')
# groups <- readRDS('~idiap/projects/scorewater/build.data/groupsSCOREwater2019.rds')

conditions <- conditions[conditions$poblacio_prevalent >= 0, ] 
conditions$cm<-NULL
conditions$ip2011<- NULL
conditions$casos_incidents<-NULL
conditions$poblacio_incident<-NULL

# groups <- groups[groups$poblacio_prevalent >= 0, ]
# groups$cm<-NULL
# groups$ip2011<- NULL
# groups$casos_incidents<-NULL
# groups$poblacio_incident<-NULL

# Conditions municipal

casos <- conditions %>% 
  group_by(condicio, provincia, municipi) %>%
  summarize_if(is.numeric, sum, na.rm = T)


poblacio <- casos %>% 
  group_by(provincia, municipi) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacio$casos_prevalents <- NULL
casos$poblacio_prevalent<-NULL

conditions_gral_municipal <- left_join(casos, poblacio)

conditions_gral_municipal$prev <- conditions_gral_municipal$casos_prevalents/conditions_gral_municipal$poblacio_prevalent

# Conditions censal

casos <- conditions %>% 
  group_by(scensal, condicio, provincia, municipi) %>%
  summarize_if(is.numeric, sum, na.rm = T)


poblacio <- casos %>% 
  group_by(scensal, provincia, municipi) %>% 
  summarize_if(is.numeric, max, na.rm = T)
poblacio$casos_prevalents <- NULL
casos$poblacio_prevalent<-NULL

conditions_gral_censal <- left_join(casos, poblacio)

conditions_gral_censal$prev <- conditions_gral_censal$casos_prevalents/conditions_gral_censal$poblacio_prevalent

# Poblacio real INE

load('~idiap/projects/scorewater/build.data/conditions_municipi.RData')
conditions_gral_municipi$provincia <- NULL
conditions_gral_municipi$condicio <- NULL
conditions_gral_municipi$casos_prevalents <- NULL
conditions_gral_municipi$casos_incidents<- NULL
conditions_gral_municipi$poblacio_incident <- NULL
conditions_gral_municipi$poblacio_prevalent <- NULL
conditions_gral_municipal <- merge(conditions_gral_municipal, conditions_gral_municipi)
conditions_gral_municipal = conditions_gral_municipal[!duplicated(conditions_gral_municipal), ]
conditions_gral_municipal$perc_censat <- (conditions_gral_municipal$poblacio_prevalent/conditions_gral_municipal$poblacio_real)*100

load('~idiap/projects/scorewater/build.data/conditions_scensal.RData')
conditions_gral_scensal$provincia <- NULL
conditions_gral_scensal$condicio <- NULL
conditions_gral_scensal$casos_prevalents <- NULL
conditions_gral_scensal$casos_incidents<- NULL
conditions_gral_scensal$poblacio_incident <- NULL
conditions_gral_scensal$poblacio_prevalent <- NULL
conditions_gral_censal <- merge(conditions_gral_censal, conditions_gral_scensal)
conditions_gral_censal = conditions_gral_censal[!duplicated(conditions_gral_censal), ]
conditions_gral_censal$perc_censat <- (conditions_gral_censal$poblacio_prevalent/conditions_gral_censal$poblacio_real)*100

save(conditions_gral_municipal, file = '~idiap/projects/scorewater/build.datanostand/conditions_municipi_nostand.RData')
save(conditions_gral_censal, file = '~idiap/projects/scorewater/build.datanostand/conditions_censal_nostand.RData')


# # Groups municipal
# 
# casos <- groups %>% 
#   group_by(subgrup, provincia, municipi) %>%
#   summarize_if(is.numeric, sum, na.rm = T)
# 
# 
# poblacio <- casos %>% 
#   group_by(provincia, municipi) %>% 
#   summarize_if(is.numeric, max, na.rm = T)
# poblacio$casos_prevalents <- NULL
# casos$poblacio_prevalent<-NULL
# 
# groups_gral_municipal <- left_join(casos, poblacio)
# 
# groups_gral_municipal$prev <- groups_gral_municipal$casos_prevalents/groups_gral_municipal$poblacio_prevalent
# 
# # Groups censal
# 
# casos <- groups %>% 
#   group_by(scensal, subgrup, provincia, municipi) %>%
#   summarize_if(is.numeric, sum, na.rm = T)
# 
# 
# poblacio <- casos %>% 
#   group_by(scensal, provincia, municipi) %>% 
#   summarize_if(is.numeric, max, na.rm = T)
# poblacio$casos_prevalents <- NULL
# casos$poblacio_prevalent<-NULL
# 
# groups_gral_scensal <- left_join(casos, poblacio)
# 
# groups_gral_scensal$prev <- groups_gral_scensal$casos_prevalents/groups_gral_scensal$poblacio_prevalent
