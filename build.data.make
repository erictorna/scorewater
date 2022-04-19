include make.global

WWW=www/descriptiva_condicions.html www/descriptiva_groups.html www/descriptiva_farmacs.html www/descriptiva_condicions_byscensal.html www/descriptiva_groups_byscensal.html www/descriptiva_farmacs_byscensal.html www/descriptiva_obesity.html www/descriptiva_coloncancer.html www/descriptiva_thyroidfunction.html www/descriptiva_condicions_EDARp.html www/descriptiva_condicions_EDARp_scensal.html

DATA=$(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/conditions_standardized.RData $(BUILD_DATA)/groups_standardized.RData $(BUILD_DATA)/conditions_standardized_byscensal.RData $(BUILD_DATA)/groups_standardized_byscensal.RData $(BUILD_DATA)/conditions_standardized_EDARSp.RData $(BUILD_DATA)/conditions_standardized_EDARSp_scensal.RData

all: $(DATA) $(WWW) $(BUILD_DATA)/finished

$(BUILD_DATA)/conditionsSCOREwater2019.rds : $(BUILD_DATA)/datatreatment.R
	Rscript $<

$(BUILD_DATA)/farmacsSCOREwater2019.rds: $(BUILD_DATA)/conditionsSCOREwater2019.rds
	touch $@

$(BUILD_DATA)/groupsSCOREwater2019.rds: $(BUILD_DATA)/conditionsSCOREwater2019.rds
	touch $@


$(BUILD_DATA)/conditions_standardized.RData : $(BUILD_DATA)/poblacio_real.R $(BUILD_DATA)/standardization.R $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/groupsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods
	Rscript $<

$(BUILD_DATA)/conditions_standardized_EDARSp.RData : $(BUILD_DATA)/poblacio_real.R $(BUILD_DATA)/standardization.R $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/groupsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods $(BASE)/EDARS_un_municipi.csv
	Rscript $<

$(BUILD_DATA)/conditions_standardized_byscensal.RData : $(BUILD_DATA)/poblacio_real.R $(BUILD_DATA)/standardization_byscensal.R $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/groupsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods
	Rscript $<

$(BUILD_DATA)/groups_standardized.RData : $(BUILD_DATA)/poblacio_real.R $(BUILD_DATA)/standardization.R $(BUILD_DATA)/groupsSCOREwater2019.rds $(BUILD_DATA)/groupsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods
	Rscript $<

$(BUILD_DATA)/groups_standardized_byscensal.RData : $(BUILD_DATA)/poblacio_real.R $(BUILD_DATA)/standardization_byscensal.R $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/groupsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods
	Rscript $<

$(BUILD_DATA)/barrisbesos.RData : $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BASE)/demografia_cat_2019.ods $(BUILD_DATA)/seccions_censals_barris.rds $(BUILD_DATA)/seccions_censals_besos.rds
	Rscript $<

www/descriptiva_condicions.html : $(BUILD_DATA)/descriptiva_condicions.html $(BUILD_DATA)/conditions_standardized.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")' 
	
www/descriptiva_condicions_EDARp.html : $(BUILD_DATA)/descriptiva_condicions_EDARp.html $(BUILD_DATA)/conditions_standardized_EDARSp.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'

www/descriptiva_condicions_EDARp_scensal.html : $(BUILD_DATA)/descriptiva_condicions_EDARp_scensal.html $(BUILD_DATA)/conditions_standardized_EDARSp_scensal.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'

www/descriptiva_groups.html : $(BUILD_DATA)/descriptiva_groups.html $(BUILD_DATA)/groups_standardized.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")' 

www/descriptiva_farmacs.html : $(BUILD_DATA)/descriptiva_farmacs.html $(BUILD_DATA)/farmacsSCOREwater2019.rds
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")' 

www/descriptiva_condicions_byscensal.html : $(BUILD_DATA)/descriptiva_condicions_byscensal.html $(BUILD_DATA)/conditions_standardized_byscensal.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")' 

www/descriptiva_groups_byscensal.html : $(BUILD_DATA)/descriptiva_groups_byscensal.html $(BUILD_DATA)/groups_standardized_byscensal.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")' 
	
www/descriptiva_farmacs_byscensal.html : $(BUILD_DATA)/descriptiva_farmacs_byscensal.html $(BUILD_DATA)/farmacsSCOREwater2019.rds
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'

$(BUILD_DATA)/finished : $(DATA) $(WWW)
	date > $@
