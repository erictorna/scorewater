library(tidyverse)
library(data.table)
load("/home/idiap/projects/scorewater/build.data2/edars_condicions.RData")
setDT(edars)

# Eliminem barris de BCN ja que aquests segur que els mostrejem, necessitem seleccionar 17 d'entre les altres
edars<-edars[!(edars$codi_edar=='Poblenou' | edars$codi_edar=='St. Gervasi' | edars$codi_edar=='Carmel')]

# Eliminem EDARS que no tinguin alguna de les 22 condicions
# edars<-edars[!(edars$codi_edar=='DTSE' | edars$codi_edar=='DSOR' | edars$codi_edar=='DFAL' | edars$codi_edar=='DBER' | edars$codi_edar=='DBBL')]

# Agrupem per EDAR i fem mitjana de les prevalencies de totes les condicions
# edars <- edars %>% group_by(codi_edar) %>% 
#   summarize_if(is.numeric,mean)

# Ens quedem només amb les variables que volem agrupar
edars$casos_prevalents<-NULL
edars$poblacio_real<-NULL
edars$perc_censat<-NULL

# Llista de totes les condicions
conditions = c('Alzheimer', 'Arthritis', 'Asthma', 'Atherosclerosis', 'Atrial fibrillation','Bipolar disorder',
               'Breast cancer','Colon cancer','Depression','Diabetes','HIV','Heart failure','IBS/IBD','Kidney diseases',
               'Lung cancer','Mania','Obesity','Psoriasis','Schizophrenia','Schizophrenia disorder','Thyroid cancer','Thyroid function')

# Creem nova taula per fer el clustering posat les condicions com a columnes  
alledars <- edars[, c("codi_edar")]
alledars = distinct(alledars)
for (i in conditions) {
  condicio = edars[condicio==i]
  condicio$condicio<-NULL
  condicio$poblacio_prevalent<-NULL
  names(condicio)[ncol(condicio)] <- paste0(i)
  alledars = left_join(alledars, condicio)
}
setDT(alledars)
# Normalizacio
z <- alledars[,-c(1,1)]
means <- apply(z,2,mean)
sds <- apply(z,2,sd)
nor <- scale(z,center=means,scale=sds)
distance = dist(nor)

# Cluster analysis
mydata.hclust = hclust(distance)
plot(mydata.hclust)
plot(mydata.hclust,labels=alledars$codi_edar,main='Cluster analysis')
plot(mydata.hclust,hang=-1, labels=alledars$codi_edar,main='Cluster analysis')
