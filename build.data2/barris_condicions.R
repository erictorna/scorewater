library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)
barrisbesos=read_rds("/home/idiap/projects/scorewater/seccions_censals_barris.rds")

barrisbesos=barrisbesos %>% select(Zona, Sc2020)
names(barrisbesos)[2]<-'scensal'
barrisbesos = barrisbesos %>% distinct()

load('/home/idiap/projects/scorewater/build.datanostand/conditions_censal_nostand.RData')
conditions = conditions_gral_censal %>% select(scensal, condicio, casos_prevalents, poblacio_prevalent, poblacio_real)

# load("/home/idiap/projects/scorewater/build.data2/edars_scensal.RData")
# poblacio=edars %>% select(scensal)

# conditions = subset(conditions, (scensal %in% poblacio$scensal))

# conditions = left_join(conditions, poblacio)

conditions_barris = left_join(barrisbesos, conditions)
setDT(conditions_barris)
conditions_barris=conditions_barris[!(is.na(conditions_barris$condicio))]

poblacio = conditions_barris %>% group_by(Zona, scensal) %>% 
  summarize_if(is.numeric, max)

poblacio = poblacio %>% group_by(Zona) %>% 
  summarize_if(is.numeric, sum) %>% 
  select(Zona, poblacio_prevalent, poblacio_real)

conditions_barris=conditions_barris %>% group_by(Zona, condicio) %>% 
  summarize_if(is.numeric, sum) %>% 
  select(Zona, condicio, casos_prevalents)

conditions_barris=left_join(conditions_barris, poblacio)

conditions_barris=conditions_barris %>% mutate(
  prev = (casos_prevalents/poblacio_prevalent)*100,
  perc_censat = (poblacio_prevalent/poblacio_real)*100
)

save(conditions_barris, file = '~idiap/projects/scorewater/build.data2/conditions_barris.RData')
