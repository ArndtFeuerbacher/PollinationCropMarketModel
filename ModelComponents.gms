**
** Parameters, variables and model equations are specified separately for each of the four models
** Model A = just 0 as a post-fix
** Model B for 2010 scaled on the UG budget = 02
** Model B for 2010 = 03
** and
** Model B for 2020 = 04;

Parameter
foodbudget0(i)           Food Budgets for sub-regions i in model A        
foodbudget02(i)          Food Budgets for sub-regions i in model B scaled 
foodbudget03(i)          Food Budgets for sub-regions i in model B 2010   
foodbudget04(i)          Food Budgets for sub-regions i in model B 2020   

budget_scaler           Food budget scaler to adjust budget based on producer prices to UG study

bshare(i,k)              Food budget shares for items k for sub regions i - Model A
bshare2(i,k)             Food budget shares for items k for sub regions i - Model B scaled
bshare3(i,k)             Food budget shares for items k for sub regions i - Model B 2010
bshare4(i,k)             Food budget shares for items k for sub regions i - Model B 2020
bshareCHK(i)            Check Parameter - budget shares have to sum up to one
supplyslope(i,k)        Slope for Supply Curve

GlobalImports0(k)       Global Imports in the base
GlobalExports0(k)       Global Exports in the base

GlobalBal0(k)           Global Trade Balance
 
* Base Parameters in Model A (0), Model B for 2010 scaled on the UG budget (02), Model B for 2010 (03) and for Model B for 2020;
PW0(k)                   Base World Market Prices in model A       
PW02(k)                  Base World Market Prices in model B scaled
PW03(k)                  Base World Market Prices in model B 2010  
PW04(k)                  Base World Market Prices in model B 2020  
Q0(i,k)                  Base Production in model A       
Q02(i,k)                 Base Production in model B scaled
Q03(i,k)                 Base Production in model B 2010  
Q04(i,k)                 Base Production in model B 2020  
P0(i,k)                  Base Prices in model A       
P02(i,k)                 Base Prices in model B scaled
P03(i,k)                 Base Prices in model B 2010  
P04(i,k)                 Base Prices in model B 2020  
X0(i,k)                  Base Demand in model A       
X02(i,k)                 Base Demand in model B scaled
X03(i,k)                 Base Demand in model B 2010  
X04(i,k)                 Base Demand in model B 2020  
NX0(i,k)                 Base Net-Exports in model A       
NX02(i,k)                Base Net-Exports in model B scaled
NX03(i,k)                Base Net-Exports in model B 2010  
NX04(i,k)                Base Net-Exports in model B 2020  
NX0inverse(i,k)          Base Net-Exports inverse in model A       
NX02inverse(i,k)         Base Net-Exports inverse in model B scaled
NX03inverse(i,k)         Base Net-Exports inverse in model B 2010  
NX04inverse(i,k)         Base Net-Exports inverse in model B 2020  ´
R0(i)                    Base food budget in model A       
R02(i)                   Base food budget in model B scaled
R03(i)                   Base food budget in model B 2010  
R04(i)                   Base food budget in model B 2020  

* Productivity shift and dependence ratios
alpha(i,k)              Intensity of Pollinator Decline
D(k)                    Dependence ratio
;

Positive variables
P(i,k)                  Domestic market price for good j in sub-region i
PW(k)                   World Market price for good j in sub-region i
Q(i,k)                  Supply quantity of good j in sub-region i
X(i,k)                  Demand quantity of good j in sub-region i
R(i)                    Available food budget in sub-region i
;

Variables
NX(i,k) Net Exports
TB(i,k) Trade Balance

;

Equations
** Model A - replicating UG
SupplyEq                Supply Equation
DemandEq                Demand Equation
PriceEq                 Price Equation    
TradeBal                Trade Balance
NXeq                    Next Exports Equation
MCeq                    Market Clearing

* same equations for model B based on 2010 data scaled (2)
SupplyEq2                Supply Equation
DemandEq2                Demand Equation
PriceEq2                 Price Equation    
TradeBal2                Trade Balance
NXeq2                    Next Exports Equation
MCeq2                    Market Clearing

* same equations for model B based on 2010 data (3)
SupplyEq3                Supply Equation
DemandEq3                Demand Equation
PriceEq3                 Price Equation    
TradeBal3                Trade Balance
NXeq3                    Next Exports Equation
MCeq3                    Market Clearing

* same equations for model B based on 2020 data (4)
SupplyEq4                Supply Equation
DemandEq4                Demand Equation
PriceEq4                 Price Equation    
TradeBal4                Trade Balance
NXeq4                    Next Exports Equation
MCeq4                    Market Clearing
;


** Choose a year for which the model shall be run (currently 2010, 2020 and 2022 is loaded)
Set
year1(year)
/
2010
/
;

Set
year4(year)   Year used in Model B for 2020 
/
2020
/
;

* For model v1 - replicating Urawing
Set
k1(k) Subset of food items k which only include pollination dependent crops in model A       
k2(k) Subset of food items k which only include pollination dependent crops in model B scaled
k3(k) Subset of food items k which only include pollination dependent crops in model B 2010  
k4(k) Subset of food items k which only include pollination dependent crops in model B 2020  

;

*

Parameters
onek1(k)            Parameter needed to count elements in k1
sumk1               Sum of elements (food items) in k1
CHKbshare1           Sum of all budget shares

onek2(k)            Parameter needed to count elements in k2
sumk2               Sum of elements (food items) in k2

onek3(k)            Parameter needed to count elements in k2
sumk3               Sum of elements (food items) in k2

onek4(k)            Parameter needed to count elements in k2
sumk4               Sum of elements (food items) in k2

ItemsIncluded(i,k)  
ItemsIncluded2(i,k)  
ItemsIncluded3(i,k)  
ItemsIncluded4(i,k)  
testMC(k)  test market clearing
testMC0(k)  test market clearing in model A       
testMC02(k) test market clearing in model B scaled
testMC03(k) test market clearing in model B 2010  
testMC04(k) test market clearing in model B 2020  

diffq03(i,k)
diffx03(i,k)
;


Set
sim
/
* Scenarios for Model A
Basemod1
*simmod1_01*simmod1_03   Auxiliary simulations in Model A
simmod1_a005            5% pollinator decline in Model A
simmod1_a050            50% pollinator decline in Model A
simmod1_a100            100% pollinator decline in Model A

* Scenarios for Model B for 2010 unscaled
Basemod2

simmod2_a005            5% pollinator decline in Model B for 2010 unscaled
simmod2_a050            50% pollinator decline in Model B for 2010 unscaled
simmod2_01*simmod2_10   Auxiliary simulations in Model B for 2010 unscaled

simmod2_a100            100% pollinator decline in Model B for 2010 unscaled

* Scenarios for Model B for 2010 
Basemod3

simmod3_a005            5% pollinator decline in Model B for 2010 
simmod3_a050            50% pollinator decline in Model B for 2010 
simmod3_01*simmod3_10   Auxiliary simulations in Model B for 2010 

simmod3_a100            100% pollinator decline in Model B for 2010 

* Scenarios for Model B for 2020 
Basemod4

simmod4_a005            5% pollinator decline in Model B for 2020 
simmod4_a050            50% pollinator decline in Model B for 2020 
simmod4_01*simmod4_10   Auxiliary simulations in Model B for 2020 
      
simmod4_a100            100% pollinator decline in Model B for 2020 
/

sim1(sim)       Simulations run with Model A
/
Basemod1
simmod1_a005       
simmod1_a050       
simmod1_a100       
/

sim1r(sim)     Simulations of Model A that are reported
/
Basemod1    
simmod1_a005
simmod1_a050
simmod1_a100

/
sim2(sim)       Simulations run with Model B for 2010 unscaled
/
Basemod2              
                      
simmod2_a005          
simmod2_a050          
*simmod2_01*simmod2_05 
                      
simmod2_a100          
/

sim2r(sim)      Simulations run with Model B for 2010 unscaled that are reported
/
Basemod2
simmod2_a005       
simmod2_a050
simmod2_a100    
/

sim3(sim)       Simulations run with Model B for 2010 
/
Basemod3

simmod3_a005            
simmod3_a050            
*simmod3_01*simmod3_10   

simmod3_a100                    
/

sim3r(sim)      Simulations run with Model B for 2010 that are reported
/
Basemod3

simmod3_a005            
simmod3_a050            
simmod3_a100            
/

sim4(sim)       Simulations run with Model B for 2020 
/
Basemod4

simmod4_a005            
simmod4_a050            
*simmod4_01*simmod4_10   

simmod4_a100                    
/

sim4r(sim)      Simulations run with Model B for 2020 that are reported
/
Basemod4

simmod4_a005            
simmod4_a050            
simmod4_a100            
/
;

*sim2r(sim)$sim2(sim) = YES;

*** Shock parameter
Parameter
value_shr_base(k)       production value share in the base Model A
value_shr_crops_base(k)       production value share in the base Model A
value_shr_pollcrops_base(k)       production value share in the base Model A

value_shr_base2(k)       production value share in the base Model B for 2010 unscaled
value_shr_crops_base2(k)       production value share in the base Model B for 2010 unscaled
value_shr_pollcrops_base2(k)       production value share in the base Model B for 2010 unscaled

value_shr_base3(k)       production value share in the base Model B for 2010 
value_shr_crops_base3(k)       production value share in the base Model B for 2010 
value_shr_pollcrops_base3(k)       production value share in the base Model B for 2010 

value_shr_base4(k)       production value share in the base Model B for 2020 
value_shr_crops_base4(k)       production value share in the base Model B for 2020 
value_shr_pollcrops_base4(k)       production value share in the base Model B for 2020 

value_shr_sim(k, sim)   production value share of each simulation

value_shr_cropgroup(k,cropgroup, modeltype)       production value share in the base Model A

PollChange(sim);


** Determine changes in pollination services across all four models

PollChange("Basemod1") = 0 ;
PollChange("simmod1_a005") = 0.05 ;
PollChange("simmod1_a050") = 0.50 ;
PollChange("simmod1_a100") = 1 ;

* Shocks for Model B for 2010 unscaled
PollChange("Basemod2") = 0 ;
PollChange("simmod2_a005") = 0.05;
PollChange("simmod2_a050") = 0.50;
PollChange("simmod2_a100") = 1;


PollChange("simmod2_01") = 0.55;
PollChange("simmod2_02") = 0.6;
PollChange("simmod2_03") = 0.8;
PollChange("simmod2_04") = 0.95;
PollChange("simmod2_05") = 0.99;

* Shocks for Model B for 2010 
PollChange("Basemod3") = 0 ;
PollChange("simmod3_a005") = 0.05;
PollChange("simmod3_a050") = 0.50;
PollChange("simmod3_a100") = 1;

* Shocks for Model B for 2020 
PollChange("Basemod4") = 0 ;
PollChange("simmod4_a005") = 0.05;
PollChange("simmod4_a050") = 0.50;
PollChange("simmod4_a100") = 1;

*** Result sets and parameters

Set
ind
/
World_Market_Price
Global_Production
Global_Demand
Global_NetExports
/;

Parameter
resPW(k,sim)            Results for World Market Prices
resQ(i,k,sim)           Result for Food Supply 
resX(i,k,sim)           Result for Food Demand
resNX(i,k,sim)          Result for Net Exports
resTradeBal(i,k,sim)    Result for Trade Balance
resGlobal(ind,k,sim)    Result for global aggregate indicators

*---
Budget(i,modeltype)                             Food budget according to model type

resPWperc(k,sim)                                World Market Price changes for each item k
resQperc(i,k,sim)                               Supply changes for each item k in each sub-region i 
resXperc(i,k,sim)                               Demand changes for each item k in each sub-region i
resNXperc(i,k,sim)                              Next-exports for each item k in each sub-region i
resTradeBalperc(i,k,sim)                        Result for Trade Balance

resNXabs(i,k,sim)                               Next-exports for each item k in each sub-region i

resGlobalperc_food(ind,k,sim)                   Global percentage changes for various indicators for all food items k

resGlobalperc_foodtot(ind,sim)                  Global total percentage changes for all food items k
resGlobalperc_croptot(ind,sim)                  Global total percentage changes for all food items k
resGlobalperc_pollcroptot(ind,sim)              Global total percentage changes for all food items k

resGlobalPriceObs(k,modeltype)                  Parameter equal 1 if there is a global price - for each model type
resGlobalPriceTotalObs_cropgroup(cropgroup,modeltype)    total observations per crop category

resGlobalPriceObsCropName(cropname,modeltype)   Parameter equal 1 if there is a global price - for each model type
resGlobalPriceTotalObs(modeltype)               Total number of crops included in the model 
resGlobalFoodPrice_avg(sim)                     Simple average change in food prices
resGlobalCropPrice_avg(sim)                     Simple average change in global crop prices  
resGlobalPollPrice_avg(sim)                     Simple average change in global pollination dependent crop prices  
   
resGlobalPriceObs_CropGroup(cropgroup,k,modeltype)  Numer of edible crop items (obs) per crop group

resGlobalCropGroupPrice_avg(cropgroup,sim)      Price per crop group - simple average    
resGlobalCropGroupPrice_wgt(cropgroup,sim)      Weighted average crop price 

resTradeBalance(FAOsubreg,cropgroup,sim)        Trade Balance by cropgroup and FAO subregion in billion USD
resTradeBalance_regional(reg,cropgroup,sim)     Trade Balance by cropgroup and continental region in billion USD


resFoodDemand_reg(FAOsubreg,sim)                Food demand per FAO region
resFoodDemand_reg_perc(FAOsubreg,sim)           Percentage change in food demand per FAO region

resFoodDemandValue_reg(FAOsubreg,sim)           Food demand value per FAO region
resFoodDemandValue_reg_perc(FAOsubreg,sim)      Percentage change in food demand value per FAO region

resFoodProd_reg(FAOsubreg,sim)                  Food production per FAO region
resFoodProd_reg_perc(FAOsubreg,sim)             Percentage change in food production per FAO region


resNutrients_reg(FAOsubreg,n,sim)               Regional nutrient availability for consumption
resNutrients_reg_pc(FAOsubreg,n,sim)            Regional nutrient availability for consumption per capita
resNutrients_reg_abs_pc(FAOsubreg,n,sim)        Absolute change in regional nutrient availability for consumption per capita
resNutrients_reg_perc(FAOsubreg,n,sim)          Percentage change in regional nutrient availability for consumption
resGlobalNutrients(n,sim)                       Global nutrient availability for consumption
resGlobalNutrients_perc(n,sim)                  Percentage change in global nutrient availability for consumption
  

** welfare change parameters

resCS(i,k,sim)                                  Consumer Surplus for sub-region i and item k in million USD
resCSchg(i,k,sim)                               Consumer Surplus change for sub-region i and item k in million USD
resPS(i,k,sim)                                  Producer Surplus Change for sub-region i and item k in million USD
resPSchg(i,k,sim)                               Producer Surplus Change for sub-region i and item k in million USD

resCS_subreg(i,sim)                             Consumer surplus for sub-region i in million USD
resCSchg_subreg(i,sim)                          Consumer surplus change for sub-region i in million USD
resCS_global(sim)                               Total global consumer surplus in million USD
resCSchg_global(sim)                            Total global consumer surplus change in million USD

resPS_subreg(i,sim)                             Producer surplus  for sub-region i in million USD
resPSchg_subreg(i,sim)                          Producer surplus change for sub-region i in million USD
resPS_global(sim)                               Total global producer surplus in million USD
resPSchg_global(sim)                            Total global producer surplus change in million USD

resWF_subreg(i,sim)                             Welfare change for sub-region i in million USD
resWFchg_subreg(i,sim)                          Welfare change for sub-region i in million USD
resWF_global(sim)                               Total global welfare in million USD
resWFchg_global(sim)                            Total global welfare change in million USD

resCSchg_subreg_perc(i,sim)                     Consumer surplus change for sub-region i in percent
resCSchg_global_perc(sim)                       Total global consumer surplus change in percent

resPSchg_subreg_perc(i,sim)                     Producer surplus change for sub-region i in percent
resPSchg_global_perc(sim)                       Total global producer surplus change in percent

resWFchg_subreg_perc(i,sim)                     Welfare change for sub-region i in percent
resWFchg_global_perc(sim)                       Total global welfare change in percent

** Comparison of welfare changes across model
ModelComparison(modeltype,Table4)               Global welfare results of 100% pollinator decline by model type
WelfareChangeRegion(FAOsubreg,Table4,modeltype) Regional change in welfare
BudgetPerCapita(FAOsubreg, modeltype)           Edible crop consumption budget per capita
;



