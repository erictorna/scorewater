library(readODS)
library(data.table)
library(dplyr)
library(tibble)
library(readr)


edars <- read.csv('seccions_censals_i_edars.csv', sep = ',')

edars$cmun = stringr::str_pad(edars$cmun, 5, side = "left", pad = 0)
edars$dist = stringr::str_pad(edars$dist, 2, side = "left", pad = 0)
edars$secc = stringr::str_pad(edars$secc, 3, side = 'left', pad = 0)

edars = edars %>% mutate(scensal = paste(cmun, dist, secc, sep = '')) %>% select(codi_edar, scensal)

save(edars, file = '~idiap/projects/scorewater/build.data2/edars_scensal.RData')
