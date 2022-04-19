library(data.table)
library(lubridate)
library(readr)
library(readODS)
library(tidyverse)
library(data.table)
# cataleg <- readRDS('~idiap/data/scorewater/SCOREwater_entregable_cataleg_20220110_164232.rds')
conditions <- readRDS('~idiap/data/scorewater/SCOREwater_entregable_conditions_20220126_121724.rds')
farmacs <- readRDS('~idiap/data/scorewater/SCOREwater_entregable_farmacs_20220126_121724.rds')
groups <- readRDS('~idiap/data/scorewater/SCOREwater_entregable_grups_ICD10MC_20220126_121724.rds')
setwd('/home/idiap/projects/scorewater/build.data/')

setDT(conditions)
conditions$scensal = stringr::str_pad(conditions$scensal, 10, side = "left", pad = 0)
conditions$cm = stringr::str_pad(conditions$cm, 5, side = "left", pad = 0)


setDT(farmacs)
farmacs$scensal = stringr::str_pad(farmacs$scensal, 10, side = "left", pad = 0)
farmacs$cm = stringr::str_pad(farmacs$cm, 5, side = "left", pad = 0)
farmacs[, date := ymd(paste(date, '15'))]



setDT(groups)
groups$scensal = stringr::str_pad(groups$scensal, 10, side = "left", pad = 0)
groups$cm = stringr::str_pad(groups$cm, 5, side = "left", pad = 0)

saveRDS(conditions, file = 'conditionsSCOREwater2019.rds')

saveRDS(farmacs, file = 'farmacsSCOREwater2019.rds')

saveRDS(groups, file = 'groupsSCOREwater2019.rds')

# poblacio_barcelona <- read.csv('~idiap/projects/scorewater/poblacio_real_barcelona_2019.csv', sep = '\t')
# poblacio_lleida <- read.csv('~idiap/projects/scorewater/poblacio_real_lleida_2019.csv', sep = '\t')
# poblacio_girona <- read.csv('~idiap/projects/scorewater/poblacio_real_girona_2019.csv', sep = '\t')
# poblacio_tarragona <- read.csv('~idiap/projects/scorewater/poblacio_real_tarragona_2019.csv', sep = '\t')
# 
# poblacio_total <- rbind(poblacio_barcelona, poblacio_girona, poblacio_lleida, poblacio_tarragona)
# poblacio_total <- poblacio_total[poblacio_total$País.de.nacimiento == 'Total Población', ]
# poblacio_total <- poblacio_total[poblacio_total$Sexo == 'Ambos Sexos', ]
# poblacio_total <- poblacio_total[poblacio_total$Sección != 'TOTAL',]
# poblacio_total$Sexo <- NULL
# poblacio_total$País.de.nacimiento<- NULL
# poblacio_total$Total <- as.numeric(gsub('[[:punct:]]+', '', poblacio_total$Total))
# 
# poblacio_total<-poblacio_total %>%
#   dplyr::rename(
#     scensal = Sección,
#     poblacio_real = Total
#   )
# conditions_ine <- merge(conditions, poblacio_total, by = 'scensal')
# conditions_ine <- conditions_ine[conditions_ine$poblacio_prevalent >= 0, ]
# conditions_ine$perc_censat = (conditions_ine$poblacio_prevalent/conditions_ine$poblacio_real)*100
# conditions = conditions_ine
# 
# groups_ine <- merge(groups, poblacio_total, by = 'scensal')
# groups_ine <- groups_ine[groups_ine$poblacio_prevalent >= 0, ]
# groups_ine$perc_censat = (groups_ine$poblacio_prevalent/groups_ine$poblacio_real)*100
# groups = groups_ine

