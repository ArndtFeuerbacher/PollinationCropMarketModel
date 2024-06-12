*** MODEL B based on 2010 data

*** This model extends the Uwangabire and Gallai (2024) study

*** Based on 2010
*** The food budget is based on the FAO data
*** Regions have HETEROGENOUS preferences

* Set FAOprices equal zero if there is no production

avgFAOprices(k,year)$(SUM(i,FAOprod(i,k,year)) EQ 0) = 0;

** reset all model variables
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

*k3(k)$(avgFAOprices(k,"2010") and ediblecrop(k)) = YES;
 
Loop(year$year1(year),

SubRegPop(i)  = FAOpop(i, year) ;

** determine what crops to include
k3(k)$(avgFAOprices(k,year) and ediblecrop(k)) = YES;


onek3(k)$depratios(k,"Mean") = 1;
sumk3 = SUM(k$k3(k),onek3(k));

k3(k)$(avgFAOprices(k,year) EQ 0 or not ediblecrop(k)) = No ;

*Include sugarcane and sugarbeet
k3("156") = YES;
k3("157") = YES;

*actually determined in model 1 but re-determined here to allow to run only model 3
Q0(i,k)$(avgFAOprices(k,year) and ediblecrop(k)) = FAOprod(i,k,year);

PW03(k)$k3(k) = avgFAOprices(k,year);

foodbudget03(i) = SUM(k$k3(k), FAOdemand(i,k,year) * avgFAOprices(k,year) );
R03(i) = foodbudget03(i);

Display R03;

bshare3(i,k)$k3(k) = (FAOdemand(i,k,year) *  avgFAOprices(k,year)) / foodbudget03(i);
bshareCHK(i) = SUM(k, bshare3(i,k));

**** Variable Initialization ****

PW.L(k)$(avgFAOprices(k,year) and ediblecrop(k)) = avgFAOprices(k,year);
*PW.L(k)$k3(k) = PW0alt(k);
PW03(k)$k3(k) = PW.L(k);

X03(i,k)$(k3(k) and PW.L(k)) = FAOdemand(i,k,year) ; 

Q03(i,k)$(k3(k) and PW.L(k)) = FAOprod(i,k,year);

P.L(i,k)$(k3(k)) = PW.L(k);
P03(i,k)$(k3(k)) = PW.L(k);

X.L(i,k)$(k3(k) and P.L(i,k)) = X03(i,k);

NX03(i,k)$(k3(k) and Q03(i,k)) = Q03(i,k) - X03(i,k);

Q.L(i,k)$(k3(k) and Q03(i,k) and P.L(i,k)) = Q03(i,k);

NX.L(i,k)$k3(k) = Q.L(i,k) - X.L(i,k);

NX.FX(i,k)$(k3(k) and P.L(i,k) EQ 0) = 0;

** Check Trade Balances

GlobalImports0(k)$(k3(k))  = SUM((i)$(NX.L(i,k) LT 0) , NX.L(i,k)) ;
GlobalExports0(k)$(k3(k))  = SUM((i)$(NX.L(i,k) GT 0) , NX.L(i,k)) ;

GlobalBal0(k)$(k3(k)) = GlobalExports0(k) + GlobalImports0(k) ;

*Exports0(k)$(k3(k) and  NX.L(i,k) GT 0)  = SUM(k$k3(k), NX.L(i,k)) ;

*Exports0(i,k)        Exports in the base

TB.L(i,k)$k3(k) =  NX.L(i,k) * P.L(i,k);

** Fix foodbudget 
R.FX(i) = foodbudget03(i);

** Fix Supply Variable if equal zero
Q.FX(i,k)$(P.L(i,k) EQ 0 and k3(k)) = 0;
Q.FX(i,k)$(Q03(i,k) EQ 0 and k3(k)) = 0;

*P.FX(i,k)$(Q03(i,k) EQ 0 and k3(k)) = 0;

** Fix Demand Variable if prices equal zero
X.FX(i,k)$(P.L(i,k) EQ 0 and k3(k)) = 0;

** calibrate the slope based on the reference equilibrium
*supplyslope(i,k)$Q.L(i,k) = PW.L(k) / Q.L(i,k);
supplyslope(i,k)$Q.L(i,k) = PW.L(k) / Q.L(i,k);

ItemsIncluded3(i,k)$(P.L(i,k) and k3(k)) = P.L(i,k);

testMC(k) = SUM(i, FAOprod(i,k,"2010") - FAOdemand(i,k,"2010"));
testMC03(k) = SUM(i, Q.L(i,k) - X.L(i,k));

diffq03(i,k)$k3(k)  = FAOprod(i,k,"2010") - Q.L(i,k);
diffx03(i,k)$k3(k) = FAOdemand(i,k,"2010") - X.L(i,k);

value_shr_base3(k) = SUM(i, Q03(i,k) * PW03(k)) / SUM((i,kp),Q03(i,kp) * PW03(kp));
value_shr_crops_base3(k)$kcrop(k) = SUM(i, Q0(i,k) * PW03(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW03(kp));
value_shr_pollcrops_base3(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW03(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW03(kp));

** set shock files
D(k) = depratios(k,"Mean");
alpha(i,k) = 0;

** calculate base food and nutrient intake

BaseFoodIntake_pc(FAOsubreg,"ModelB_2010", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        X03(i,k) * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"ModelB_2010") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),X03(i,k)* 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                                                                     
BaseNutrientIntake_pc(FAOsubreg,"ModelB_2010", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * X03(i,k)*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i)); 

value_shr_cropgroup(k,cropgroup, "ModelB_2010") = (SUM(i,PW.L(k)*Q.L(i,k)*mapping_k_cropgroup(k,cropgroup))) /
                                            SUM((i,kp)$mapping_k_cropgroup(kp,cropgroup),PW.L(kp)*Q.L(i,kp));
                                                           
* end of loop
);

**** MODEL EQUATIONS ****
SupplyEQ3(i,k)$(k3(k) and Q03(i,k))..

        P(i,k) =E= Q(i,k) * supplyslope(i,k) / (1 - alpha(i,k) * D(k));
        
DemandEQ3(i,k)$(ItemsIncluded3(i,k) and k3(k))..

        X(i,k) =E= R(i) * bshare3(i,k) / P(i,k);
*        P(i,k) =E= R(i) * bshare3(i,k) / Q(i,k);
        

PriceEq3(i,k)$(k3(k) and ItemsIncluded3(i,k))..

       PW(k) =E= P(i,k) ;
       
NXeq3(i,k)$(ItemsIncluded3(i,k) and k3(k))..

        NX(i,k) =E= Q(i,k) - X(i,k);
        
MCeq3(k)$(k3(k))..

         0 =E= SUM(i, NX(i,k));
*         SUM(i, NX(i,k)) =L= 0.1;
       
*$ontext
TradeBal3(i,k)$(ItemsIncluded3(i,k) and k3(k))..

        TB(i,k) =E= (Q(i,k) - X(i,k)) * P(i,k);
        
*$offtext


Model ModelB_2010 /

SupplyEQ3.Q
DemandEQ3.X
PriceEq3.P
NXeq3.NX
MCeq3.PW
TradeBal3.TB
*all
/;

** Calibrate the model - zero iterations show that it has been setup correctly

 OPTION DECIMALS = 6 ;

 Options limrow=500,limcol=10;

 option iterlim = 100 ;

 option MCP           = PATH ;
 
Solve ModelB_2010 using MCP;


Loop(sim$sim3(sim),

* shock pollinator population via alpha

alpha(i,k) = PollChange(sim);

Solve ModelB_2010  using MCP;

Budget(i,"ModelB_2010")  = R03(i);

* World Market Prices
resPW(k,sim)$sim3r(sim) = PW.L(k);
* Food Supply
resQ(i,k,sim)$sim3r(sim)       = Q.L(i,k);
* Food Demand
resX(i,k,sim)$sim3r(sim)        = X.L(i,k);
* Net Exports
resNX(i,k,sim)$sim3r(sim)       = NX.L(i,k);
** Trade Balance
resTradeBal(i,k,sim)$sim3r(sim)            =  TB.L(i,k);

resGlobal("World_Market_Price",k,sim)$sim3r(sim) = PW.L(k); 
resGlobal("Global_Production",k,sim)$sim3r(sim) = SUM(i, Q.L(i,k)); 
resGlobal("GLobal_Demand",k,sim)$sim3r(sim)  = SUM(i, X.L(i,k)); 
resGlobal("GLobal_NetExports",k,sim)$sim3r(sim) = SUM(i, NX.L(i,k)); 

resPWperc(k,sim)$(sim3r(sim) and resPW(k,"Basemod3") )          = PW.L(k) / resPW(k,"Basemod3")-1;
resQperc(i,k,sim)$(sim3r(sim) and resQ(i,k,"Basemod3") )       = Q.L(i,k) / resQ(i,k,"Basemod3")-1;
resXperc(i,k,sim)$(sim3r(sim) and resX(i,k,"Basemod3") )         = X.L(i,k) / resX(i,k,"Basemod3")-1;
resNXperc(i,k,sim)$(sim3r(sim) and resNX(i,k,"Basemod3"))        = NX.L(i,k) / resNX(i,k,"Basemod3")-1;
resTradeBalperc(i,k,sim)$(sim3r(sim) and resTradeBal(i,k,"Basemod3"))        = TB.L(i,k) / resTradeBal(i,k,"Basemod3")-1;

resNXabs(i,k,sim)$(sim3r(sim))    = NX.L(i,k) - resNX(i,k,"Basemod3");

resGlobalperc_food("World_Market_Price",k,sim)$(sim3r(sim) and resPW(k,"Basemod3") )  = PW.L(k) / resPW(k,"Basemod3")-1;
resGlobalperc_food("Global_Production",k,sim)$(sim3r(sim) and resGlobal("Global_Production",k,"Basemod3") )  = resGlobal("Global_Production",k,sim)/ resGlobal("Global_Production",k,"Basemod3")-1;
resGlobalperc_food("Global_Demand",k,sim)$(sim3r(sim) and resGlobal("GLobal_Demand",k,"Basemod3"))   = resGlobal("Global_Demand",k,sim) / resGlobal("GLobal_Demand",k,"Basemod3")-1;
resGlobalperc_food("Global_NetExports",k,sim)$(sim3r(sim) and resGlobal("GLobal_NetExports",k,"Basemod3") )  = resGlobal("Global_NetExports",k,sim) / resGlobal("GLobal_NetExports",k,"Basemod3")-1;

*resGlobalperc_foodtot("World_Market_Price",sim)$(sim3r(sim) and SUM(k, value_shr_base3(k)*resPW(k,"Basemod3")))  = SUM(k, PW.L(k) *value_shr_base3(k)) / SUM(k, value_shr_base3(k)*resPW(k,"Basemod3"))-1;
resGlobalperc_foodtot("World_Market_Price",sim)$(sim3r(sim))  = SUM(k, resPWperc(k,sim) *value_shr_base3(k)) ;
resGlobalperc_foodtot("Global_Production",sim)$(sim3r(sim) and SUM(k, resGlobal("Global_Production",k,"Basemod3")))  = SUM(k,resGlobal("Global_Production",k,sim))/SUM(k, resGlobal("Global_Production",k,"Basemod3"))-1;
resGlobalperc_foodtot("Global_Demand",sim)$(sim3r(sim) and SUM(k, resGlobal("GLobal_Demand",k,"Basemod3")))   = SUM(k, resGlobal("Global_Demand",k,sim)) / SUM(k, resGlobal("GLobal_Demand",k,"Basemod3"))-1;
resGlobalperc_foodtot("Global_NetExports",sim)$(sim3r(sim) and SUM(k, resGlobal("GLobal_NetExports",k,"Basemod3")))  = SUM(k,resGlobal("Global_NetExports",k,sim)) / SUM(k, resGlobal("GLobal_NetExports",k,"Basemod3"))-1;

*resGlobalperc_croptot("World_Market_Price",sim)$(sim3r(sim) and SUM(k$kcrop(k), value_shr_base3(k)*resPW(k,"Basemod3")))  = SUM(k$kcrop(k), PW.L(k) *value_shr_base3(k)) / SUM(k$kcrop(k), value_shr_base3(k)*resPW(k,"Basemod3"))-1;
resGlobalperc_croptot("World_Market_Price",sim)$(sim3r(sim))  = SUM(k$kcrop(k), resPWperc(k,sim) *value_shr_crops_base3(k)) ;
resGlobalperc_croptot("Global_Production",sim)$(sim3r(sim) and SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod3")))  = SUM(k$kcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod3"))-1;
resGlobalperc_croptot("Global_Demand",sim)$(sim3r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod3")))   = SUM(k$kcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod3"))-1;
resGlobalperc_croptot("Global_NetExports",sim)$(sim3r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_NetExports",k,"Basemod3")))  = SUM(k$kcrop(k),resGlobal("Global_NetExports",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_NetExports",k,"Basemod3"))-1;

*resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim3r(sim) and SUM(k$kpollcrop(k), value_shr_base3(k)*resPW(k,"Basemod3")))  = SUM(k$kpollcrop(k), PW.L(k) *value_shr_base3(k)) / SUM(k$kpollcrop(k), value_shr_base3(k)*resPW(k,"Basemod3"))-1;
resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim3r(sim))  = SUM(k$kpollcrop(k), resPWperc(k,sim) *value_shr_pollcrops_base3(k)) ;
resGlobalperc_pollcroptot("Global_Production",sim)$(sim3r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod3")))  = SUM(k$kpollcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod3"))-1;
resGlobalperc_pollcroptot("Global_Demand",sim)$(sim3r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod3")))   = SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod3"))-1;
resGlobalperc_pollcroptot("Global_NetExports",sim)$(sim3r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_NetExports",k,"Basemod3")))  = SUM(k$kpollcrop(k),resGlobal("Global_NetExports",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_NetExports",k,"Basemod3"))-1;

resGlobalPriceObs(k,"ModelB_2010")$(not k3(k)) = 0;
*resGlobalPriceObs(k,"ModelB_2010")$(resPWperc(k,sim) GT 0 and sim3r(sim)) = 1;
resGlobalPriceObs(k,"ModelB_2010")$(PW03(k) and sim3r(sim)) = 1;

*resGlobalPrice(sim)$sim3r(sim) = SUM(k,resGlobalperc("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_2010"));

resGlobalFoodPrice_avg(sim)$(sim3r(sim) and SUM(k,resGlobalPriceObs(k,"ModelB_2010")))  = SUM(k,resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_2010"));
resGlobalCropPrice_avg(sim)$(sim3r(sim) and SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_2010")))  = SUM(k$kcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_2010"));               
resGlobalPollPrice_avg(sim)$(sim3r(sim) and SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_2010"))) = SUM(k$kpollcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_2010"));  

* Change in crop group prices
resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2010")$(PW.L(k) and sim3r(sim) and mapping_k_cropgroup(k,cropgroup)) = 1;

resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2010") = SUM(k$k3(k),resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2010"));

resGlobalCropGroupPrice_avg(cropgroup,sim)$(sim3r(sim) and resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2010"))     =  SUM(k$mapping_k_cropgroup(k,cropgroup),resGlobalperc_food("World_Market_Price",k,sim)) /
*                                                                SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2010"));
                                                                resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2010");

resGlobalCropGroupPrice_wgt(cropgroup,sim)$sim3r(sim)  = SUM(k$mapping_k_cropgroup(k,cropgroup),
                                                resPWperc(k,sim) *value_shr_cropgroup(k,cropgroup, "ModelB_2010")) ;
                                                
** Change in Trade Balances in billion USD 
resTradeBalance(FAOsubreg,cropgroup,sim)$sim3r(sim) = SUM((k, i)$ ( mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)), resNX(i,k,sim) * resPW(k,sim)) / 10**9;           
resTradeBalance_regional(reg,cropgroup,sim)$sim3r(sim) = SUM((i,k)$(mapping_k_cropgroup(k,cropgroup) and map_reg_i(reg,i)), resNX(i,k,sim)*resPW(k,sim))  / 10**9;  
     
resFoodDemand_reg(FAOsubreg,sim)$sim3r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim))); 
resFoodDemand_reg_perc(FAOsubreg,sim)$(sim3r(sim) and resFoodDemand_reg(FAOsubreg,"Basemod3")) = resFoodDemand_reg(FAOsubreg,sim)/resFoodDemand_reg(FAOsubreg,"Basemod3") - 1;
         
resFoodDemandValue_reg(FAOsubreg,sim)$sim3r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim)*resPW(k,sim))); 
resFoodDemandValue_reg_perc(FAOsubreg,sim)$(sim3r(sim) and resFoodDemandValue_reg(FAOsubreg,"Basemod3")) = resFoodDemandValue_reg(FAOsubreg,sim)/resFoodDemandValue_reg(FAOsubreg,"Basemod3") - 1;
   
resFoodProd_reg(FAOsubreg,sim)$sim3r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resQ(i,k,sim))); 
resFoodProd_reg_perc(FAOsubreg,sim)$(sim3r(sim) and resFoodProd_reg(FAOsubreg,"Basemod3")) = resFoodProd_reg(FAOsubreg,sim)/resFoodProd_reg(FAOsubreg,"Basemod3") - 1;
                     
           
              
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**3) and protein in kg

resNutrients_reg(FAOsubreg,n,sim)$sim3r(sim)      = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) *  resX(i,k,sim)*10));             

resNutrients_reg_pc(FAOsubreg,n,sim)$sim3r(sim)    = resNutrients_reg(FAOsubreg,n,sim)/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                
resNutrients_reg_abs_pc(FAOsubreg,n,sim)$sim3r(sim)   = (resNutrients_reg(FAOsubreg,n,sim)-resNutrients_reg(FAOsubreg,n,"Basemod3"))/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));  

resNutrients_reg_perc(FAOsubreg,n,sim)$(resNutrients_reg(FAOsubreg,n,"Basemod3") and sim3r(sim)) =  resNutrients_reg(FAOsubreg,n,sim) / resNutrients_reg(FAOsubreg,n,"Basemod3") -1 ;             
                  
** Change in global nutrient intake / availability
resGlobalNutrients(n,sim)$sim3r(sim)     = SUM((i,k), nutritionmatrix(k,n) *  resX(i,k,sim));             
resGlobalNutrients_perc(n,sim)$sim3r(sim) =  resGlobalNutrients(n,sim) / resGlobalNutrients(n,"Basemod3") -1 ;             


** Calculate welfare changes
* Consumer surplus
** demand curve         P(i,k) =E= R(i) * bshare3(i,k) / Q(i,k);
resCS(i,k,sim)$(sim3r(sim) and Q03(i,k)) = ((R.L(i) * bshare3(i,k) * log(Q.L(i,k)) - R.L(i) * bshare3(i,k) * log(0.0001))  - PW.L(k) * Q.L(i,k) ) / 10**6;
resCSchg(i,k,sim)$sim3r(sim) = (resCS(i,k,sim) - resCS(i,k,"Basemod3")) ;

* Producer surplus is simply the half of the domestic production value (because it is a linear supply function)
resPS(i,k,sim)$(sim3r(sim) and Q03(i,k)) = ((P.L(i,k) * Q.L(i,k)) / 2) / 10**6;
resPSchg(i,k,sim)$sim3r(sim)     =  resPS(i,k,sim) - resPS(i,k,"Basemod3");

resCS_subreg(i,sim)$sim3r(sim)   = SUM(k,resCS(i,k,sim) )  ;
resCSchg_subreg(i,sim)$sim3r(sim)   = SUM(k,resCSchg(i,k,sim) )  ;
resCS_global(sim)$sim3r(sim)     = SUM(i,resCS_subreg(i,sim) )  ;
resCSchg_global(sim)$sim3r(sim)     = SUM(i,resCSchg_subreg(i,sim) )  ;

resPS_subreg(i,sim)$sim3r(sim)     = SUM(k,resPS(i,k,sim) )  ;            
resPSchg_subreg(i,sim)$sim3r(sim)     = SUM(k,resPSchg(i,k,sim) )  ;            
resPS_global(sim)$sim3r(sim)       = SUM(i,resPS_subreg(i,sim) )  ;       
resPSchg_global(sim)$sim3r(sim)       = SUM(i,resPSchg_subreg(i,sim) )  ;       

resWF_subreg(i,sim)$sim3r(sim)    =  resCS_subreg(i,sim) + resPS_subreg(i,sim); 
resWFchg_subreg(i,sim)$sim3r(sim)    =  resCSchg_subreg(i,sim) + resPSchg_subreg(i,sim); 
resWF_global(sim)$sim3r(sim)      = SUM(i, resWF_subreg(i,sim))  ; 
resWFchg_global(sim)$sim3r(sim)      = SUM(i, resWFchg_subreg(i,sim))  ; 

resCSchg_subreg_perc(i,sim)$(sim3r(sim) and resCS_subreg(i,"Basemod3")) = resCS_subreg(i,sim)  / resCS_subreg(i,"Basemod3")  -1 ; 
resCSchg_global_perc(sim)$(sim3r(sim) and resCS_global("Basemod3"))   = resCS_global(sim) / resCS_global("Basemod3")  - 1;  

resPSchg_subreg_perc(i,sim)$(sim3r(sim) and resPS_subreg(i,"Basemod3")) = resPS_subreg(i,sim)  / resPS_subreg(i,"Basemod3")  -1 ; 
resPSchg_global_perc(sim)$(sim3r(sim) and resPS_global("Basemod3"))   = resPS_global(sim) / resPS_global("Basemod3")  - 1;  

resWFchg_subreg_perc(i,sim)$(sim3r(sim) and resWF_subreg(i,"Basemod3")) = resWF_subreg(i,sim) / resWF_subreg(i,"Basemod3")-1;
resWFchg_global_perc(sim)$(sim3r(sim) and resWF_global("Basemod3")) = resWF_global(sim) / resWF_global("Basemod3") - 1;  
* end of simulation loop
);

