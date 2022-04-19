include make.global

WWW=www/descriptiva_nostand.html www/descriptiva_censal_nostand.html www/EDARp_municipal_nostand.html

DATA=$(BUILD_DATA_NOSTAND)/conditions_municipi_nostand.RData $(BUILD_DATA_NOSTAND)/conditions_municipi_nostand_EDAR.RData $(BUILD_DATA_NOSTAND)/edarsp+g.RData

all: $(DATA) $(WWW) $(BUILD_DATA_NOSTAND)/finished

$(BUILD_DATA_NOSTAND)/conditions_municipi_nostand.RData : $(BUILD_DATA_NOSTAND)/prevalences_nostand.R $(BUILD_DATA)/conditions_municipi.RData $(BUILD_DATA_NOSTAND)/conditions_censal_nostand.RData
	Rscript $<

$(BUILD_DATA_NOSTAND)/conditions_municipi_nostand_EDAR.RData : $(BUILD_DATA_NOSTAND)/prevalences_EDARp_nostand.R $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BUILD_DATA)/conditions_municipi.RData $(BUILD_DATA)/conditions_scensal.RData
	Rscript $<

$(BUILD_DATA_NOSTAND)/barrisbesos.RData : $(BUILD_DATA_NOSTAND)/barrisbesos_nostand.R $(BASE)/demografia_cat_2019.ods $(BUILD_DATA)/conditionsSCOREwater2019.rds $(BASE)/seccions_censal_barris.rds $(BASE)/seccions_censals_besos.rds
	Rscript $<

$(BUILD_DATA_NOSTAND)/edarsp+g.RData : $(BUILD_DATA_NOSTAND)/EDARS_nostand.R $(BASE)/sc_with_edar.csv 
	Rscript $<
	
www/descriptiva_nostand.html : $(BUILD_DATA_NOSTAND)/descriptiva_nostand.html $(BUILD_DATA_NOSTAND)/conditions_municipi_nostand.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'

www/descriptiva_censal_nostand.html : $(BUILD_DATA_NOSTAND)/descriptiva_censal_nostand.html $(BUILD_DATA_NOSTAND)/conditions_censal_nostand.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'

www/EDARp_municipal_nostand.html : $(BUILD_DATA_NOSTAND)/EDARp_municipal_nostand.html $(BUILD_DATA_NOSTAND)/edarsp+g.RData
	Rscript -e 'OUT = "$@"; IN = "$<"; source("$(RMD2HTML)")'
		
$(BUILD_DATA)/finished : $(DATA) $(WWW)
	date > $@
