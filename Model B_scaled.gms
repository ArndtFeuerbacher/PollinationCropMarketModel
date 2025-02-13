** MODEL B for 2010 SCALED

*** This model variant tries to replicated Uwangabire and Gallai (2023)

** Model B scaled (2) inflates the prices such that the same food budget in absolute terms is achieved as in Model A (or the UG study)

** based on 2010
*** The food budget is based on the UG data by simply scaling it
*** Countries have heterogenous preferences 

* Set FAOprices equal zero if there is no production

avgFAOprices(k,year)$(SUM(i,FAOprod(i,k,year)) EQ 0) = 0;

** reset all variables
P.LO(i,k)   = 0;               
P.UP(i,k)   = +inf;               
PW.LO(k)    = 0;           
PW.UP(k)    = +inf;        
Q.LO(i,k)   = 0;                  
Q.UP(i,k)   = +inf;               
X.LO(i,k)   = 0;                  
X.UP(i,k)   = +inf;                                 

NX.LO(i,k) = -inf;
NX.UP(i,k) = +inf;
TB.LO(i,k) = -inf;
TB.UP(i,k) = +inf;

;

Set
kprice_noprod(k)
kprod_noprice(k)
kprod_andprice(k)
knoprod_noprice(k)
;


Loop(year$year1(year),

kprice_noprod(k)$(ediblecrop(k) and globalprod2(k,year) EQ 0 and avgFAOprices(k,year)) = YES;
kprod_noprice(k)$(ediblecrop(k) and avgFAOprices(k,year)  EQ 0 and globalprod2(k,year) ) = YES;


kprod_andprice(k)$(ediblecrop(k) and avgFAOprices(k,year) and globalprod2(k,year) ) = YES;

knoprod_noprice(k)$(ediblecrop(k) and avgFAOprices(k,year)  EQ 0 and globalprod2(k,year) EQ 0 ) = YES;

SubRegPop(i)  = FAOpop(i, year) ;

** determine what crops to include
k2(k)$(avgFAOprices(k,year) and ediblecrop(k)) = YES;

**count number of pollination dependent crops
onek2(k)$depratios(k,"Klein","Mean")= 1;
sumk2 = SUM(k$k2(k),onek2(k));

k2(k)$(avgFAOprices(k,year) EQ 0 or not ediblecrop(k)) = No ;

*Include sugarcane and sugarbeet
k2("156") = YES;
k2("157") = YES;

*actually determined in model 1 but re-determined here to allow to run only model 2
Q0(i,k)$k2(k) = FAOprod(i,k,year);

budget_scaler  = SUM(i, Uwingabire_study(i,"Budget") * FAOpop(i, "2010")) / SUM(i,SUM(k$k2(k), FAOdemand(i,k,year) * avgFAOprices(k,year)));

foodbudget02(i) = SUM(k$k2(k), FAOdemand(i,k,year) * avgFAOprices(k,year)) * budget_scaler;

R02(i) = foodbudget02(i);

** Model 2 inflates the prices such that the same food budget in absolute terms is achieved as in Model 1
PW02(k)$k2(k) = avgFAOprices(k,year) * budget_scaler;

Display R02;

** re-estimate bshare2 based on inflated prices

bshare2(i,k)$k2(k) = (FAOdemand(i,k,year) *  PW02(k)) / foodbudget02(i);
bshareCHK(i) = SUM(k, bshare2(i,k));

**** Variable Initialization ****

PW.L(k)$k2(k) = PW02(k);

PW02(k)$k2(k)  = PW.L(k);

X02(i,k)$(k2(k) and PW.L(k)) = FAOdemand(i,k,year) ; 

Q02(i,k)$(k2(k) and PW.L(k)) = FAOprod(i,k,year);

* Calculate production value shares for k2 in the base
prodvalue_shr_base02(k)$k2(k) = SUM(i, Q02(i,k) * PW02(k)) / SUM((i,kp)$k2(k),Q02(i,kp) * PW02(kp));

prodvalue_shr_base02CHK= SUM(k,prodvalue_shr_base02(k));

ABORT $(abs(prodvalue_shr_base02CHK - 1) GT 0.000005) "Production base value shares in model B_scaled  do not equal 1" ;



P.L(i,k)$(k2(k)) = PW.L(k);
P02(i,k)$(k2(k)) = PW.L(k);



X.L(i,k)$(k2(k) and P.L(i,k)) = X02(i,k);

NX02(i,k)$(k2(k) and Q02(i,k)) = Q02(i,k) - X02(i,k);

Q.L(i,k)$(k2(k) and Q02(i,k) and P.L(i,k)) = Q02(i,k);

NX02(i,k)$(k2(k) and Q02(i,k)) = Q02(i,k) - X02(i,k);

NX.L(i,k)$k2(k) = Q.L(i,k) - X.L(i,k);

NX.FX(i,k)$(k2(k) and P.L(i,k) EQ 0) = 0;

** Check Trade Balances

GlobalImports0(k)$(k2(k))  = SUM((i)$(NX.L(i,k) LT 0) , NX.L(i,k)) ;
GlobalExports0(k)$(k2(k))  = SUM((i)$(NX.L(i,k) GT 0) , NX.L(i,k)) ;

GlobalBal0(k)$(k2(k)) = GlobalExports0(k) + GlobalImports0(k) ;

TB.L(i,k)$k2(k) =  NX.L(i,k) * P.L(i,k);

** Fix foodbudget 
R.FX(i) = foodbudget02(i);

** Fix Supply Variable if equal zero
Q.FX(i,k)$(P.L(i,k) EQ 0 and k2(k)) = 0;
Q.FX(i,k)$(Q02(i,k) EQ 0 and k2(k)) = 0;

*P.FX(i,k)$(Q02(i,k) EQ 0 and k2(k)) = 0;

** Fix Demand Variable if prices equal zero
X.FX(i,k)$(P.L(i,k) EQ 0 and k2(k)) = 0;

** calibrate the slope based on the open economy reference equilibrium
supplyslope(i,k)$Q.L(i,k) = PW.L(k) / Q.L(i,k);

ItemsIncluded2(i,k)$(P.L(i,k) and k2(k)) = P.L(i,k);

testMC(k) = SUM(i, FAOprod(i,k,"2010") - FAOdemand(i,k,"2010"));
testMC02(k) = SUM(i, Q.L(i,k) - X.L(i,k));

value_shr_base2(k) = SUM(i, Q02(i,k) * PW02(k)) / SUM((i,kp),Q02(i,kp) * PW02(kp));
value_shr_crops_base2(k)$kcrop(k) = SUM(i, Q0(i,k) * PW02(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW02(kp));
value_shr_pollcrops_base2(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW02(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW02(kp));

** set shock files
D(k) = depratios(k,"Klein","mean");
alpha(i,k) = 0;

** calculate base food and nutrient intake

BaseFoodIntake_pc(FAOsubreg,"ModelB_scaled", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        X02(i,k) * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"ModelB_scaled") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),X02(i,k)* 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                                                                     
BaseNutrientIntake_pc(FAOsubreg,"ModelB_scaled", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * X02(i,k)*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i)); 

value_shr_cropgroup(k,cropgroup, "ModelB_scaled") = (SUM(i,PW.L(k)*Q.L(i,k)*mapping_k_cropgroup(k,cropgroup))) /
                                            SUM((i,kp)$mapping_k_cropgroup(kp,cropgroup),PW.L(kp)*Q.L(i,kp));
                                                           
* end of loop
);

**** MODEL EQUATIONS ****
SupplyEQ2(i,k)$(k2(k) and Q02(i,k))..

        P(i,k) =E= Q(i,k) * supplyslope(i,k) / (1 - alpha(i,k) * D(k));
        
DemandEQ2(i,k)$(ItemsIncluded2(i,k) and k2(k))..

        X(i,k) =E= R(i) * bshare2(i,k) / P(i,k);

PriceEq2(i,k)$(k2(k) and ItemsIncluded2(i,k))..

       PW(k) =E= P(i,k) ;
       
NXeq2(i,k)$(ItemsIncluded2(i,k) and k2(k))..

        NX(i,k) =E= Q(i,k) - X(i,k);
        
MCeq2(k)$(k2(k))..

         0 =E= SUM(i, NX(i,k));
 

TradeBal2(i,k)$(ItemsIncluded2(i,k) and k2(k))..

        TB(i,k) =E= (Q(i,k) - X(i,k)) * P(i,k);
        

Model ModelB_scaled /

SupplyEQ2.Q
DemandEQ2.X
PriceEq2.P
NXeq2.NX
MCeq2.PW
TradeBal2.TB
*all
/;

** Calibrate the model - zero iterations show that it has been setup correctly

 OPTION DECIMALS = 6 ;

 Options limrow=500,limcol=10;

 option iterlim = 100 ;

 option MCP           = PATH ;
 
Solve ModelB_scaled using MCP;

Loop(sim$sim2(sim),

* shock pollinator population via alpha

alpha(i,k) = PollChange(sim);

Solve ModelB_scaled  using MCP;

Budget(i,"ModelB_scaled")  = R02(i);

* World Market Prices
resPW(k,sim)$sim2r(sim) = PW.L(k);
* Food Supply
resQ(i,k,sim)$sim2r(sim)       = Q.L(i,k);
* Food Demand
resX(i,k,sim)$sim2r(sim)        = X.L(i,k);
* Net Exports
resNX(i,k,sim)$sim2r(sim)       = NX.L(i,k);
** Trade Balance
resTradeBal(i,k,sim)            =  TB.L(i,k);

resGlobal("World_Market_Price",k,sim)$sim2r(sim) = PW.L(k);
resGlobal("Global_Production",k,sim)$sim2r(sim) = SUM(i, Q.L(i,k)); 
resGlobal("GLobal_Demand",k,sim)$sim2r(sim)  = SUM(i, X.L(i,k)); 

** Global production, demand and trade are aggregated using base world market prices as weights
resGlobal("Global_Production_wgt",k,sim)$sim2r(sim) = SUM(i, Q.L(i,k)* PW0(k)); 
resGlobal("GLobal_Demand_wgt",k,sim)$sim2r(sim)  = SUM(i, X.L(i,k)* PW0(k)); 

resPWperc(k,sim)$(sim2r(sim) and resPW(k,"Basemod2") )          = PW.L(k) / resPW(k,"Basemod2")-1;
resQperc(i,k,sim)$(sim2r(sim) and resQ(i,k,"Basemod2") )       = Q.L(i,k) / resQ(i,k,"Basemod2")-1;
resXperc(i,k,sim)$(sim2r(sim) and resX(i,k,"Basemod2") )         = X.L(i,k) / resX(i,k,"Basemod2")-1;
resNXperc(i,k,sim)$(sim2r(sim) and resNX(i,k,"Basemod2"))        = NX.L(i,k) / resNX(i,k,"Basemod2")-1;
resTradeBalperc(i,k,sim)$(sim2r(sim) and resTradeBal(i,k,"Basemod2"))        = TB.L(i,k) / resTradeBal(i,k,"Basemod2")-1;

resNXabs(i,k,sim)$(sim2r(sim))    = NX.L(i,k) - resNX(i,k,"Basemod2");

resGlobalperc_food("World_Market_Price",k,sim)$(sim2r(sim) and resPW(k,"Basemod2") )  = PW.L(k) / resPW(k,"Basemod2")-1;
resGlobalperc_food("Global_Production",k,sim)$(sim2r(sim) and resGlobal("Global_Production",k,"Basemod2") )  = resGlobal("Global_Production",k,sim)/ resGlobal("Global_Production",k,"Basemod2")-1;
resGlobalperc_food("Global_Demand",k,sim)$(sim2r(sim) and resGlobal("GLobal_Demand",k,"Basemod2"))   = resGlobal("Global_Demand",k,sim) / resGlobal("GLobal_Demand",k,"Basemod2")-1;

*resGlobalperc_foodtot("World_Market_Price",sim)$(sim2r(sim) and SUM(k, value_shr_base2(k)*resPW(k,"Basemod2")))  = SUM(k, PW.L(k) *value_shr_base2(k)) / SUM(k, value_shr_base2(k)*resPW(k,"Basemod2"))-1;
resGlobalperc_foodtot("World_Market_Price",sim)$(sim2r(sim))  = SUM(k, resPWperc(k,sim) *value_shr_base2(k)) ;
resGlobalperc_foodtot("Global_Production",sim)$(sim2r(sim) and SUM(k, resGlobal("Global_Production",k,"Basemod2")))  = SUM(k,resGlobal("Global_Production",k,sim))/SUM(k, resGlobal("Global_Production",k,"Basemod2"))-1;
resGlobalperc_foodtot("Global_Demand",sim)$(sim2r(sim) and SUM(k, resGlobal("GLobal_Demand",k,"Basemod2")))   = SUM(k, resGlobal("Global_Demand",k,sim)) / SUM(k, resGlobal("GLobal_Demand",k,"Basemod2"))-1;
** also include weighted measures
resGlobalperc_foodtot("Global_Production_wgt",sim)$(sim2r(sim) and SUM(k, resGlobal("Global_Production_wgt",k,"Basemod2")))  = SUM(k,resGlobal("Global_Production_wgt",k,sim))/SUM(k, resGlobal("Global_Production_wgt",k,"Basemod2"))-1;
resGlobalperc_foodtot("Global_Demand_wgt",sim)$(sim2r(sim) and SUM(k, resGlobal("Global_Demand_wgt",k,"Basemod2")))   = SUM(k, resGlobal("Global_Demand_wgt",k,sim)) / SUM(k, resGlobal("GLobal_Demand_wgt",k,"Basemod2"))-1;

*resGlobalperc_croptot("World_Market_Price",sim)$(sim2r(sim) and SUM(k$kcrop(k), value_shr_base2(k)*resPW(k,"Basemod2")))  = SUM(k$kcrop(k), PW.L(k) *value_shr_base2(k)) / SUM(k$kcrop(k), value_shr_base2(k)*resPW(k,"Basemod2"))-1;
resGlobalperc_croptot("World_Market_Price",sim)$(sim2r(sim))  = SUM(k$kcrop(k), resPWperc(k,sim) *value_shr_crops_base2(k)) ;
resGlobalperc_croptot("Global_Production",sim)$(sim2r(sim) and SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod2")))  = SUM(k$kcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod2"))-1;
resGlobalperc_croptot("Global_Demand",sim)$(sim2r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod2")))   = SUM(k$kcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod2"))-1;

*resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim2r(sim) and SUM(k$kpollcrop(k), value_shr_base2(k)*resPW(k,"Basemod2")))  = SUM(k$kpollcrop(k), PW.L(k) *value_shr_base2(k)) / SUM(k$kpollcrop(k), value_shr_base2(k)*resPW(k,"Basemod2"))-1;
resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim2r(sim))  = SUM(k$kpollcrop(k), resPWperc(k,sim) *value_shr_pollcrops_base2(k)) ;
resGlobalperc_pollcroptot("Global_Production",sim)$(sim2r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod2")))  = SUM(k$kpollcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod2"))-1;
resGlobalperc_pollcroptot("Global_Demand",sim)$(sim2r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod2")))   = SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod2"))-1;

resGlobalPriceObs(k,"ModelB_scaled") = 0;
*resGlobalPriceObs(k,"ModelB_scaled")$(resPWperc(k,sim) GT 0 and sim2r(sim)) = 1;
resGlobalPriceObs(k,"ModelB_scaled")$(PW02(k) and sim2r(sim)) = 1;

*resGlobalPrice(sim)$sim2r(sim) = SUM(k,resGlobalperc("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_scaled"));

resGlobalFoodPrice_avg(sim)$(sim2r(sim) and SUM(k,resGlobalPriceObs(k,"ModelB_scaled")))  = SUM(k,resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_scaled"));
resGlobalCropPrice_avg(sim)$(sim2r(sim) and SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_scaled")))  = SUM(k$kcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_scaled"));               
resGlobalPollPrice_avg(sim)$(sim2r(sim) and SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_scaled"))) = SUM(k$kpollcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_scaled"));  

* Change in crop group prices
resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_scaled")$(PW.L(k) and sim2r(sim) and mapping_k_cropgroup(k,cropgroup)) = 1;

resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_scaled") = SUM(k$k2(k),resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_scaled"));

resGlobalCropGroupPrice_avg(cropgroup,sim)$(sim2r(sim) and resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_scaled"))     =  SUM(k$mapping_k_cropgroup(k,cropgroup),resGlobalperc_food("World_Market_Price",k,sim)) /
*                                                                SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_scaled"));
                                                                resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_scaled");
                                                                
resGlobalCropGroupPrice_wgt(cropgroup,sim)$sim2r(sim)  = SUM(k$mapping_k_cropgroup(k,cropgroup),
                                                resPWperc(k,sim) *value_shr_cropgroup(k,cropgroup, "ModelB_scaled")) ;
                                                
** Change in Trade Balances in billion USD 
resTradeBalance(FAOsubreg,cropgroup,sim)$sim2r(sim) = SUM((k, i)$ ( mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)), resNX(i,k,sim) * resPW(k,sim)) / 10**9;           
resTradeBalance_regional(reg,cropgroup,sim)$sim2r(sim) = SUM((i,k)$(mapping_k_cropgroup(k,cropgroup) and map_reg_i(reg,i)), resNX(i,k,sim)*resPW(k,sim))  / 10**9;  

** Change in Food Demand and Production        
resFoodDemand_reg(FAOsubreg,k,sim)$sim2r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim));  
resFoodDemand_reg_perc(FAOsubreg,k,sim)$(sim2r(sim) and resFoodDemand_reg(FAOsubreg,k,"Basemod2"))  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim)) / resFoodDemand_reg(FAOsubreg,k,"Basemod2") -1;  

resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)$sim2r(sim)  = SUM(FAOsubreg, map_reg_FAOsubreg(reg,FAOsubreg) * SUM(k, mapping_k_cropgroup(k,cropgroup) * resFoodDemand_reg(FAOsubreg,k,sim)) );
*Calculate global changes
resFoodDemand_macroreg_cropgroup("World",cropgroup,sim)$sim2r(sim)  = SUM(reg,resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim));
** calculate percentage changes
resFoodDemand_macroreg_cropgroup_perc(reg,cropgroup,sim)$(sim2r(sim) and resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod2")) =   resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)/resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod2") -1 ;

resTotalFoodDemand_reg(FAOsubreg,sim)$sim2r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim))); 
resTotalFoodDemand_reg_perc(FAOsubreg,sim)$(sim2r(sim) and resTotalFoodDemand_reg(FAOsubreg,"Basemod2")) = resTotalFoodDemand_reg(FAOsubreg,sim)/resTotalFoodDemand_reg(FAOsubreg,"Basemod2") - 1;
 
resTotalFoodDemandValue_reg(FAOsubreg,sim)$sim2r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim)*resPW(k,sim))); 
resTotalFoodDemandValue_reg_perc(FAOsubreg,sim)$(sim2r(sim) and resTotalFoodDemandValue_reg(FAOsubreg,"Basemod2")) = resTotalFoodDemandValue_reg(FAOsubreg,sim)/resTotalFoodDemandValue_reg(FAOsubreg,"Basemod2") - 1;
   

resFoodProd_reg(FAOsubreg,sim)$sim2r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resQ(i,k,sim))); 
resFoodProd_reg_perc(FAOsubreg,sim)$(sim2r(sim) and resFoodProd_reg(FAOsubreg,"Basemod2")) = resFoodProd_reg(FAOsubreg,sim)/resFoodProd_reg(FAOsubreg,"Basemod2") - 1;
                     
                   
                          
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**3) and protein in kg

resNutrients_reg(FAOsubreg,n,sim)$sim2r(sim)      = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) *  resX(i,k,sim)*10));             

resNutrients_reg_pc(FAOsubreg,n,sim)$sim2r(sim)    = resNutrients_reg(FAOsubreg,n,sim)/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                
resNutrients_reg_abs_pc(FAOsubreg,n,sim)$sim2r(sim)   = (resNutrients_reg(FAOsubreg,n,sim)-resNutrients_reg(FAOsubreg,n,"Basemod2"))/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));  

resNutrients_reg_perc(FAOsubreg,n,sim)$(resNutrients_reg(FAOsubreg,n,"Basemod2") and sim2r(sim)) =  resNutrients_reg(FAOsubreg,n,sim) / resNutrients_reg(FAOsubreg,n,"Basemod2") -1 ;             
                  
** Change in global nutrient intake / availability
resGlobalNutrients(n,sim)$sim2r(sim)     = SUM((i,k), nutritionmatrix(k,n) *  resX(i,k,sim));             
resGlobalNutrients_perc(n,sim)$sim2r(sim) =  resGlobalNutrients(n,sim) / resGlobalNutrients(n,"Basemod2") -1 ;             


** Calculate welfare changes
* Consumer surplus
** demand curve         P(i,k) =E= R(i) * bshare2(i,k) / Q(i,k);
resCS(i,k,sim)$(sim2r(sim) and Q02(i,k)) = ((R.L(i) * bshare2(i,k) * log(Q.L(i,k)) - R.L(i) * bshare2(i,k) * log(0.0001))  - PW.L(k) * Q.L(i,k) ) / 10**6;
resCSchg(i,k,sim)$sim2r(sim) = (resCS(i,k,sim) - resCS(i,k,"Basemod2")) ;

* Producer surplus is simply the half of the domestic production value (because it is a linear supply function)
resPS(i,k,sim)$(sim2r(sim) and Q02(i,k)) = ((P.L(i,k) * Q.L(i,k)) / 2) / 10**6;
resPSchg(i,k,sim)$sim2r(sim)     =  resPS(i,k,sim) - resPS(i,k,"Basemod2");

resCS_subreg(i,sim)$sim2r(sim)   = SUM(k,resCS(i,k,sim) )  ;
resCSchg_subreg(i,sim)$sim2r(sim)   = SUM(k,resCSchg(i,k,sim) )  ;
resCS_global(sim)$sim2r(sim)     = SUM(i,resCS_subreg(i,sim) )  ;
resCSchg_global(sim)$sim2r(sim)     = SUM(i,resCSchg_subreg(i,sim) )  ;

resPS_subreg(i,sim)$sim2r(sim)     = SUM(k,resPS(i,k,sim) )  ;            
resPSchg_subreg(i,sim)$sim2r(sim)     = SUM(k,resPSchg(i,k,sim) )  ;            
resPS_global(sim)$sim2r(sim)       = SUM(i,resPS_subreg(i,sim) )  ;       
resPSchg_global(sim)$sim2r(sim)       = SUM(i,resPSchg_subreg(i,sim) )  ;       

resWF_subreg(i,sim)$sim2r(sim)    =  resCS_subreg(i,sim) + resPS_subreg(i,sim); 
resWFchg_subreg(i,sim)$sim2r(sim)    =  resCSchg_subreg(i,sim) + resPSchg_subreg(i,sim); 
resWF_global(sim)$sim2r(sim)      = SUM(i, resWF_subreg(i,sim))  ; 
resWFchg_global(sim)$sim2r(sim)      = SUM(i, resWFchg_subreg(i,sim))  ; 

resCSchg_subreg_perc(i,sim)$(sim2r(sim) and resCS_subreg(i,"Basemod2")) = resCS_subreg(i,sim)  / resCS_subreg(i,"Basemod2")  -1 ; 
resCSchg_global_perc(sim)$(sim2r(sim) and resCS_global("Basemod2"))   = resCS_global(sim) / resCS_global("Basemod2")  - 1;  

resPSchg_subreg_perc(i,sim)$(sim2r(sim) and resPS_subreg(i,"Basemod2")) = resPS_subreg(i,sim)  / resPS_subreg(i,"Basemod2")  -1 ; 
resPSchg_global_perc(sim)$(sim2r(sim) and resPS_global("Basemod2"))   = resPS_global(sim) / resPS_global("Basemod2")  - 1;  

resWFchg_subreg_perc(i,sim)$(sim2r(sim) and resWF_subreg(i,"Basemod2")) = resWF_subreg(i,sim) / resWF_subreg(i,"Basemod2")-1;
resWFchg_global_perc(sim)$(sim2r(sim) and resWF_global("Basemod2")) = resWF_global(sim) / resWF_global("Basemod2") - 1;  
* end of simulation loop
);

