*** This model variant aims to reconstruct the model approach in Uwangabire and Gallai (2023)

*** Based on 2010
*** The food budget is based on the UG data
*** It is assumed that all countries have identical preferences


** Important - if the demand is derived from identical preferences then the prices have to be reset
Parameter
globalfoodbudget        Global budget spent on food - based on total global production and producer prices
globalprod(k)           Global production - used in loop
globalprod2(k,year)     Global production per year - used below to exclude zero production in subset k1
globalbshare(k)         Global budget share
globaldemand_value(k)   Global demand value for a product - only in case of identical preferences needed
PW0alt(k)               Alternative world price - only in case of identical preferences

foodbudget_fromstudy(i)   Food budget per capita as in Table 4 of Uwangabire and Gallai (2024)
;

globalprod2(k,year) = SUM(i, FAOprod(i,k,year));

Loop(year$year1(year),

SubRegPop(i)  = FAOpop(i, year) ;

** determine what crops to include
* inlude all crops that are included in Chaplin Kramer et al 2014 - about 139 crops
k1(k)$(globalprod2(k,year) and ediblecrop(k))= YES;
*Include sugarcane and sugarbeet
k1("156") = YES;
k1("157") = YES;

*activate below to include crops with dependence ratios
onek1(k)$k1(k)= 1;
sumk1 = SUM(k$k1(k),onek1(k));

** determine budget share 
globalbshare(k)$k1(k) = 1 / sumk1;

*Determine global production for crop k
globalprod(k)$k1(k) = SUM(i, FAOprod(i,k,year));

** The food budget is derived from the UG study which reports the food budget in US$ per capita in Table 4
** below multiplies this with the FAO population data for each subregion (FAOpop is not available for 2022)

foodbudget_fromstudy(i) = Uwingabire_study(i,"Budget") * FAOpop(i, year) ;
PW0alt(k)$(globalprod(k) and k1(k)) = (globalbshare(k)*SUM(i,foodbudget_fromstudy(i))) / globalprod(k) ;

foodbudget0(i) = foodbudget_fromstudy(i);
R0(i) = foodbudget0(i);

** the budget share is derived by the number of edible food items k1
*bshare(i,k) = FAOdemand(i,k,year) / foodbudget0(i);
bshare(i,k)$k1(k)  = 1 / sumk1;

CHKbshare1   = SUM(k,bshare("5",k));

ABORT $((CHKbshare1 - 1) GT 0.000005) "Some of budget shares do not equal 1" ;

**** Variable Initialization ****
PW.L(k)$k1(k) = PW0alt(k);
PW0(k)$k1(k) = PW0alt(k);
P.L(i,k)$k1(k) = PW.L(k);
P0(i,k)$k1(k) = PW.L(k);

*Initialize Food Demand
X.L(i,k)$(k1(k) and P.L(i,k)) = bshare(i,k) * foodbudget0(i) /P.L(i,k)  ; 
X0(i,k)$(k1(k) and P.L(i,k)) = X.L(i,k);

Q0(i,k)$k1(k) = FAOprod(i,k,year);

* Calculate production value shares for k1 in the base
prodvalue_shr_base0(k)$k1(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp)$k1(k),Q0(i,kp) * PW0(kp));

prodvalue_shr_base0CHK= SUM(k,prodvalue_shr_base0(k));

ABORT $(abs(prodvalue_shr_base0CHK - 1) GT 0.000005) "Production base value shares do not equal 1" ;


Q.L(i,k)$(k1(k) and Q0(i,k)) = Q0(i,k);

NX.L(i,k)$k1(k) = Q.L(i,k) - X.L(i,k);
TB.L(i,k)$k1(k) =  NX.L(i,k) * P.L(i,k);

** Fix foodbudget 
R.FX(i) = foodbudget0(i);

** Fix Supply Variable if equal zero
Q.FX(i,k)$(P.L(i,k) EQ 0 and k1(k)) = 0;
Q.FX(i,k)$(Q.L(i,k) EQ 0 and k1(k)) = 0;

** Fix Demd Variable if prices equal zero
X.FX(i,k)$(P.L(i,k) EQ 0 and k1(k)) = 0;

** calibrate the slope based on the open economy reference equilibrium 

supplyslope(i,k)$Q.L(i,k) = P.L(i,k) / Q.L(i,k);

ItemsIncluded(i,k)$(P.L(i,k) and k1(k)) = P.L(i,k);

testMC(k) = SUM(i, Q.L(i,k) - X.L(i,k));

value_shr_base(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp),Q0(i,kp) * PW0(kp));
value_shr_crops_base(k)$kcrop(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW0(kp));
value_shr_pollcrops_base(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW0(kp));

** set shock files
D(k) = depratios(k,"Klein","Mean");
alpha(i,k) = 0;

** calculate base food and nutrient intake

BaseFoodIntake_pc(FAOsubreg,"ModelA", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        X0(i,k) * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"ModelA") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),X0(i,k)* 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                                                                     
BaseNutrientIntake_pc(FAOsubreg,"ModelA", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * X0(i,k)*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
 
value_shr_cropgroup(k,cropgroup, "ModelA") = (SUM(i,PW.L(k)*Q.L(i,k)*mapping_k_cropgroup(k,cropgroup))) /
                                            SUM((i,kp)$mapping_k_cropgroup(kp,cropgroup),PW.L(kp)*Q.L(i,kp));
                                                           
* end of loop
);

**** MODEL EQUATIONS ****
*SupplyEQ(i,k)$k1(k)..
SupplyEQ(i,k)$(k1(k) and Q0(i,k))..

        P(i,k) =E= Q(i,k) * supplyslope(i,k) / (1 - alpha(i,k) * D(k));
            
DemandEQ(i,k)$(ItemsIncluded(i,k) and k1(k))..

        X(i,k) =E= R(i) * bshare(i,k) / P(i,k);

   
PriceEq(i,k)$k1(k)..

       PW(k) =E= P(i,k) ;
       
NXeq(i,k)$k1(k)..

        NX(i,k) =E= Q(i,k) - X(i,k);
        
MCeq(k)$k1(k)..

         0 =E= SUM(i, NX(i,k));
       
TradeBal(i,k)$k1(k)..

        TB(i,k) =E= (Q(i,k) - X(i,k)) * P(i,k);
        


Model ModelA /

SupplyEQ.Q
DemandEQ.X
PriceEq.P
NXeq.NX
MCeq.PW
TradeBal.TB
*all
/;


 OPTION DECIMALS = 6 ;

 Options limrow=500,limcol=10;

 option iterlim = 100 ;

 option MCP           = PATH ;
 
Solve ModelA using MCP;


Loop(sim$sim1(sim),

* shock pollinator population via alpha

alpha(i,k) = PollChange(sim);

Solve ModelA using MCP;

Budget(i,"ModelA")  = R0(i);

* World Market Prices
resPW(k,sim)$sim1r(sim) = PW.L(k);
* Food Supply
resQ(i,k,sim)$sim1r(sim)       = Q.L(i,k);
* Food Demand
resX(i,k,sim)$sim1r(sim)        = X.L(i,k);
* Net Exports
resNX(i,k,sim)$sim1r(sim)       = NX.L(i,k);
** Trade Balance
resTradeBal(i,k,sim)            =  TB.L(i,k);

resGlobal("World_Market_Price",k,sim)$sim1r(sim) = PW.L(k);

resGlobal("Global_Production",k,sim)$sim1r(sim) = SUM(i, Q.L(i,k) ); 
resGlobal("GLobal_Demand",k,sim)$sim1r(sim)  = SUM(i, X.L(i,k)); 
** Here global production, demand and trade are aggregated using base world market prices as weights
resGlobal("Global_Production_wgt",k,sim)$sim1r(sim) = SUM(i, Q.L(i,k) * PW0(k)); 
resGlobal("GLobal_Demand_wgt",k,sim)$sim1r(sim)  = SUM(i, X.L(i,k)* PW0(k)); 

resPWperc(k,sim)$(sim1r(sim) and resPW(k,"Basemod1") )          = PW.L(k) / resPW(k,"Basemod1")-1;
resQperc(i,k,sim)$(sim1r(sim) and resQ(i,k,"Basemod1") )       = Q.L(i,k) / resQ(i,k,"Basemod1")-1;
resXperc(i,k,sim)$(sim1r(sim) and resX(i,k,"Basemod1") )         = X.L(i,k) / resX(i,k,"Basemod1")-1;
resNXperc(i,k,sim)$(sim1r(sim) and resNX(i,k,"Basemod1"))        = NX.L(i,k) / resNX(i,k,"Basemod1")-1;
resTradeBalperc(i,k,sim)$(sim1r(sim) and resTradeBal(i,k,"Basemod1"))        = TB.L(i,k) / resTradeBal(i,k,"Basemod1")-1;

resNXabs(i,k,sim)$(sim1r(sim))    = NX.L(i,k) - resNX(i,k,"Basemod1");

** Calculate global results - careful when aggregating - see weighted measures
resGlobalperc_food("World_Market_Price",k,sim)$(sim1r(sim) and resPW(k,"Basemod1") )  = PW.L(k) / resPW(k,"Basemod1")-1;
resGlobalperc_food("Global_Production",k,sim)$(sim1r(sim) and resGlobal("Global_Production",k,"Basemod1") )  = resGlobal("Global_Production",k,sim)/ resGlobal("Global_Production",k,"Basemod1")-1;
resGlobalperc_food("Global_Demand",k,sim)$(sim1r(sim) and resGlobal("Global_Demand",k,"Basemod1"))   = resGlobal("Global_Demand",k,sim) / resGlobal("Global_Demand",k,"Basemod1")-1;

*resGlobalperc_foodtot("World_Market_Price",sim)$(sim1r(sim) and SUM(k, value_shr_base(k)*resPW(k,"Basemod1")))  = SUM(k, PW.L(k) *value_shr_base(k)) / SUM(k, value_shr_base(k)*resPW(k,"Basemod1"))-1;
resGlobalperc_foodtot("World_Market_Price",sim)$(sim1r(sim))  = SUM(k, resPWperc(k,sim) *value_shr_base(k)) ;
resGlobalperc_foodtot("Global_Production",sim)$(sim1r(sim) and SUM(k, resGlobal("Global_Production",k,"Basemod1")))  = SUM(k,resGlobal("Global_Production",k,sim))/SUM(k, resGlobal("Global_Production",k,"Basemod1"))-1;
resGlobalperc_foodtot("Global_Demand",sim)$(sim1r(sim) and SUM(k, resGlobal("Global_Demand",k,"Basemod1")))   = SUM(k, resGlobal("Global_Demand",k,sim)) / SUM(k, resGlobal("GLobal_Demand",k,"Basemod1"))-1;
** also include weighted measures
resGlobalperc_foodtot("Global_Production_wgt",sim)$(sim1r(sim) and SUM(k, resGlobal("Global_Production_wgt",k,"Basemod1")))  = SUM(k,resGlobal("Global_Production_wgt",k,sim))/SUM(k, resGlobal("Global_Production_wgt",k,"Basemod1"))-1;
resGlobalperc_foodtot("Global_Demand_wgt",sim)$(sim1r(sim) and SUM(k, resGlobal("Global_Demand_wgt",k,"Basemod1")))   = SUM(k, resGlobal("Global_Demand_wgt",k,sim)) / SUM(k, resGlobal("GLobal_Demand_wgt",k,"Basemod1"))-1;

*resGlobalperc_croptot("World_Market_Price",sim)$(sim1r(sim) and SUM(k$kcrop(k), value_shr_base(k)*resPW(k,"Basemod1")))  = SUM(k$kcrop(k), PW.L(k) *value_shr_base(k)) / SUM(k$kcrop(k), value_shr_base(k)*resPW(k,"Basemod1"))-1;
resGlobalperc_croptot("World_Market_Price",sim)$(sim1r(sim))  = SUM(k$kcrop(k), resPWperc(k,sim) *value_shr_crops_base(k)) ;
resGlobalperc_croptot("Global_Production",sim)$(sim1r(sim) and SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod1")))  = SUM(k$kcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod1"))-1;
resGlobalperc_croptot("Global_Demand",sim)$(sim1r(sim) and SUM(k$kcrop(k), resGlobal("Global_Demand",k,"Basemod1")))   = SUM(k$kcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kcrop(k), resGlobal("Global_Demand",k,"Basemod1"))-1;

*resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim1r(sim) and SUM(k$kpollcrop(k), value_shr_base(k)*resPW(k,"Basemod1")))  = SUM(k$kpollcrop(k), PW.L(k) *value_shr_base(k)) / SUM(k$kpollcrop(k), value_shr_base(k)*resPW(k,"Basemod1"))-1;
resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim1r(sim))  = SUM(k$kpollcrop(k), resPWperc(k,sim) *value_shr_pollcrops_base(k)) ;
resGlobalperc_pollcroptot("Global_Production",sim)$(sim1r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod1")))  = SUM(k$kpollcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod1"))-1;
resGlobalperc_pollcroptot("Global_Demand",sim)$(sim1r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,"Basemod1")))   = SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,"Basemod1"))-1;

value_shr_crops_base(k)$kcrop(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW0(kp));
value_shr_pollcrops_base(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW0(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW0(kp));

resGlobalPriceObs(k,"ModelA")=0;
resGlobalPriceObs(k,"ModelA")$(PW.L(k) and sim1r(sim)) = 1;
*resGlobalPriceObs(k)$(resPWperc(k,sim) GT 0 and sim1r(sim)) = 1;
*resGlobalPriceObs(k)$(resPW(k,sim) and sim1r(sim)) = 1;
*resGlobalPrice(sim)$sim1r(sim) = SUM(k,resGlobalperc("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelA"));

resGlobalFoodPrice_avg(sim)$(sim1r(sim) and SUM(k,resGlobalPriceObs(k,"ModelA"))) = SUM(k,resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelA"));
resGlobalCropPrice_avg(sim)$(sim1r(sim) and SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelA"))) = SUM(k$kcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelA"));               
resGlobalPollPrice_avg(sim)$(sim1r(sim) and SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelA"))) = SUM(k$kpollcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelA"));  

* Change in crop group prices
resGlobalPriceObs_CropGroup(cropgroup,k,"ModelA")$(PW.L(k) and sim1r(sim) and mapping_k_cropgroup(k,cropgroup)) = 1;

resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelA") = SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelA"));

resGlobalCropGroupPrice_avg(cropgroup,sim)$sim1r(sim)      =  SUM(k$mapping_k_cropgroup(k,cropgroup),resGlobalperc_food("World_Market_Price",k,sim)) /
*                                                                SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelA"));
                                                                resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelA");
                                                                

resGlobalCropGroupPrice_wgt(cropgroup,sim)$sim1r(sim)  = SUM(k$mapping_k_cropgroup(k,cropgroup),
                                                resPWperc(k,sim) *value_shr_cropgroup(k,cropgroup, "ModelA")) ;

** Change in Trade Balances in billion USD 
resTradeBalance(FAOsubreg,cropgroup,sim)$sim1r(sim) = SUM((k, i)$ ( mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)), resNX(i,k,sim) * resPW(k,sim)) / 10**9;           
resTradeBalance_regional(reg,cropgroup,sim)$sim1r(sim)  = SUM((i,k)$(mapping_k_cropgroup(k,cropgroup) and map_reg_i(reg,i)), resNX(i,k,sim)*resPW(k,sim))  / 10**9;  
 
** Change in Food Demand and Production        
resFoodDemand_reg(FAOsubreg,k,sim)$sim1r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim));  
resFoodDemand_reg_perc(FAOsubreg,k,sim)$(sim1r(sim) and resFoodDemand_reg(FAOsubreg,k,"Basemod1"))  = SUM(i$map_i_FAOsubreg(i,FAOsubreg), resX(i,k,sim)) / resFoodDemand_reg(FAOsubreg,k,"Basemod1") -1;  

resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)$sim1r(sim)  = SUM(FAOsubreg, map_reg_FAOsubreg(reg,FAOsubreg) * SUM(k, mapping_k_cropgroup(k,cropgroup) * resFoodDemand_reg(FAOsubreg,k,sim)) ); 
*Calculate global changes
resFoodDemand_macroreg_cropgroup("World",cropgroup,sim)$sim1r(sim)  = SUM(reg,resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim));
** calculate percentage changes
resFoodDemand_macroreg_cropgroup_perc(reg,cropgroup,sim)$(sim1r(sim) and resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod1")) =   resFoodDemand_macroreg_cropgroup(reg,cropgroup,sim)/resFoodDemand_macroreg_cropgroup(reg,cropgroup,"Basemod1") -1 ;



resTotalFoodDemand_reg(FAOsubreg,sim)$sim1r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim))); 
resTotalFoodDemand_reg_perc(FAOsubreg,sim)$(sim1r(sim) and resTotalFoodDemand_reg(FAOsubreg,"Basemod1")) = resTotalFoodDemand_reg(FAOsubreg,sim)/resTotalFoodDemand_reg(FAOsubreg,"Basemod1") - 1;
  
resTotalFoodDemandValue_reg(FAOsubreg,sim)$sim1r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim)*resPW(k,sim))); 
resTotalFoodDemandValue_reg_perc(FAOsubreg,sim)$(sim1r(sim) and resTotalFoodDemandValue_reg(FAOsubreg,"Basemod1")) = resTotalFoodDemandValue_reg(FAOsubreg,sim)/resTotalFoodDemandValue_reg(FAOsubreg,"Basemod1") - 1;
                     
                   
resFoodProd_reg(FAOsubreg,sim)$sim1r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resQ(i,k,sim))); 
resFoodProd_reg_perc(FAOsubreg,sim)$(sim1r(sim) and resFoodProd_reg(FAOsubreg,"Basemod1")) = resFoodProd_reg(FAOsubreg,sim)/resFoodProd_reg(FAOsubreg,"Basemod1") - 1;
                     
           
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric tons (10**3 kg) - but nutrient contents are measured per 100g
* => adjustment by factor 10
* change in vitamin A is then in 1000 IU; change in vitamin B6, C, Folate and Iron is in gram (mg * 10**3)

resNutrients_reg(FAOsubreg,n,sim)$sim1r(sim)       = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) *  resX(i,k,sim)*10));             

resNutrients_reg_pc(FAOsubreg,n,sim)$sim1r(sim)    = resNutrients_reg(FAOsubreg,n,sim)/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                
resNutrients_reg_abs_pc(FAOsubreg,n,sim)$sim1r(sim)    = (resNutrients_reg(FAOsubreg,n,sim)-resNutrients_reg(FAOsubreg,n,"Basemod1"))/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));  

resNutrients_reg_perc(FAOsubreg,n,sim)$(resNutrients_reg(FAOsubreg,n,"Basemod1") and sim1r(sim)) =  resNutrients_reg(FAOsubreg,n,sim) / resNutrients_reg(FAOsubreg,n,"Basemod1") -1 ;             

** Change in global nutrient intake / availability
resGlobalNutrients(n,sim)$sim1r(sim)     = SUM((i,k), nutritionmatrix(k,n) *  resX(i,k,sim));             
resGlobalNutrients_perc(n,sim)$sim1r(sim) =  resGlobalNutrients(n,sim) / resGlobalNutrients(n,"Basemod1") -1 ;             

** Calculate welfare changes
* Consumer surplus
** demand curve         P(i,k) =E= R(i) * bshare(i,k) / Q(i,k);
resCS(i,k,sim)$(sim1r(sim) and Q0(i,k)) = ((R.L(i) * bshare(i,k) * log(Q.L(i,k)) - R.L(i) * bshare(i,k) * log(0.0001))  - PW.L(k) * Q.L(i,k) ) / 10**6;
resCSchg(i,k,sim)$sim1r(sim) = (resCS(i,k,sim) - resCS(i,k,"Basemod1")) ;

* Producer surplus is simply the half of the domestic production value (because it is a linear supply function)
resPS(i,k,sim)$(sim1r(sim) and Q0(i,k)) = ((P.L(i,k) * Q.L(i,k)) / 2) / 10**6;
resPSchg(i,k,sim)$sim1r(sim)     =  resPS(i,k,sim) - resPS(i,k,"Basemod1");

resCS_subreg(i,sim)$sim1r(sim)   = SUM(k,resCS(i,k,sim) )  ;
resCSchg_subreg(i,sim)$sim1r(sim)   = SUM(k,resCSchg(i,k,sim) )  ;
resCS_global(sim)$sim1r(sim)     = SUM(i,resCS_subreg(i,sim) )  ;
resCSchg_global(sim)$sim1r(sim)     = SUM(i,resCSchg_subreg(i,sim) )  ;

resPS_subreg(i,sim)$sim1r(sim)     = SUM(k,resPS(i,k,sim) )  ;            
resPSchg_subreg(i,sim)$sim1r(sim)     = SUM(k,resPSchg(i,k,sim) )  ;            
resPS_global(sim)$sim1r(sim)       = SUM(i,resPS_subreg(i,sim) )  ;       
resPSchg_global(sim)$sim1r(sim)       = SUM(i,resPSchg_subreg(i,sim) )  ;       

resWF_subreg(i,sim)$sim1r(sim)    =  resCS_subreg(i,sim) + resPS_subreg(i,sim); 
resWFchg_subreg(i,sim)$sim1r(sim)    =  resCSchg_subreg(i,sim) + resPSchg_subreg(i,sim); 
resWF_global(sim)$sim1r(sim)      = SUM(i, resWF_subreg(i,sim))  ; 
resWFchg_global(sim)$sim1r(sim)      = SUM(i, resWFchg_subreg(i,sim))  ; 

resCSchg_subreg_perc(i,sim)$(sim1r(sim) and resCS_subreg(i,"Basemod1")) = resCS_subreg(i,sim)  / resCS_subreg(i,"Basemod1")  -1 ; 
resCSchg_global_perc(sim)$(sim1r(sim) and resCS_global("Basemod1"))   = resCS_global(sim) / resCS_global("Basemod1")  - 1;  

resPSchg_subreg_perc(i,sim)$(sim1r(sim) and resPS_subreg(i,"Basemod1")) = resPS_subreg(i,sim)  / resPS_subreg(i,"Basemod1")  -1 ; 
resPSchg_global_perc(sim)$(sim1r(sim) and resPS_global("Basemod1"))   = resPS_global(sim) / resPS_global("Basemod1")  - 1;  

resWFchg_subreg_perc(i,sim)$(sim1r(sim) and resWF_subreg(i,"Basemod1")) = resWF_subreg(i,sim) / resWF_subreg(i,"Basemod1")-1;
resWFchg_global_perc(sim)$(sim1r(sim) and resWF_global("Basemod1")) = resWF_global(sim) / resWF_global("Basemod1") - 1;  
* end of simulation loop
);


