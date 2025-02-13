** This file links the model results to the tables and figures reported in Feuerbacher (2025)

Parameter
Table2(FAOsubreg_ext,modeltype)         Food budget per FAO sub-region and model setup in billion USD
Table3(FAOsubreg_ext,*,modeltype)       Welfare changes in USD per capita per FAO sub-region and model setup
Table4(cropgroup_ext,modeltype)         %-Price changes per crop-group and modeltype
Table5(FAOsubreg_ext,*,modeltype)       %-changes in Food demand and Vitamin A availability across FAO sub-regions

Figure1(*,modeltype)                    Total welfare change in billions per modeltype
Figure2(*,*,modeltype)                  %-changes in micronutrient availability and food prodction per modeltype
Figure3(*,*,reg,modeltype)              Regional % changes in micro-nutrients and food demand of crop categories    
;


*** Table 2: Food budget per FAO sub-region and model setup
Table2(FAOsubreg,"UnG") = SUM(i,map_i_FAOsubreg(i,FAOsubreg)* foodbudget0(i));
Table2(FAOsubreg,"ModelA") = SUM(i,map_i_FAOsubreg(i,FAOsubreg)* foodbudget0(i));
* Note foodbudget02(i) refers to ModelB scaled 
Table2(FAOsubreg,"ModelB") = SUM(i,map_i_FAOsubreg(i,FAOsubreg)* foodbudget03(i));
Table2(FAOsubreg,"ModelC") = SUM(i,map_i_FAOsubreg(i,FAOsubreg)* foodbudget04(i));
Table2(FAOsubreg,"ModelD") = SUM(i,map_i_FAOsubreg(i,FAOsubreg)* foodbudget05(i));

Table2(FAOsubreg_ext,modeltype)   = Table2(FAOsubreg_ext,modeltype)  / (10**9) ; 
Table2("World",modeltype) = ModelComparison(modeltype,"budget");  
Table2("World","ModelB_scaled") = 0; 

***

*** Table 3: Welfare changes per FAO sub-region and model setup
** Welfare changes in USD per capita across FAO sub-regions resulting from a 100% pollinator decline as reported by the UG study and simulated by model setups A to D 

Table3(FAOsubreg,"Consumer Surplus","ModelA") = WelfareChangeRegion(FAOsubreg,"CSchg","ModelA")* (10**6) / SUM(i,map_i_FAOsubreg(i,FAOsubreg)* FAOpop(i, "2010"));

Table3(FAOsubreg,"Consumer Surplus","ModelB") = WelfareChangeRegion(FAOsubreg,"CSchg","ModelB")* (10**6) / SUM(i,map_i_FAOsubreg(i,FAOsubreg)* FAOpop(i, "2010"));

Table3(FAOsubreg,"Consumer Surplus","ModelC") = WelfareChangeRegion(FAOsubreg,"CSchg","ModelC")* (10**6) / SUM(i,map_i_FAOsubreg(i,FAOsubreg)* FAOpop(i, "2020"));
Table3(FAOsubreg,"Consumer Surplus","ModelD") = WelfareChangeRegion(FAOsubreg,"CSchg","ModelD")* (10**6) / SUM(i,map_i_FAOsubreg(i,FAOsubreg)* FAOpop(i, "2020"));


Table3("World","Consumer Surplus",modeltype)$modelA_D(modeltype) = ModelComparison(modeltype,"CSchg");
Table3("World","Consumer Surplus","ModelA") = Table3("World","Consumer Surplus","ModelA") * (10**9) / SUM(i, FAOpop(i, "2010"));
Table3("World","Consumer Surplus","ModelB") = Table3("World","Consumer Surplus","ModelB") * (10**9) / SUM(i, FAOpop(i, "2010"));
Table3("World","Consumer Surplus","ModelC") = Table3("World","Consumer Surplus","ModelC") * (10**9) / SUM(i, FAOpop(i, "2020"));
Table3("World","Consumer Surplus","ModelD") = Table3("World","Consumer Surplus","ModelD") * (10**9) / SUM(i, FAOpop(i, "2020"));


Table3(FAOsubreg,"Consumer Surplus","UnG") = WelfareChangeRegion(FAOsubreg,"CSchg","UnG");
Table3(FAOsubreg,"Producer Surplus","UnG") = WelfareChangeRegion(FAOsubreg,"PSchg","UnG");
Table3(FAOsubreg,"Net welfare change","UnG") = WelfareChangeRegion(FAOsubreg,"CSchg","UnG") + WelfareChangeRegion(FAOsubreg,"PSchg","UnG");

Table3("World","Consumer Surplus","UnG") = ModelComparison("UnG","CSchg")* (10**9) / SUM(i, FAOpop(i, "2010"));  
Table3("World","Producer Surplus","UnG") = ModelComparison("UnG","PSchg")* (10**9) / SUM(i, FAOpop(i, "2010"));  
Table3("World","Net welfare change","UnG") = ModelComparison("UnG","NWFchg")* (10**9) / SUM(i, FAOpop(i, "2010")); 

***

*** Table 4: Price changes per crop-group and modeltype 
*Table4(cropgroup_ext,modeltype) = SUM(sim, resGlobalCropGroupPrice_avg(cropgroup_ext,sim) * map_sim_modeltype(sim,modeltype));
Table4(cropgroup_ext,modeltype) = SUM(sim, resGlobalCropGroupPrice_wgt(cropgroup_ext,sim) * map_sim_modeltype(sim,modeltype));
*Table4("Allcrops",modeltype) = SUM(sim,resGlobalCropPrice_avg(sim) * map_sim_modeltype(sim,modeltype));
Table4("Allcrops",modeltype) = SUM(sim,resGlobalperc_croptot("World_Market_Price",sim) * map_sim_modeltype(sim,modeltype));

Table4(cropgroup_ext,modeltype) = Table4(cropgroup_ext,modeltype) * 100;

***

*** Table 5: Food demand and Vitamin A changes across FAO sub-regions
Table5(FAOsubreg_ext,"Food Demand",modeltype) = SUM(sim, resTotalFoodDemand_reg_perc(FAOsubreg_ext,sim) * map_sim_modeltype(sim,modeltype));
Table5("World","Food Demand",modeltype)$modelA_D(modeltype) = ModelComparison(modeltype,"FoodDemand") ;
Table5("World","Food Demand","UnG") = ModelComparison("UnG","FoodDemand");

Table5(FAOsubreg_ext,"Vitamin A",modeltype) = SUM(sim, resNutrients_reg_perc(FAOsubreg_ext,"VitA",sim)  * map_sim_modeltype(sim,modeltype));
Table5("World","Vitamin A",modeltype)$modelA_D(modeltype) = ModelComparison(modeltype,"VitA") ;
*Table5("World","Vitamin A","UnG") = ModelComparison("UnG","VitA");

Table5(FAOsubreg_ext,"Food Demand",modeltype) = Table5(FAOsubreg_ext,"Food Demand",modeltype) * 100;
Table5(FAOsubreg_ext,"Vitamin A",modeltype) = Table5(FAOsubreg_ext,"Vitamin A",modeltype) * 100;


****

* Figure 1:  Total welfare change in billions per modeltype
Figure1("ConsumerSurplus",modeltype)$mainmodels(modeltype) = ModelComparison(modeltype,"CSchg");
Figure1("ProducerSurplus",modeltype)$mainmodels(modeltype) = ModelComparison(modeltype,"PSchg");

**

* Figure 2: %-changes in micronutrient availability and food prodction per modeltype

Figure2("Micronutrients",n,modeltype)$mainmodels(modeltype) = ModelComparison(modeltype,n);
** Note there is no information for UnG for production changes
Figure2("Production","CropProduction",modeltype)$mainmodels(modeltype) = ModelComparison(modeltype,"CropProduction");
Figure2("Production","PollCropProduction",modeltype)$mainmodels(modeltype) = ModelComparison(modeltype,"PollCropProduction");
**

* Figure 3: Regional % changes in micro-nutrients and food demand of crop categories 

Figure3("Micronutrients",n,reg,"ModelC") = SUM(sim,resNutrients_macroreg_perc(reg,n,sim) * map_sim_modeltype(sim,"ModelC"))*100;
Figure3("Micronutrients",n,reg,"ModelD") = SUM(sim,resNutrients_macroreg_perc(reg,n,sim) * map_sim_modeltype(sim,"ModelD"))*100;

Figure3("FoodDemand",cropgroup,reg,"ModelC") = SUM(sim,resFoodDemand_macroreg_cropgroup_perc(reg,cropgroup,sim) * map_sim_modeltype(sim,"ModelC"))*100;
Figure3("FoodDemand",cropgroup,reg,"ModelD") = SUM(sim,resFoodDemand_macroreg_cropgroup_perc(reg,cropgroup,sim) * map_sim_modeltype(sim,"ModelD"))*100;

** set entries below 10**-6 equal to 0
Figure3("Micronutrients",n,reg,"ModelC")$(abs(Figure3("Micronutrients",n,reg,"ModelC")) LT 1*10**(-6)) = 0;
Figure3("FoodDemand",cropgroup,reg,"ModelC")$(abs(Figure3("FoodDemand",cropgroup,reg,"ModelC")) LT 1*10**(-6)) = 0;

Figure3("Micronutrients",n,reg,"ModelD")$(abs(Figure3("Micronutrients",n,reg,"ModelD")) LT 1*10**(-6)) = 0;
Figure3("FoodDemand",cropgroup,reg,"ModelD")$(abs(Figure3("FoodDemand",cropgroup,reg,"ModelD")) LT 1*10**(-6)) = 0;

** Unload result parameters to gdx

Execute_unload 'FinalOutputs.gdx',
                Table2
                Table3 
                Table4 
                Table5 
                        
                Figure1 
                Figure2 
                Figure3 
;


** end of final outputs of figures and tables reported in the main text of Feuerbacher (2025): Pollinator Declines, International Trade and Global Food Security: Reassessing the Global Economic and Nutritional Impacts



