library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)
barrisbesos=read_rds("/home/idiap/projects/scorewater/seccions_censals_barris.rds")
farmacs <- readRDS('~idiap/data/scorewater/SCOREwater_entregable_farmacs_20220126_121724.rds')
setDT(farmacs)
setDT(barrisbesos)

farmacs$scensal = stringr::str_pad(farmacs$scensal, 10, side = "left", pad = 0)
farmacs$date = as.character(farmacs$date)
farmacs = farmacs %>% select(scensal, Compound, date, nddd) %>% 
  group_by(scensal, Compound, date) %>% 
  summarize_if(is.numeric, sum)
farmacs$scensal=as.character(farmacs$scensal)

barrisbesos=barrisbesos %>% select(Zona, Sc2020)
names(barrisbesos)[2]<-'scensal'

barrisbesos = left_join(barrisbesos, farmacs)
barrisbesos = barrisbesos[!(is.na(Compound))]

load("/home/idiap/projects/scorewater/build.data2/edars_scensal.RData")
# poblacio=edars %>% select(poblacio, scensal)
# barrisbesos = left_join(barrisbesos, poblacio)
barrisbesos = subset(barrisbesos, (scensal %in% edars$scensal))

barris=barrisbesos %>% group_by(Zona, Compound, date) %>% 
  summarize_if(is.numeric, sum)
# poblacio = barrisbesos %>% group_by(scensal, Zona, date) %>% 
#   summarize_if(is.numeric, max)
# poblacio = poblacio %>% group_by(Zona, date) %>% 
#   summarize_if(is.numeric, sum)
# poblacio$nddd<-NULL
# barris$poblacio<-NULL
# barris=left_join(barris, poblacio)
barris = barris %>% mutate(poblacio=ifelse(Zona == 'Carmel',26499,0))
barris = barris %>% mutate(poblacio=ifelse(Zona == 'Poblenou', 8466, poblacio))
barris = barris %>% mutate(poblacio=ifelse(Zona == 'St. Gervasi', 5577, poblacio))
#################
setDT(edars)
edars = edars[codi_edar=='DBSS']
besos = left_join(edars, farmacs)
besos = besos[!(is.na(Compound))]
besos = besos %>% mutate(nddd=ifelse(is.na(nddd),0,nddd))
besos = besos %>% group_by(codi_edar, Compound, date) %>% 
  summarize_if(is.numeric, sum)
besos = besos %>% mutate(poblacio=1045546)
besos = besos %>% mutate(Zona='Besos')
besos = besos %>% select(Zona, Compound, poblacio, date, nddd)
besos$codi_edar<-NULL

barrisbesos = rbind(barris, besos)
# barrisbesos = barrisbesos %>% mutate(nddd=nddd/12)
save(barrisbesos, file = '~idiap/projects/scorewater/build.data2/barris_farmacs.RData')
write.csv(barrisbesos,"/home/idiap/projects/scorewater/build.data2/farmacsbarris.csv")