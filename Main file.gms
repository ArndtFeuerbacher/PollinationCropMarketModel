** Model Code underlyign the results of Feuerbacher (2025) - Pollinator Declines, International Trade and Global Food Security: Reassessing the Global Economic and Nutritional Impacts
** Version: February, 2025 - Mansuscript accepted with minor revisions by Ecological Economics


*** This code replicates the study of Uwingabire and Gallai, 2024 in Ecological Economics ***

*** Code developed by Arndt Feuerbacher, University of Hohenheim, Research Group Ecological-Economic Policy Modelling ***

** Note: FinalOutputs.gms reports 
*** Define sets (indices) used in the later model

** Load model sets
$Include Model_sets.inc

Parameter
FAOprod(i,k,year)                                   Production in tons per subregion for 2022 2020 and 2010 according to FAO
FAOprices(c,k,year)                                 Producer prices in USD per ton and country for 2022 2020 and 2010 according to FAO
FAOexport_allitems(i,j,year)                        Exports per ton and subregion for 2022 2020 and 2010 according to FAO
FAOimport_allitems(i,j,year)                        Imports per ton and subregion for 2022 2020 and 2010 according to FAO
FAOtradeqty(i,flow,j,year)                          Trade flow (export or import) per ton and subregion for 2022 2020 and 2010 according to FAO
FAOpop(i, year)                                     Population of FAO subregions for 2010 and 2020 (2022 was not available) 
FAOsubregpop(FAOsubreg,i, year)                     Population of FAO subregions for 2010 and 2020 (2022 was not available) 

SubRegPop(i)                                        Populations in sub-regions in year1 (set above)

depratios(k,authors,intens)                  Dependence ratios for FAO food items according to Klein et al (2007) and Siopa et al. (2024)

** Conversion matrix is based on FAO, nd. Technical Conversion Factors for Agricultural Commodities. Rome, Italy. https://www.fao.org/fileadmin/templates/ess/documents/methodology/tcf.pdf
conversionmatrix(k,j)                               Conversion matrix to convert food items j to raw equivalents in food items k

** Nutrition matrix is based on Chaplin-Kramer et al. 2014 -  per 100g or international unit (for Vitamin A)
nutritionmatrix(k,n)                                Nutrition content of edible crops 

* Base Food and Nutrient Intake for Model Year 2010

BaseFoodIntake_pc(FAOsubreg,modeltype, cropgroup)   Base Food Intake in kg per crop croup' year and capita - by model type
BaseTotalFoodIntake_pc(FAOsubreg,modeltype)         Base Food Intake in kg per crop croup' year and capita - by model type
BaseNutrientIntake_pc(FAOsubreg,modeltype, n)       Base Nutrient Intake (in 1000 IU for Vit A' gramms for VitC' VitB6' Folate and Iron and in kg for Protein) per year and capita - by model type

** Data from the UG study

Uwingabire_study(i,table4_UnG)                          Data extracted from Uwingabire and Gallai (UG) study - per region i
Uwingabire_study2(FAOsubreg,i,table4_UnG)               Data extracted from Uwingabire and Gallai (UG) study - per region i

WelfareUnG_subreg(i,table4_UnG)                         Welfare changes in billion USD as reported by UG    
WelfareUnG_global(table4_UnG)                           Global welfare changes in billion USD as reported by UG


count_prices(c,k,year)                              Parameter that counts the number of price records per country and year 
numb_obs(k,year)                                    Number of edible crops (observations) per year
avgFAOprices(k,year)                                Average producer price according to FAOstat

FAOexport(i,k,year)                                 Exports in raw-equivalents per ton and subregion for 2022 2020 and 2010 according to FAO
FAOimport(i,k,year)                                 Imports in raw-equivalents per ton and subregion for 2022 2020 and 2010 according to FAO

global_exports_beforescaling(k,year)                Global Exports - before scaling
global_imports_beforescaling(k,year)                GLobal Imports - before scaling
net_trade_beforescaling(k,year)                     Net trade - before scaling

global_avgtrade_beforescaling(k,year)               Global average of exports and imports - before scaling
global_exports(k,year)                              Global exports - after scaling
global_imports(k,year)                              Global imports - after scaling

global_avgtrade(k,year)                             Global average of exports and imports 
net_trade(k,year)                                   GLobal total exports minus total imports => should equal zero

shr_trade_difference(k,year)                        Difference between global exports and imports as a share 
shr_trade_difference_withdep(k,year)                Difference between global exports and imports as a share - for pollination dependent crops       

import_scaling_factor(u,k,year)                     Scaling factor to converge total global imports 
export_scaling_factor(u,k,year)                     Scaling factor to converge total global exports

FAOdemand(i,k,year)                                 Demand for edible crops in raw-equivalents
count_expGTprod(year)                               Total number of crops for which demand exceeds supply (production)

one(i,k,year)                                       Parameter = 1

FAOdemand_belowzero(i,k,year)                       Records negative demand data entries
FAOdemand_belowzero_depratiolt0(i,k,year)           ecords negative demand data entries for pollination dependent crops            
BreakLoop                                           Value is equal zero if all countries export less than they produce
AbbortIfDemandBelowZero                             Parameter to abort the model if demand is negative

count_expGTprod_per_iter(year,u)                    Count cases in which exports exceed production
iteration(u)                                        Parameter to count interations
TotalIteration                                      Count total iterations
;


** Activate the "connect code" below if the code is run for the first time


$ontext
$onEmbeddedCode Connect:
- ExcelReader:
    file: datainput.xlsx
    symbols:
      - name: ConversionMatrix
        range: conversion_matrix!A1
        rowDimension: 1
        columnDimension: 1
      - name: nutritionmatrix
        range: NutrientContent!A4
        rowDimension: 1
        columnDimension: 1
      - name: FAOprices
        range: FAOprices!A1
        rowDimension: 3
        columnDimension: 0
      - name: FAOprod
        range: FAOprod!A1
        rowDimension: 3
        columnDimension: 0
      - name: FAOexport_allitems
        range: FAOexport!A1
        rowDimension: 3
        columnDimension: 0
      - name: FAOimport_allitems
        range: FAOimport!A1
        rowDimension: 3
        columnDimension: 0
      - name: depratios
        range: DepRatios!C3
        rowDimension: 1
        columnDimension: 2      
      - name: FAOpop
        range: FAOpop!B1
        rowDimension: 2
        columnDimension: 0
      - name: Uwingabire_study
        range: Uwingabire_study!B1
        rowDimension: 1
        columnDimension: 1      
- GAMSWriter:
    domainCheckType: checked
$offEmbeddedCode



$gdxOut replication_data.gdx
$unload ConversionMatrix FAOprices FAOprod FAOexport_allitems FAOimport_allitems nutritionmatrix FAOpop Uwingabire_study depratios
$gdxOut

** Important: if connect code above is run, do stop here - then comment out the connect above (deactivate $ontext and $offtext) and re-run the whole file without the stop command and the GAMS connect code above (re-activate the $ontext)
$stop
$offtext
** to accelerate the run time - the parameters loaded from xlsx are stored as gdx files that can be loaded more quickly.
** The gdx file is provided with the supplementary data, but if the excel file is updated then the above Connect code - if commented out - needs to be again included.
$gdxIn replication_data.gdx
$loadDC ConversionMatrix FAOprices FAOprod FAOexport_allitems FAOimport_allitems DepRatios nutritionmatrix FAOpop Uwingabire_study 


FAOsubregpop(FAOsubreg,i, year)  = map_i_FAOsubreg(i,FAOsubreg) * FAOpop(i,year);

Uwingabire_study2(FAOsubreg,i,table4_UnG) = Uwingabire_study(i,table4_UnG) * map_i_FAOsubreg(i,FAOsubreg);

Uwingabire_study2(FAOsubreg,i,"NWFchg") = Uwingabire_study2(FAOsubreg,i,"CSchg")  + Uwingabire_study2(FAOsubreg,i,"PSchg") ;

WelfareUnG_subreg(i,"CSchg") = FAOpop(i,"2010") * Uwingabire_study(i,"CSchg")/10**9;
WelfareUnG_subreg(i,"PSchg") = FAOpop(i,"2010") * Uwingabire_study(i,"PSchg")/10**9;

WelfareUnG_global("CSchg") = SUM(i,WelfareUnG_subreg(i,"CSchg"));
WelfareUnG_global("PSchg") = SUM(i,WelfareUnG_subreg(i,"PSchg"));

count_prices(c,k,year)$FAOprices(c,k, year) = 1;
numb_obs(k,year) = SUM(c,count_prices(c,k,year));

** calculate average global FAO prices 
avgFAOprices(k,year)$numb_obs(k,year) = SUM(c,FAOprices(c,k, year) ) / numb_obs(k,year);

*** Clean Trade and Demand Data ***

** Convert trade data into raw equivalents => so far only for pollination dependent items (other items do not experience a change in prices..)
FAOexport(i,k,year) = SUM(j, conversionmatrix(k,j)*FAOexport_allitems(i,j,year));
FAOimport(i,k,year) = SUM(j, conversionmatrix(k,j)*FAOimport_allitems(i,j,year));

Alias (u,up);

one(i,k,year)$FAOimport(i,k,year) = 1;

count_expGTprod(year) = SUM((i,k)$(FAOexport(i,k,year) GT FAOprod(i,k,year)), one(i,k,year));

** FAOdemand before cleaning - so far is only coded for the year 2010
SubRegPop(i)  = FAOpop(i, "2010") ;

FAOdemand(i,k,year) = FAOprod(i,k,year) + FAOimport(i,k,year) - FAOexport(i,k,year) ;

BaseFoodIntake_pc(FAOsubreg,"BaseDataBC", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        FAOdemand(i,k,"2010") * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));


BaseFoodIntake_pc(FAOsubreg,"BaseDataBC", cropgroup)$(SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i))) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        FAOdemand(i,k,"2010") * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                        
BaseTotalFoodIntake_pc(FAOsubreg,"BaseDataBC") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),FAOdemand(i,k,"2010") * 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
 
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**3) and protein in kg
                                                                                                    
BaseNutrientIntake_pc(FAOsubreg,"BaseDataBC", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * FAOdemand(i,k,"2010")*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
 
** Micronesia Data is weird - consider replacing production and trade data as in Polynesia adjusted for Population


** Adjust trade to match global total exports and imports and to adjust negative demand
** Loop is needed to re-run the consistency estimation of trade-data
Loop(u,

** Simple rule: If exports exceed production then limit them to 99% of production
FAOexport(i,k,year)$(FAOexport(i,k,year) > (FAOprod(i,k,year))) = 0.99 * FAOprod(i,k,year);

global_exports_beforescaling(k,year)  = SUM(i,FAOexport(i,k,year));
global_imports_beforescaling(k,year)  = SUM(i,FAOimport(i,k,year));

* Set imports/exports equal zero if only one of each is globally recorded
FAOimport(i,k,year)$(global_exports_beforescaling(k,year) EQ 0) = 0;
FAOexport(i,k,year)$(global_imports_beforescaling(k,year) EQ 0) = 0;

global_exports_beforescaling(k,year)  = SUM(i,FAOexport(i,k,year));
global_imports_beforescaling(k,year)  = SUM(i,FAOimport(i,k,year));

net_trade_beforescaling(k,year)       = global_exports_beforescaling(k,year) - global_imports_beforescaling(k,year);

shr_trade_difference(k,year)$net_trade_beforescaling(k,year) = abs(net_trade_beforescaling(k,year)  / ((global_exports_beforescaling(k,year)  + global_imports_beforescaling(k,year))/2));
shr_trade_difference_withdep(k,year)$(depratios(k,"Klein","mean")) = shr_trade_difference(k,year);
  
** separate scaling factors to scale exports and imports equal to the average of global total imports/exports
   
global_avgtrade_beforescaling(k,year) = (global_imports_beforescaling(k,year)+global_exports_beforescaling(k,year))/2;
             
import_scaling_factor(u,k,year)$global_avgtrade_beforescaling(k,year)   = global_imports_beforescaling(k,year)/global_avgtrade_beforescaling(k,year);
export_scaling_factor(u,k,year)$global_avgtrade_beforescaling(k,year)  = global_exports_beforescaling(k,year)/global_avgtrade_beforescaling(k,year);

** scale trade data
FAOexport(i,k,year)$ export_scaling_factor(u,k,year) = FAOexport(i,k,year) / export_scaling_factor(u,k,year);
FAOimport(i,k,year)$ import_scaling_factor(u,k,year) = FAOimport(i,k,year) / import_scaling_factor(u,k,year);

global_exports(k,year)  = SUM(i,FAOexport(i,k,year));
global_imports(k,year)  = SUM(i,FAOimport(i,k,year));

global_avgtrade(k,year) = (global_imports(k,year)+global_exports(k,year))/2;
    

** net trade now should be equal zero for all items and years
net_trade(k,year)       = abs(global_exports(k,year) - global_imports(k,year));

*added
** again count cases in which more is exported than produced
count_expGTprod_per_iter(year,u) = SUM((i,k)$(FAOexport(i,k,year) GT FAOprod(i,k,year)), one(i,k,year));

BreakLoop = SUM(year,SUM((i,k)$(FAOexport(i,k,year) GT FAOprod(i,k,year)), one(i,k,year)));

iteration(u) = 1;

TotalIteration = SUM(up, iteration(up)) ;

IF(BreakLoop EQ 0, Break);
*

* end of loop needed to smooth out negative demand
);

** again count cases in which more is exported than produced
count_expGTprod(year) = SUM((i,k)$(FAOexport(i,k,year) GT FAOprod(i,k,year)), one(i,k,year));

** Simple rule: If exports exceed production then limit them to 90% of production
*FAOexport(i,k,year)$(FAOexport(i,k,year) > (FAOprod(i,k,year))) = 0.9 * FAOprod(i,k,year);

FAOdemand(i,k,year) = FAOprod(i,k,year) + FAOimport(i,k,year) - FAOexport(i,k,year) ;

BaseFoodIntake_pc(FAOsubreg,"BaseDataAC", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        FAOdemand(i,k,"2010") * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"BaseDataAC") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),FAOdemand(i,k,"2010") * 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**3) and protein in kg
                                                                                                    
BaseNutrientIntake_pc(FAOsubreg,"BaseDataAC", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * FAOdemand(i,k,"2010")*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
 
Parameter
check_mc(k, year)  Check market clearing
;

check_mc(k, year) = SUM(i,FAOdemand(i,k,year)) - SUM(i, FAOprod(i,k,year));

ABORT $(SUM(k,check_mc(k, "2010")) GT 0.000005) "Some item demands are below zero" ;


*only activate below if FAOexport is not adjusted above

Parameter
FAOdemand_belowzero(i,k,year)
FAOdemand_belowzero_depratiolt0(i,k,year)
AbbortIfDemandBelowZero
;

FAOdemand_belowzero(i,k,year)$(FAOdemand(i,k,year) LT 0) = FAOdemand(i,k,year);
FAOdemand_belowzero_depratiolt0(i,k,year)$(depratios(k,"Klein","mean")) = FAOdemand_belowzero(i,k,year);

AbbortIfDemandBelowZero = abs(SUM((i,k,year),FAOdemand_belowzero(i,k,year) ));

ABORT $(AbbortIfDemandBelowZero GT 0.000005) "Some item demands are below zero" ;


** Only include below to replicate appendix E (to calculate the share of pollination dependent crops in total crop production value, export and import value)
$INCLUDE PollinationDepGlobalShareCalc.gms

$INCLUDE ModelComponents.gms
$INCLUDE Model A
*$stop
** Model B scaled is the model that uses heterogenous preferences and FAO trade data, but which is scaled to the UG budget data as in model A
$INCLUDE Model B_scaled.gms
$INCLUDE Model B.gms
$INCLUDE Model C.gms
$INCLUDE Model D.gms
*$stop



******* RESULT ANALYSIS *******

resGlobalPriceTotalObs(modeltype) = SUM(k, resGlobalPriceObs(k,modeltype));

resGlobalPriceObsCropName(cropname,modeltype) = SUM(k,mapping_k_cropname(k,cropname)*resGlobalPriceObs(k,modeltype));

*** Fill Model Comparison Parameter

ModelComparison("UnG","Budget")  = SUM(i,Uwingabire_study(i,"Budget") * FAOpop(i, "2010"))/10**9 ; 
ModelComparison("UnG","CSchg")  = WelfareUnG_global("CSchg") ;
ModelComparison("UnG","PSchg")  = WelfareUnG_global("PSchg") ;
ModelComparison("UnG","NWFchg") = ModelComparison("UnG","CSchg") +
                                            ModelComparison("UnG","PSchg");

ModelComparison("ModelA","Budget") =  SUM(i, Budget(i,"ModelA")) / 10**9 ;
ModelComparison("ModelA","CSchg") = resCSchg_global("simmod1_a100") / 10**3 ;
ModelComparison("ModelA","PSchg") = resPSchg_global("simmod1_a100") / 10**3  ;
ModelComparison("ModelA","NWFchg") = ModelComparison("ModelA","CSchg") +
                                            ModelComparison("ModelA","PSchg");
                                            
ModelComparison("ModelB_scaled","Budget") =  SUM(i, Budget(i,"ModelB_scaled")) / 10**9 ;
ModelComparison("ModelB_scaled","CSchg") = resCSchg_global("simmod2_a100") / 10**3  ;
ModelComparison("ModelB_scaled","PSchg") = resPSchg_global("simmod2_a100") / 10**3 ;
ModelComparison("ModelB_scaled","NWFchg") = ModelComparison("ModelB_scaled","CSchg") +
                                            ModelComparison("ModelB_scaled","PSchg");                                          

ModelComparison("ModelB","Budget") = SUM(i, Budget(i,"ModelB")) / 10**9 ;
ModelComparison("ModelB","CSchg") = resCSchg_global("simmod3_a100") / 10**3  ;
ModelComparison("ModelB","PSchg") = resPSchg_global("simmod3_a100") / 10**3 ;
ModelComparison("ModelB","NWFchg") = ModelComparison("ModelB","CSchg") +
                                            ModelComparison("ModelB","PSchg");
                                            
ModelComparison("ModelC","Budget") = SUM(i, Budget(i,"ModelC")) / 10**9 ;
ModelComparison("ModelC","CSchg") = resCSchg_global("simmod4_a100") / 10**3  ;
ModelComparison("ModelC","PSchg") = resPSchg_global("simmod4_a100") / 10**3 ;
ModelComparison("ModelC","NWFchg") = ModelComparison("ModelC","CSchg") +
                                            ModelComparison("ModelC","PSchg");
                                            
ModelComparison("ModelD","Budget") = SUM(i, Budget(i,"ModelD")) / 10**9 ;
ModelComparison("ModelD","CSchg") = resCSchg_global("simmod5_a100") / 10**3  ;
ModelComparison("ModelD","PSchg") = resPSchg_global("simmod5_a100") / 10**3 ;
ModelComparison("ModelD","NWFchg") = ModelComparison("ModelD","CSchg") +
                                            ModelComparison("ModelD","PSchg");
     
*taken from Fig. 4 Uwingabire, Z., Gallai, N., 2024. Impacts of degraded pollination ecosystem services on global food security and nutrition.
* Ecological Economics 217, 108068. https://doi.org/10.1016/j.ecolecon.2023.108068"                                    
ModelComparison("UnG","VitA")       = -0.067;
ModelComparison("UnG","VitC")       = -0.052;
ModelComparison("UnG","Iron")       = -0.034;
ModelComparison("UnG","Folate")     = -0.029;
ModelComparison("UnG","Protein")    = -0.018;
ModelComparison("UnG","VitB6")      = -0.0015;

ModelComparison("ModelA",n) = resGlobalNutrients_perc(n,"simmod1_a100");
ModelComparison("ModelB_scaled",n) = resGlobalNutrients_perc(n,"simmod2_a100");
ModelComparison("ModelB",n) = resGlobalNutrients_perc(n,"simmod3_a100");
ModelComparison("ModelC",n) = resGlobalNutrients_perc(n,"simmod4_a100");
ModelComparison("ModelD",n) = resGlobalNutrients_perc(n,"simmod5_a100");

ModelComparison("ModelA","foodprice_wgt")         = resGlobalperc_foodtot("World_Market_Price","simmod1_a100");
ModelComparison("ModelA","cropprice_wgt")         = resGlobalperc_croptot("World_Market_Price","simmod1_a100");
ModelComparison("ModelA","pollcropprice_wgt")     = resGlobalperc_pollcroptot("World_Market_Price","simmod1_a100");
ModelComparison("ModelA","foodprice_avg")         = resGlobalFoodPrice_avg("simmod1_a100");
ModelComparison("ModelA","cropprice_avg")         = resGlobalCropPrice_avg("simmod1_a100");
ModelComparison("ModelA","pollcropprice_avg")     = resGlobalPollPrice_avg("simmod1_a100");
ModelComparison("ModelA","FoodProduction")        = resGlobalperc_foodtot("Global_Production","simmod1_a100");
ModelComparison("ModelA","CropProduction")        = resGlobalperc_croptot("Global_Production","simmod1_a100");
ModelComparison("ModelA","PollCropProduction")    = resGlobalperc_pollcroptot("Global_Production","simmod1_a100");
*added 
ModelComparison("ModelA","FoodDemand")            = resGlobalperc_foodtot("Global_Demand",         "simmod1_a100");
ModelComparison("ModelA","FoodProduction_wgt")    = resGlobalperc_foodtot("Global_Production_wgt", "simmod1_a100");
ModelComparison("ModelA","FoodDemand_wgt")        = resGlobalperc_foodtot("Global_Demand_wgt",     "simmod1_a100");

ModelComparison("ModelB_scaled","foodprice_wgt")         = resGlobalperc_foodtot("World_Market_Price","simmod2_a100");
ModelComparison("ModelB_scaled","cropprice_wgt")         = resGlobalperc_croptot("World_Market_Price","simmod2_a100");
ModelComparison("ModelB_scaled","pollcropprice_wgt")     = resGlobalperc_pollcroptot("World_Market_Price","simmod2_a100");
ModelComparison("ModelB_scaled","foodprice_avg")         = resGlobalFoodPrice_avg("simmod2_a100");
ModelComparison("ModelB_scaled","cropprice_avg")         = resGlobalCropPrice_avg("simmod2_a100");
ModelComparison("ModelB_scaled","pollcropprice_avg")     = resGlobalPollPrice_avg("simmod2_a100");
ModelComparison("ModelB_scaled","FoodProduction")        = resGlobalperc_foodtot("Global_Production","simmod2_a100");
ModelComparison("ModelB_scaled","CropProduction")        = resGlobalperc_croptot("Global_Production","simmod2_a100");
ModelComparison("ModelB_scaled","PollCropProduction")    = resGlobalperc_pollcroptot("Global_Production","simmod2_a100");
*added 
ModelComparison("ModelB_scaled","FoodDemand")            = resGlobalperc_foodtot("Global_Demand",         "simmod2_a100");
ModelComparison("ModelB_scaled","FoodProduction_wgt")    = resGlobalperc_foodtot("Global_Production_wgt", "simmod2_a100");
ModelComparison("ModelB_scaled","FoodDemand_wgt")        = resGlobalperc_foodtot("Global_Demand_wgt",     "simmod2_a100");

ModelComparison("ModelB","foodprice_wgt")         = resGlobalperc_foodtot("World_Market_Price","simmod3_a100");
ModelComparison("ModelB","cropprice_wgt")         = resGlobalperc_croptot("World_Market_Price","simmod3_a100");
ModelComparison("ModelB","pollcropprice_wgt")     = resGlobalperc_pollcroptot("World_Market_Price","simmod3_a100");
ModelComparison("ModelB","foodprice_avg")         = resGlobalFoodPrice_avg("simmod3_a100");
ModelComparison("ModelB","cropprice_avg")         = resGlobalCropPrice_avg("simmod3_a100");
ModelComparison("ModelB","pollcropprice_avg")     = resGlobalPollPrice_avg("simmod3_a100");
ModelComparison("ModelB","FoodProduction")        = resGlobalperc_foodtot("Global_Production","simmod3_a100");
ModelComparison("ModelB","CropProduction")        = resGlobalperc_croptot("Global_Production","simmod3_a100");
ModelComparison("ModelB","PollCropProduction")    = resGlobalperc_pollcroptot("Global_Production","simmod3_a100");
*added 
ModelComparison("ModelB","FoodDemand")            = resGlobalperc_foodtot("Global_Demand",         "simmod3_a100");
ModelComparison("ModelB","FoodProduction_wgt")    = resGlobalperc_foodtot("Global_Production_wgt", "simmod3_a100");
ModelComparison("ModelB","FoodDemand_wgt")        = resGlobalperc_foodtot("Global_Demand_wgt",     "simmod3_a100");


ModelComparison("ModelC","foodprice_wgt")         = resGlobalperc_foodtot("World_Market_Price","simmod4_a100");
ModelComparison("ModelC","cropprice_wgt")         = resGlobalperc_croptot("World_Market_Price","simmod4_a100");
ModelComparison("ModelC","pollcropprice_wgt")     = resGlobalperc_pollcroptot("World_Market_Price","simmod4_a100");
ModelComparison("ModelC","foodprice_avg")         = resGlobalFoodPrice_avg("simmod4_a100");
ModelComparison("ModelC","cropprice_avg")         = resGlobalCropPrice_avg("simmod4_a100");
ModelComparison("ModelC","pollcropprice_avg")     = resGlobalPollPrice_avg("simmod4_a100");
ModelComparison("ModelC","FoodProduction")        = resGlobalperc_foodtot("Global_Production","simmod4_a100");
ModelComparison("ModelC","CropProduction")        = resGlobalperc_croptot("Global_Production","simmod4_a100");
ModelComparison("ModelC","PollCropProduction")    = resGlobalperc_pollcroptot("Global_Production","simmod4_a100");
*added 
ModelComparison("ModelC","FoodDemand")            = resGlobalperc_foodtot("Global_Demand",         "simmod4_a100");
ModelComparison("ModelC","FoodProduction_wgt")    = resGlobalperc_foodtot("Global_Production_wgt", "simmod4_a100");
ModelComparison("ModelC","FoodDemand_wgt")        = resGlobalperc_foodtot("Global_Demand_wgt",     "simmod4_a100");

ModelComparison("ModelD","foodprice_wgt")         = resGlobalperc_foodtot("World_Market_Price","simmod5_a100");
ModelComparison("ModelD","cropprice_wgt")         = resGlobalperc_croptot("World_Market_Price","simmod5_a100");
ModelComparison("ModelD","pollcropprice_wgt")     = resGlobalperc_pollcroptot("World_Market_Price","simmod5_a100");
ModelComparison("ModelD","foodprice_avg")         = resGlobalFoodPrice_avg("simmod5_a100");
ModelComparison("ModelD","cropprice_avg")         = resGlobalCropPrice_avg("simmod5_a100");
ModelComparison("ModelD","pollcropprice_avg")     = resGlobalPollPrice_avg("simmod5_a100");
ModelComparison("ModelD","FoodProduction")        = resGlobalperc_foodtot("Global_Production","simmod5_a100");
ModelComparison("ModelD","CropProduction")        = resGlobalperc_croptot("Global_Production","simmod5_a100");
ModelComparison("ModelD","PollCropProduction")    = resGlobalperc_pollcroptot("Global_Production","simmod5_a100");
*added 
ModelComparison("ModelD","FoodDemand")            = resGlobalperc_foodtot("Global_Demand",         "simmod5_a100");
ModelComparison("ModelD","FoodProduction_wgt")    = resGlobalperc_foodtot("Global_Production_wgt", "simmod5_a100");
ModelComparison("ModelD","FoodDemand_wgt")        = resGlobalperc_foodtot("Global_Demand_wgt",     "simmod5_a100");


*** Retrieve results for welfare changes 

WelfareChangeRegion(FAOsubreg,table4_UnG,"UnG") = SUM(i,Uwingabire_study(i,table4_UnG) * map_i_FAOsubreg(i,FAOsubreg));

WelfareChangeRegion(FAOsubreg,"CSchg","ModelA")  = SUM(i,resCSchg_subreg(i,"simmod1_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"PSchg","ModelA")  = SUM(i,resPSchg_subreg(i,"simmod1_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"NWFchg","ModelA") = SUM(i,resWFchg_subreg(i,"simmod1_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
                                                                                                                       
WelfareChangeRegion(FAOsubreg,"CSchg","ModelB")  = SUM(i,resCSchg_subreg(i,"simmod3_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"PSchg","ModelB")  = SUM(i,resPSchg_subreg(i,"simmod3_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"NWFchg","ModelB") = SUM(i,resWFchg_subreg(i,"simmod3_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
                                                                                                                       
WelfareChangeRegion(FAOsubreg,"CSchg", "ModelC")  = SUM(i,resCSchg_subreg(i,"simmod4_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"PSchg", "ModelC")  = SUM(i,resPSchg_subreg(i,"simmod4_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"NWFchg","ModelC")  = SUM(i,resWFchg_subreg(i,"simmod4_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;

WelfareChangeRegion(FAOsubreg,"CSchg", "ModelD")  = SUM(i,resCSchg_subreg(i,"simmod5_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"PSchg", "ModelD")  = SUM(i,resPSchg_subreg(i,"simmod5_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;
WelfareChangeRegion(FAOsubreg,"NWFchg","ModelD")  = SUM(i,resWFchg_subreg(i,"simmod5_a100")* map_i_FAOsubreg(i,FAOsubreg)) ;

** Budget per capita
                                            
BudgetPerCapita(FAOsubreg, "UnG") = SUM(i$map_i_FAOsubreg(i,FAOsubreg), Uwingabire_study(i,"Budget"));
BudgetPerCapita(FAOsubreg, "ModelA") = SUM(i$map_i_FAOsubreg(i,FAOsubreg),R0(i) / FAOpop(i, "2010") );
BudgetPerCapita(FAOsubreg, "ModelB_scaled") = SUM(i$map_i_FAOsubreg(i,FAOsubreg),R02(i) / FAOpop(i, "2010") );
BudgetPerCapita(FAOsubreg, "ModelB") = SUM(i$map_i_FAOsubreg(i,FAOsubreg),R03(i) / FAOpop(i, "2010") );
BudgetPerCapita(FAOsubreg, "ModelC") = SUM(i$map_i_FAOsubreg(i,FAOsubreg),R04(i) / FAOpop(i, "2020") );
BudgetPerCapita(FAOsubreg, "ModelD") = SUM(i$map_i_FAOsubreg(i,FAOsubreg),R05(i) / FAOpop(i, "2020") );

** Micro-nutrient availability change across macro regions

resNutrients_macroreg(reg,n,sim)  = SUM(FAOsubreg, map_reg_FAOsubreg(reg,FAOsubreg) * resNutrients_reg(FAOsubreg,n,sim) );
resNutrients_macroreg("World",n,sim)  = SUM(reg, resNutrients_macroreg(reg,n,sim));

resNutrients_macroreg_perc(reg,n,sim)$(sim1r(sim) and resNutrients_macroreg(reg,n,"Basemod1"))  = resNutrients_macroreg(reg,n,sim) / resNutrients_macroreg(reg,n,"Basemod1") -1 ; 
resNutrients_macroreg_perc(reg,n,sim)$(sim2r(sim) and resNutrients_macroreg(reg,n,"Basemod2"))  = resNutrients_macroreg(reg,n,sim) / resNutrients_macroreg(reg,n,"Basemod2") -1 ; 
resNutrients_macroreg_perc(reg,n,sim)$(sim3r(sim) and resNutrients_macroreg(reg,n,"Basemod3"))  = resNutrients_macroreg(reg,n,sim) / resNutrients_macroreg(reg,n,"Basemod3") -1 ; 
resNutrients_macroreg_perc(reg,n,sim)$(sim4r(sim) and resNutrients_macroreg(reg,n,"Basemod4"))  = resNutrients_macroreg(reg,n,sim) / resNutrients_macroreg(reg,n,"Basemod4") -1 ; 
resNutrients_macroreg_perc(reg,n,sim)$(sim5r(sim) and resNutrients_macroreg(reg,n,"Basemod5"))  = resNutrients_macroreg(reg,n,sim) / resNutrients_macroreg(reg,n,"Basemod5") -1 ; 


Parameter
value_shr_cropgroupCHK(cropgroup, modeltype)  Check if the sum of shares per crop group sum to 1;

value_shr_cropgroupCHK(cropgroup, modeltype) = SUM(k, value_shr_cropgroup(k,cropgroup, modeltype))

$INCLUDE FinalOutputs.gms

*** END OF FILE ***
