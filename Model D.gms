*** MODEL B based on 2020 data

*** This model variant extends the Uwangabire and Gallai (2023) study

*** Based on 2020 data
*** The food budget is based on the FAO data
*** Regions have HETEROGENOUS preferences


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
 


Loop(year$year5(year),

SubRegPop(i)  = FAOpop(i, year) ;

k5(k)$(avgFAOprices(k,year) and ediblecrop(k)) = YES;


**count number of pollination dependent crops
onek5(k)$depratios(k,"Siopa","mean") = 1;
sumk5 = SUM(k$k5(k),onek5(k));

** determine what crops to include
k5(k)$(avgFAOprices(k,year) EQ 0 or not ediblecrop(k)) = No ;

*Include sugarcane and sugarbeet
k5("156") = YES;
k5("157") = YES;

*actually determined in model 1 but re-determined here to allow to run only model 5
Q0(i,k)$k5(k) = FAOprod(i,k,year);

PW05(k)$k5(k) = avgFAOprices(k,year);
foodbudget05(i) = SUM(k$k5(k), FAOdemand(i,k,year) * avgFAOprices(k,year) );
R05(i) = foodbudget05(i);

Display R05;

bshare5(i,k)$k5(k) = (FAOdemand(i,k,year) *  avgFAOprices(k,year)) / foodbudget05(i);
bshareCHK(i) = SUM(k, bshare5(i,k));

**** Variable Initialization ****

PW.L(k)$k5(k) = avgFAOprices(k,year);

PW05(k)$k5(k)  = PW.L(k);

X05(i,k)$(k5(k) and PW.L(k)) = FAOdemand(i,k,year) ; 

Q05(i,k)$(k5(k) and PW.L(k)) = FAOprod(i,k,year);

* Calculate production value shares for k5 in the base
prodvalue_shr_base05(k)$k5(k) = SUM(i, Q05(i,k) * PW04(k)) / SUM((i,kp)$k5(k),Q05(i,kp) * PW05(kp));

prodvalue_shr_base04CHK= SUM(k,prodvalue_shr_base05(k));

ABORT $(abs(prodvalue_shr_base04CHK - 1) GT 0.000005) "Production base value shares in model D do not equal 1" ;



P.L(i,k)$(k5(k)) = PW.L(k);
P05(i,k)$(k5(k)) = PW.L(k);

X.L(i,k)$(k5(k) and P.L(i,k)) = X05(i,k);

NX05(i,k)$(k5(k) and Q05(i,k)) = Q05(i,k) - X05(i,k);

Q.L(i,k)$(k5(k) and Q05(i,k) and P.L(i,k)) = Q05(i,k);

NX.L(i,k)$k5(k) = Q.L(i,k) - X.L(i,k);

NX.FX(i,k)$(k5(k) and P.L(i,k) EQ 0) = 0;

** Check Trade Balances

GlobalImports0(k)$(k5(k))  = SUM((i)$(NX.L(i,k) LT 0) , NX.L(i,k)) ;
GlobalExports0(k)$(k5(k))  = SUM((i)$(NX.L(i,k) GT 0) , NX.L(i,k)) ;

GlobalBal0(k)$k5(k) = GlobalExports0(k) + GlobalImports0(k) ;

TB.L(i,k)$k5(k) =  NX.L(i,k) * P.L(i,k);

** Fix foodbudget 
R.FX(i) = foodbudget05(i);

** Fix Supply Variable if equal zero
Q.FX(i,k)$(P.L(i,k) EQ 0 and k5(k)) = 0;
Q.FX(i,k)$(Q05(i,k) EQ 0 and k5(k)) = 0;

*P.FX(i,k)$(Q05(i,k) EQ 0 and k5(k)) = 0;

** Fix Demand Variable if prices equal zero
X.FX(i,k)$(P.L(i,k) EQ 0 and k5(k)) = 0;

** calibrate the slope Basemod5d on the reference equilibrium
*supplyslope(i,k)$Q.L(i,k) = P.L(i,k) / Q.L(i,k);
supplyslope(i,k)$Q.L(i,k) = PW.L(k) / Q.L(i,k);

ItemsIncluded5(i,k)$(P.L(i,k) and k5(k)) = P.L(i,k);

testMC(k) = SUM(i, FAOprod(i,k,"2010") - FAOdemand(i,k,"2010"));
testMC05(k) = SUM(i, Q.L(i,k) - X.L(i,k));

value_shr_base5(k)$k5(k)  = SUM(i, Q05(i,k) * PW05(k)) / SUM((i,kp)$k5(kp) ,Q05(i,kp) * PW05(kp));
value_shr_crops_base5(k)$kcrop(k) = SUM(i, Q0(i,k) * PW05(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW05(kp));
value_shr_pollcrops_base5(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW05(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW05(kp));

** set shock files
*D(k) = depratios(k,"Mean");
D(k) = depratios(k,"Siopa","mean");
D(k)$(D(k) EQ 1) = 0.99;
*$stop

alpha(i,k) = 0;

** calculate base food and nutrient intake

BaseFoodIntake_pc(FAOsubreg,"ModelD", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        X05(i,k) * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"ModelD") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),X05(i,k)* 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                                                                     
BaseNutrientIntake_pc(FAOsubreg,"ModelD", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * X05(i,k)*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i)); 

value_shr_cropgroup(k,cropgroup, "ModelD") = (SUM(i,PW.L(k)*Q.L(i,k)*mapping_k_cropgroup(k,cropgroup))) /
                                            SUM((i,kp)$mapping_k_cropgroup(kp,cropgroup),PW.L(kp)*Q.L(i,kp));
                                                           

* end of loop
);

**** MODEL EQUATIONS ****
SupplyEQ5(i,k)$(k5(k) and Q05(i,k))..

        P(i,k) =E= Q(i,k) * supplyslope(i,k) / (1 - alpha(i,k) * D(k));
        
DemandEQ5(i,k)$(ItemsIncluded5(i,k) and k5(k))..

        X(i,k) =E= R(i) * bshare5(i,k) / P(i,k);

PriceEq5(i,k)$(k5(k) and ItemsIncluded5(i,k))..

       PW(k) =E= P(i,k) ;
       
NXeq5(i,k)$(ItemsIncluded5(i,k) and k5(k))..

        NX(i,k) =E= Q(i,k) - X(i,k);
        
MCeq5(k)$(k5(k))..

         0 =E= SUM(i, NX(i,k));
       

TradeBal5(i,k)$(ItemsIncluded5(i,k) and k5(k))..

        TB(i,k) =E= (Q(i,k) - X(i,k)) * P(i,k);
        


Model ModelD /

SupplyEQ5.Q
DemandEQ5.X
PriceEq5.P
NXeq5.NX
MCeq5.PW
TradeBal5.TB
*all
/;

** Calibrate the model - zero iterations show that it has been setup correctly

 OPTION DECIMALS = 6 ;

 Options limrow=500,limcol=10;

* option iterlim = 45000 ;
 option iterlim = 100 ;

 option MCP           = PATH ;
 
Solve ModelD using MCP;

Loop(sim$sim5(sim),

* shock pollinator population via alpha

alpha(i,k) = PollChange(sim);

Solve ModelD  using MCP;

Budget(i,"ModelD")  = R05(i);

* World Market Prices
resPW(k,sim)$sim5r(sim) = PW.L(k);
* Food Supply
resQ(i,k,sim)$sim5r(sim)       = Q.L(i,k);
* Food Demand
resX(i,k,sim)$sim5r(sim)        = X.L(i,k);
* Net Exports
resNX(i,k,sim)$sim5r(sim)       = NX.L(i,k);
** Trade Balance
resTradeBal(i,k,sim)$sim5r(sim)            =  TB.L(i,k);

resGlobal("World_Market_Price",k,sim)$sim5r(sim) = PW.L(k);
resGlobal("Global_Production",k,sim)$sim5r(sim) = SUM(i, Q.L(i,k)); 
resGlobal("GLobal_Demand",k,sim)$sim5r(sim)  = SUM(i, X.L(i,k)); 

** Global production, demand and trade are aggregated using base world market prices as weights
resGlobal("Global_Production_wgt",k,sim)$(sim5r(sim) and k5(k)) = SUM(i, Q.L(i,k)* PW0(k)); 
resGlobal("GLobal_Demand_wgt",k,sim)$sim5r(sim)  = SUM(i, X.L(i,k)* PW0(k)); 

resPWperc(k,sim)$(sim5r(sim) and resPW(k,"Basemod5") )          = PW.L(k) / resPW(k,"Basemod5")-1;
resQperc(i,k,sim)$(sim5r(sim) and resQ(i,k,"Basemod5") )       = Q.L(i,k) / resQ(i,k,"Basemod5")-1;
resXperc(i,k,sim)$(sim5r(sim) and resX(i,k,"Basemod5") )         = X.L(i,k) / resX(i,k,"Basemod5")-1;
resNXperc(i,k,sim)$(sim5r(sim) and resNX(i,k,"Basemod5"))        = NX.L(i,k) / resNX(i,k,"Basemod5")-1;
resTradeBalperc(i,k,sim)$(sim5r(sim) and resTradeBal(i,k,"Basemod5"))        = TB.L(i,k) / resTradeBal(i,k,"Basemod5")-1;

resNXabs(i,k,sim)$(sim5r(sim))    = NX.L(i,k) - resNX(i,k,"Basemod5");

resGlobalperc_food("World_Market_Price",k,sim)$(sim5r(sim) and resPW(k,"Basemod5") )  = PW.L(k) / resPW(k,"Basemod5")-1;
resGlobalperc_food("Global_Production",k,sim)$(sim5r(sim) and resGlobal("Global_Production",k,"Basemod5") )  = resGlobal("Global_Production",k,sim)/ resGlobal("Global_Production",k,"Basemod5")-1;
resGlobalperc_food("Global_Demand",k,sim)$(sim5r(sim) and resGlobal("GLobal_Demand",k,"Basemod5"))   = resGlobal("Global_Demand",k,sim) / resGlobal("GLobal_Demand",k,"Basemod5")-1;

*resGlobalperc_foodtot("World_Market_Price",sim)$(sim5r(sim) and SUM(k, value_shr_base5(k)*resPW(k,"Basemod5")))  = SUM(k, PW.L(k) *value_shr_base5(k)) / SUM(k, value_shr_base5(k)*resPW(k,"Basemod5"))-1;
resGlobalperc_foodtot("World_Market_Price",sim)$(sim5r(sim))  = SUM(k, resPWperc(k,sim) *value_shr_base5(k)) ;
resGlobalperc_foodtot("Global_Production",sim)$(sim5r(sim) and SUM(k, resGlobal("Global_Production",k,"Basemod5")))  = SUM(k,resGlobal("Global_Production",k,sim))/SUM(k, resGlobal("Global_Production",k,"Basemod5"))-1;
resGlobalperc_foodtot("Global_Demand",sim)$(sim5r(sim) and SUM(k, resGlobal("GLobal_Demand",k,"Basemod5")))   = SUM(k, resGlobal("Global_Demand",k,sim)) / SUM(k, resGlobal("GLobal_Demand",k,"Basemod5"))-1;
** also include weighted measures
resGlobalperc_foodtot("Global_Production_wgt",sim)$(sim5r(sim) and SUM(k, resGlobal("Global_Production_wgt",k,"Basemod5")))  = SUM(k,resGlobal("Global_Production_wgt",k,sim))/SUM(k, resGlobal("Global_Production_wgt",k,"Basemod5"))-1;
resGlobalperc_foodtot("Global_Demand_wgt",sim)$(sim5r(sim) and SUM(k, resGlobal("Global_Demand_wgt",k,"Basemod5")))   = SUM(k, resGlobal("Global_Demand_wgt",k,sim)) / SUM(k, resGlobal("GLobal_Demand_wgt",k,"Basemod5"))-1;



*resGlobalperc_croptot("World_Market_Price",sim)$(sim5r(sim) and SUM(k$kcrop(k), value_shr_base5(k)*resPW(k,"Basemod5")))  = SUM(k$kcrop(k), PW.L(k) *value_shr_base5(k)) / SUM(k$kcrop(k), value_shr_base5(k)*resPW(k,"Basemod5"))-1;
resGlobalperc_croptot("World_Market_Price",sim)$(sim5r(sim))  = SUM(k$kcrop(k), resPWperc(k,sim) *value_shr_crops_base5(k)) ;
resGlobalperc_croptot("Global_Production",sim)$(sim5r(sim) and SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod5")))  = SUM(k$kcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod5"))-1;
resGlobalperc_croptot("Global_Demand",sim)$(sim5r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod5")))   = SUM(k$kcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod5"))-1;

*resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim5r(sim) and SUM(k$kpollcrop(k), value_shr_base5(k)*resPW(k,"Basemod5")))  = SUM(k$kpollcrop(k), PW.L(k) *value_shr_base5(k)) / SUM(k$kpollcrop(k), value_shr_base5(k)*resPW(k,"Basemod5"))-1;
resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim5r(sim))  = SUM(k$kpollcrop(k), resPWperc(k,sim) *value_shr_pollcrops_base5(k)) ;
resGlobalperc_pollcroptot("Global_Production",sim)$(sim5r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod5")))  = SUM(k$kpollcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod5"))-1;
resGlobalperc_pollcroptot("Global_Demand",sim)$(sim5r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod5")))   = SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod5"))-1;

resGlobalPriceObs(k,"ModelD") = 0;
*resGlobalPriceObs(k,"ModelD")$(resPWperc(k,sim) GT 0 and sim5r(sim)) = 1;
resGlobalPriceObs(k,"ModelD")$(PW05(k) and sim5r(sim)) = 1;

*resGlobalPrice(sim)$sim5r(sim) = SUM(k,resGlobalperc("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelD"));

resGlobalFoodPrice_avg(sim)$(sim5r(sim) and SUM(k,resGlobalPriceObs(k,"ModelD")))  = SUM(k,resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelD"));
resGlobalCropPrice_avg(sim)$(sim5r(sim) and SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelD")))  = SUM(k$kcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelD"));               
resGlobalPollPrice_avg(sim)$(sim5r(sim) and SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelD"))) = SUM(k$kpollcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelD"));  

* Change in crop group prices
resGlobalPriceObs_CropGroup(cropgroup,k,"ModelD")$(PW.L(k) and sim5r(sim) and mapping_k_cropgroup(k,cropgroup)) = 1;

resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelD") = SUM(k$k5(k),resGlobalPriceObs_CropGroup(cropgroup,k,"ModelD"));

resGlobalCropGroupPrice_avg(cropgroup,sim)$(sim5r(sim) and resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelD"))    =  SUM(k$mapping_k_cropgroup(k,cropgroup),resGlobalperc_food("World_Market_Price",k,sim)) /
*                                                                SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelD"));
                                                                resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelD");

resGlobalCropGroupPrice_wgt(cropgroup,sim)$sim5r(sim)  = SUM(k$mapping_k_cropgroup(k,cropgroup),
                                                resPWperc(k,sim) *value_shr_cropgroup(k,cropgroup, "ModelD")) ;
                                                
** Change in Trade Balances in billion USD 
resTradeBalance(FAOsubreg,cropgroup,sim)$sim5r(sim) = SUM((k, i)$ ( mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)), resNX(i,k,sim) * resPW(k,sim)) / 10**9;           
resTradeBalance_regional(reg,cropgroup,sim)$sim5r(sim) = SUM((i,k)$(mapping_k_cropgroup(k,cropgroup) and map_reg_i(reg,i)), resNX(i,k,sim)*resPW(k,sim))  / 10**9;  

** Change in Food Demand and Production        
resFoodDemand_reg(FAOsubreg,k,sim)$sim5r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim));  
resFoodDemand_reg_perc(FAOsubreg,k,sim)$(sim5r(sim) and resFoodDemand_reg(FAOsubreg,k,"Basemod5"))  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim)) / resFoodDemand_reg(FAOsubreg,k,"Basemod5") -1;  

resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)$sim5r(sim)  = SUM(FAOsubreg, map_reg_FAOsubreg(reg,FAOsubreg) * SUM(k, mapping_k_cropgroup(k,cropgroup) * resFoodDemand_reg(FAOsubreg,k,sim)) ); 
*Calculate global changes
resFoodDemand_macroreg_cropgroup("World",cropgroup,sim)$sim5r(sim)  = SUM(reg,resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim));
** calculate percentage changes
resFoodDemand_macroreg_cropgroup_perc(reg,cropgroup,sim)$(sim5r(sim) and resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod5")) =   resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)/resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod5") -1 ;

                 
resTotalFoodDemand_reg(FAOsubreg,sim)$sim5r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim))); 
resTotalFoodDemand_reg_perc(FAOsubreg,sim)$(sim5r(sim) and resTotalFoodDemand_reg(FAOsubreg,"Basemod5")) = resTotalFoodDemand_reg(FAOsubreg,sim)/resTotalFoodDemand_reg(FAOsubreg,"Basemod5") - 1;
      
resTotalFoodDemandValue_reg(FAOsubreg,sim)$sim5r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim)*resPW(k,sim))); 
resTotalFoodDemandValue_reg_perc(FAOsubreg,sim)$(sim5r(sim) and resTotalFoodDemandValue_reg(FAOsubreg,"Basemod5")) = resTotalFoodDemandValue_reg(FAOsubreg,sim)/resTotalFoodDemandValue_reg(FAOsubreg,"Basemod5") - 1;
   
   
resFoodProd_reg(FAOsubreg,sim)$sim5r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resQ(i,k,sim))); 
resFoodProd_reg_perc(FAOsubreg,sim)$(sim5r(sim) and resFoodProd_reg(FAOsubreg,"Basemod5")) = resFoodProd_reg(FAOsubreg,sim)/resFoodProd_reg(FAOsubreg,"Basemod5") - 1;
                     
           
  
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**5) and protein in kg

resNutrients_reg(FAOsubreg,n,sim)$sim5r(sim)      = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) *  resX(i,k,sim)*10));             

resNutrients_reg_pc(FAOsubreg,n,sim)$sim5r(sim)    = resNutrients_reg(FAOsubreg,n,sim)/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                
resNutrients_reg_abs_pc(FAOsubreg,n,sim)$sim5r(sim)   = (resNutrients_reg(FAOsubreg,n,sim)-resNutrients_reg(FAOsubreg,n,"Basemod5"))/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));  

resNutrients_reg_perc(FAOsubreg,n,sim)$(resNutrients_reg(FAOsubreg,n,"Basemod5") and sim5r(sim)) =  resNutrients_reg(FAOsubreg,n,sim) / resNutrients_reg(FAOsubreg,n,"Basemod5") -1 ;             
                  
** Change in global nutrient intake / availability
resGlobalNutrients(n,sim)$sim5r(sim)     = SUM((i,k), nutritionmatrix(k,n) *  resX(i,k,sim));             
resGlobalNutrients_perc(n,sim)$sim5r(sim) =  resGlobalNutrients(n,sim) / resGlobalNutrients(n,"Basemod5") -1 ;             


** Calculate welfare changes
* Consumer surplus
** demand curve         P(i,k) =E= R(i) * bshare5(i,k) / Q(i,k);
resCS(i,k,sim)$(sim5r(sim) and Q05(i,k)) = ((R.L(i) * bshare5(i,k) * log(Q.L(i,k)) - R.L(i) * bshare5(i,k) * log(0.0001))  - PW.L(k) * Q.L(i,k) ) / 10**6;
resCSchg(i,k,sim)$sim5r(sim) = (resCS(i,k,sim) - resCS(i,k,"Basemod5")) ;

* Producer surplus is simply the half of the domestic production value (because it is a linear supply function)
resPS(i,k,sim)$(sim5r(sim) and Q05(i,k)) = ((P.L(i,k) * Q.L(i,k)) / 2) / 10**6;
resPSchg(i,k,sim)$sim5r(sim)     =  resPS(i,k,sim) - resPS(i,k,"Basemod5");

resCS_subreg(i,sim)$sim5r(sim)   = SUM(k,resCS(i,k,sim) )  ;
resCSchg_subreg(i,sim)$sim5r(sim)   = SUM(k,resCSchg(i,k,sim) )  ;
resCS_global(sim)$sim5r(sim)     = SUM(i,resCS_subreg(i,sim) )  ;
resCSchg_global(sim)$sim5r(sim)     = SUM(i,resCSchg_subreg(i,sim) )  ;

resPS_subreg(i,sim)$sim5r(sim)     = SUM(k,resPS(i,k,sim) )  ;            
resPSchg_subreg(i,sim)$sim5r(sim)     = SUM(k,resPSchg(i,k,sim) )  ;            
resPS_global(sim)$sim5r(sim)       = SUM(i,resPS_subreg(i,sim) )  ;       
resPSchg_global(sim)$sim5r(sim)       = SUM(i,resPSchg_subreg(i,sim) )  ;       

resWF_subreg(i,sim)$sim5r(sim)    =  resCS_subreg(i,sim) + resPS_subreg(i,sim); 
resWFchg_subreg(i,sim)$sim5r(sim)    =  resCSchg_subreg(i,sim) + resPSchg_subreg(i,sim); 
resWF_global(sim)$sim5r(sim)      = SUM(i, resWF_subreg(i,sim))  ; 
resWFchg_global(sim)$sim5r(sim)      = SUM(i, resWFchg_subreg(i,sim))  ; 

resCSchg_subreg_perc(i,sim)$(sim5r(sim) and resCS_subreg(i,"Basemod5")) = resCS_subreg(i,sim)  / resCS_subreg(i,"Basemod5")  -1 ; 
resCSchg_global_perc(sim)$(sim5r(sim) and resCS_global("Basemod5"))   = resCS_global(sim) / resCS_global("Basemod5")  - 1;  

resPSchg_subreg_perc(i,sim)$(sim5r(sim) and resPS_subreg(i,"Basemod5")) = resPS_subreg(i,sim)  / resPS_subreg(i,"Basemod5")  -1 ; 
resPSchg_global_perc(sim)$(sim5r(sim) and resPS_global("Basemod5"))   = resPS_global(sim) / resPS_global("Basemod5")  - 1;  

resWFchg_subreg_perc(i,sim)$(sim5r(sim) and resWF_subreg(i,"Basemod5")) = resWF_subreg(i,sim) / resWF_subreg(i,"Basemod5")-1;
resWFchg_global_perc(sim)$(sim5r(sim) and resWF_global("Basemod5")) = resWF_global(sim) / resWF_global("Basemod5") - 1;  
* end of simulation loop
);

