library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)

load("/home/idiap/projects/scorewater/build.data2/edars_scensal.RData")

setDT(edars)
edars = edars[complete.cases(edars), ]
edars = edars[!(codi_edar=='' | codi_edar=='D???')]

edars$scensal = as.character(edars$scensal)

load('/home/idiap/projects/scorewater/build.datanostand/conditions_censal_nostand.RData')
# conditions_gral_censal$poblacio_real<-NULL
edars = left_join(edars, conditions_gral_censal)
edars = edars[!(is.na(municipi))]

edars = edars %>% 
  group_by(codi_edar, condicio) %>% 
  summarize_if(is.numeric, sum) %>% 
  select(codi_edar, condicio, casos_prevalents, poblacio_prevalent, poblacio_real)

poblacipoprevalent = edars %>% select(codi_edar, poblacio_prevalent, poblacio_real) %>% 
  group_by(codi_edar) %>% 
  summarize_if(is.numeric, max)

edars$poblacio_prevalent<-NULL
edars$poblacio_real<-NULL
edars = left_join(edars, poblacipoprevalent)

# percentatge = edars %>% 
#   group_by(codi_edar) %>% 
#   summarize_if(is.numeric, max)
# percentatge = percentatge %>% select(codi_edar, poblacio_real)
# 
# edars$perc_censat<-NULL
# edars$poblacio<-NULL
# edars = left_join(edars, percentatge)
setDT(edars)
edars = edars[!(is.na(edars$condicio))]
edars = edars %>% mutate(perc_censat=(poblacio_prevalent/poblacio_real)*100)
edars = edars %>% mutate(prev=(casos_prevalents/poblacio_prevalent)*100)

load("/home/idiap/projects/scorewater/build.data2/conditions_barris.RData")
names(conditions_barris)[1]<-'codi_edar'
edars=rbind(edars, conditions_barris)

save(edars, file = '~idiap/projects/scorewater/build.data2/edars_condicions.RData')
write.csv(edars,"/home/idiap/projects/scorewater/build.data2/condicionsedars.csv")
