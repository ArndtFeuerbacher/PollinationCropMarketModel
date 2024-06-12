*** MODEL B based on 2020 data

*** This model variant extends the Uwangabire and Gallai (2024) study

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
 

Loop(year$year4(year),

SubRegPop(i)  = FAOpop(i, year) ;

k4(k)$(avgFAOprices(k,year) and ediblecrop(k)) = YES;


**count number of pollination dependent crops
onek4(k)$depratios(k,"Mean") = 1;
sumk4 = SUM(k$k4(k),onek4(k));

** determine what crops to include
k4(k)$(avgFAOprices(k,year) EQ 0 or not ediblecrop(k)) = No ;

*Include sugarcane and sugarbeet
k4("156") = YES;
k4("157") = YES;

*actually determined in model 1 but re-determined here to allow to run only model 4
Q0(i,k)$k4(k) = FAOprod(i,k,year);

PW04(k)$k4(k) = avgFAOprices(k,year);
foodbudget04(i) = SUM(k$k4(k), FAOdemand(i,k,year) * avgFAOprices(k,year) );
R04(i) = foodbudget04(i);

Display R04;

bshare4(i,k)$k4(k) = (FAOdemand(i,k,year) *  avgFAOprices(k,year)) / foodbudget04(i);
bshareCHK(i) = SUM(k, bshare4(i,k));

**** Variable Initialization ****

PW.L(k)$k4(k) = avgFAOprices(k,year);

PW04(k)$k4(k)  = PW.L(k);

X04(i,k)$(k4(k) and PW.L(k)) = FAOdemand(i,k,year) ; 

Q04(i,k)$(k4(k) and PW.L(k)) = FAOprod(i,k,year);

P.L(i,k)$(k4(k)) = PW.L(k);
P04(i,k)$(k4(k)) = PW.L(k);

X.L(i,k)$(k4(k) and P.L(i,k)) = X04(i,k);

NX04(i,k)$(k4(k) and Q04(i,k)) = Q04(i,k) - X04(i,k);

Q.L(i,k)$(k4(k) and Q04(i,k) and P.L(i,k)) = Q04(i,k);

NX.L(i,k)$k4(k) = Q.L(i,k) - X.L(i,k);

NX.FX(i,k)$(k4(k) and P.L(i,k) EQ 0) = 0;

** Check Trade Balances

GlobalImports0(k)$(k4(k))  = SUM((i)$(NX.L(i,k) LT 0) , NX.L(i,k)) ;
GlobalExports0(k)$(k4(k))  = SUM((i)$(NX.L(i,k) GT 0) , NX.L(i,k)) ;

GlobalBal0(k)$(k4(k)) = GlobalExports0(k) + GlobalImports0(k) ;

TB.L(i,k)$k4(k) =  NX.L(i,k) * P.L(i,k);

** Fix foodbudget 
R.FX(i) = foodbudget04(i);

** Fix Supply Variable if equal zero
Q.FX(i,k)$(P.L(i,k) EQ 0 and k4(k)) = 0;
Q.FX(i,k)$(Q04(i,k) EQ 0 and k4(k)) = 0;

*P.FX(i,k)$(Q04(i,k) EQ 0 and k4(k)) = 0;

** Fix Demand Variable if prices equal zero
X.FX(i,k)$(P.L(i,k) EQ 0 and k4(k)) = 0;

** calibrate the slope Basemod4d on the reference equilibrium
*supplyslope(i,k)$Q.L(i,k) = P.L(i,k) / Q.L(i,k);
supplyslope(i,k)$Q.L(i,k) = PW.L(k) / Q.L(i,k);

ItemsIncluded4(i,k)$(P.L(i,k) and k4(k)) = P.L(i,k);

testMC(k) = SUM(i, FAOprod(i,k,"2010") - FAOdemand(i,k,"2010"));
testMC04(k) = SUM(i, Q.L(i,k) - X.L(i,k));

value_shr_base4(k) = SUM(i, Q04(i,k) * PW04(k)) / SUM((i,kp),Q04(i,kp) * PW04(kp));
value_shr_crops_base4(k)$kcrop(k) = SUM(i, Q0(i,k) * PW04(k)) / SUM((i,kp)$kcrop(kp),Q0(i,kp) * PW04(kp));
value_shr_pollcrops_base4(k)$kpollcrop(k) = SUM(i, Q0(i,k) * PW04(k)) / SUM((i,kp)$kpollcrop(kp) ,Q0(i,kp) * PW04(kp));

** set shock files
D(k) = depratios(k,"Mean");
alpha(i,k) = 0;

** calculate base food and nutrient intake

BaseFoodIntake_pc(FAOsubreg,"ModelB_2020", cropgroup) = SUM((k, i)$(mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)),
                                        X04(i,k) * 10**3) / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));

BaseTotalFoodIntake_pc(FAOsubreg,"ModelB_2020") = SUM((k,i)$(map_i_FAOsubreg(i,FAOsubreg)),X04(i,k)* 10**3) 
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                                                                     
BaseNutrientIntake_pc(FAOsubreg,"ModelB_2020", n) = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) * X04(i,k)*10))
                                                    / SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i)); 

value_shr_cropgroup(k,cropgroup, "ModelB_2020") = (SUM(i,PW.L(k)*Q.L(i,k)*mapping_k_cropgroup(k,cropgroup))) /
                                            SUM((i,kp)$mapping_k_cropgroup(kp,cropgroup),PW.L(kp)*Q.L(i,kp));
                                                           

* end of loop
);

**** MODEL EQUATIONS ****
SupplyEQ4(i,k)$(k4(k) and Q04(i,k))..

        P(i,k) =E= Q(i,k) * supplyslope(i,k) / (1 - alpha(i,k) * D(k));
        
DemandEQ4(i,k)$(ItemsIncluded4(i,k) and k4(k))..

        X(i,k) =E= R(i) * bshare4(i,k) / P(i,k);

PriceEq4(i,k)$(k4(k) and ItemsIncluded4(i,k))..

       PW(k) =E= P(i,k) ;
       
NXeq4(i,k)$(ItemsIncluded4(i,k) and k4(k))..

        NX(i,k) =E= Q(i,k) - X(i,k);
        
MCeq4(k)$(k4(k))..

         0 =E= SUM(i, NX(i,k));
       

TradeBal4(i,k)$(ItemsIncluded4(i,k) and k4(k))..

        TB(i,k) =E= (Q(i,k) - X(i,k)) * P(i,k);
        


Model ModelB_2020 /

SupplyEQ4.Q
DemandEQ4.X
PriceEq4.P
NXeq4.NX
MCeq4.PW
TradeBal4.TB
*all
/;

** Calibrate the model - zero iterations show that it has been setup correctly

 OPTION DECIMALS = 6 ;

 Options limrow=500,limcol=10;

* option iterlim = 45000 ;
 option iterlim = 100 ;

 option MCP           = PATH ;
 
Solve ModelB_2020 using MCP;

Loop(sim$sim4(sim),

* shock pollinator population via alpha

alpha(i,k) = PollChange(sim);

Solve ModelB_2020  using MCP;

Budget(i,"ModelB_2020")  = R04(i);

* World Market Prices
resPW(k,sim)$sim4r(sim) = PW.L(k);
* Food Supply
resQ(i,k,sim)$sim4r(sim)       = Q.L(i,k);
* Food Demand
resX(i,k,sim)$sim4r(sim)        = X.L(i,k);
* Net Exports
resNX(i,k,sim)$sim4r(sim)       = NX.L(i,k);
** Trade Balance
resTradeBal(i,k,sim)$sim4r(sim)            =  TB.L(i,k);

resGlobal("World_Market_Price",k,sim)$sim4r(sim) = PW.L(k); 
resGlobal("Global_Production",k,sim)$sim4r(sim) = SUM(i, Q.L(i,k)); 
resGlobal("GLobal_Demand",k,sim)$sim4r(sim)  = SUM(i, X.L(i,k)); 
resGlobal("GLobal_NetExports",k,sim)$sim4r(sim) = SUM(i, NX.L(i,k)); 

resPWperc(k,sim)$(sim4r(sim) and resPW(k,"Basemod4") )          = PW.L(k) / resPW(k,"Basemod4")-1;
resQperc(i,k,sim)$(sim4r(sim) and resQ(i,k,"Basemod4") )       = Q.L(i,k) / resQ(i,k,"Basemod4")-1;
resXperc(i,k,sim)$(sim4r(sim) and resX(i,k,"Basemod4") )         = X.L(i,k) / resX(i,k,"Basemod4")-1;
resNXperc(i,k,sim)$(sim4r(sim) and resNX(i,k,"Basemod4"))        = NX.L(i,k) / resNX(i,k,"Basemod4")-1;
resTradeBalperc(i,k,sim)$(sim4r(sim) and resTradeBal(i,k,"Basemod4"))        = TB.L(i,k) / resTradeBal(i,k,"Basemod4")-1;

resNXabs(i,k,sim)$(sim4r(sim))    = NX.L(i,k) - resNX(i,k,"Basemod4");

resGlobalperc_food("World_Market_Price",k,sim)$(sim4r(sim) and resPW(k,"Basemod4") )  = PW.L(k) / resPW(k,"Basemod4")-1;
resGlobalperc_food("Global_Production",k,sim)$(sim4r(sim) and resGlobal("Global_Production",k,"Basemod4") )  = resGlobal("Global_Production",k,sim)/ resGlobal("Global_Production",k,"Basemod4")-1;
resGlobalperc_food("Global_Demand",k,sim)$(sim4r(sim) and resGlobal("GLobal_Demand",k,"Basemod4"))   = resGlobal("Global_Demand",k,sim) / resGlobal("GLobal_Demand",k,"Basemod4")-1;
resGlobalperc_food("Global_NetExports",k,sim)$(sim4r(sim) and resGlobal("GLobal_NetExports",k,"Basemod4") )  = resGlobal("Global_NetExports",k,sim) / resGlobal("GLobal_NetExports",k,"Basemod4")-1;

*resGlobalperc_foodtot("World_Market_Price",sim)$(sim4r(sim) and SUM(k, value_shr_base4(k)*resPW(k,"Basemod4")))  = SUM(k, PW.L(k) *value_shr_base4(k)) / SUM(k, value_shr_base4(k)*resPW(k,"Basemod4"))-1;
resGlobalperc_foodtot("World_Market_Price",sim)$(sim4r(sim))  = SUM(k, resPWperc(k,sim) *value_shr_base4(k)) ;
resGlobalperc_foodtot("Global_Production",sim)$(sim4r(sim) and SUM(k, resGlobal("Global_Production",k,"Basemod4")))  = SUM(k,resGlobal("Global_Production",k,sim))/SUM(k, resGlobal("Global_Production",k,"Basemod4"))-1;
resGlobalperc_foodtot("Global_Demand",sim)$(sim4r(sim) and SUM(k, resGlobal("GLobal_Demand",k,"Basemod4")))   = SUM(k, resGlobal("Global_Demand",k,sim)) / SUM(k, resGlobal("GLobal_Demand",k,"Basemod4"))-1;
resGlobalperc_foodtot("Global_NetExports",sim)$(sim4r(sim) and SUM(k, resGlobal("GLobal_NetExports",k,"Basemod4")))  = SUM(k,resGlobal("Global_NetExports",k,sim)) / SUM(k, resGlobal("GLobal_NetExports",k,"Basemod4"))-1;

*resGlobalperc_croptot("World_Market_Price",sim)$(sim4r(sim) and SUM(k$kcrop(k), value_shr_base4(k)*resPW(k,"Basemod4")))  = SUM(k$kcrop(k), PW.L(k) *value_shr_base4(k)) / SUM(k$kcrop(k), value_shr_base4(k)*resPW(k,"Basemod4"))-1;
resGlobalperc_croptot("World_Market_Price",sim)$(sim4r(sim))  = SUM(k$kcrop(k), resPWperc(k,sim) *value_shr_crops_base4(k)) ;
resGlobalperc_croptot("Global_Production",sim)$(sim4r(sim) and SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod4")))  = SUM(k$kcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kcrop(k), resGlobal("Global_Production",k,"Basemod4"))-1;
resGlobalperc_croptot("Global_Demand",sim)$(sim4r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod4")))   = SUM(k$kcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_Demand",k,"Basemod4"))-1;
resGlobalperc_croptot("Global_NetExports",sim)$(sim4r(sim) and SUM(k$kcrop(k), resGlobal("GLobal_NetExports",k,"Basemod4")))  = SUM(k$kcrop(k),resGlobal("Global_NetExports",k,sim)) / SUM(k$kcrop(k), resGlobal("GLobal_NetExports",k,"Basemod4"))-1;

*resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim4r(sim) and SUM(k$kpollcrop(k), value_shr_base4(k)*resPW(k,"Basemod4")))  = SUM(k$kpollcrop(k), PW.L(k) *value_shr_base4(k)) / SUM(k$kpollcrop(k), value_shr_base4(k)*resPW(k,"Basemod4"))-1;
resGlobalperc_pollcroptot("World_Market_Price",sim)$(sim4r(sim))  = SUM(k$kpollcrop(k), resPWperc(k,sim) *value_shr_pollcrops_base4(k)) ;
resGlobalperc_pollcroptot("Global_Production",sim)$(sim4r(sim) and SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod4")))  = SUM(k$kpollcrop(k),resGlobal("Global_Production",k,sim))/SUM(k$kpollcrop(k), resGlobal("Global_Production",k,"Basemod4"))-1;
resGlobalperc_pollcroptot("Global_Demand",sim)$(sim4r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod4")))   = SUM(k$kpollcrop(k), resGlobal("Global_Demand",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_Demand",k,"Basemod4"))-1;
resGlobalperc_pollcroptot("Global_NetExports",sim)$(sim4r(sim) and SUM(k$kpollcrop(k), resGlobal("GLobal_NetExports",k,"Basemod4")))  = SUM(k$kpollcrop(k),resGlobal("Global_NetExports",k,sim)) / SUM(k$kpollcrop(k), resGlobal("GLobal_NetExports",k,"Basemod4"))-1;

resGlobalPriceObs(k,"ModelB_2020") = 0;
*resGlobalPriceObs(k,"ModelB_2020")$(resPWperc(k,sim) GT 0 and sim4r(sim)) = 1;
resGlobalPriceObs(k,"ModelB_2020")$(PW04(k) and sim4r(sim)) = 1;

*resGlobalPrice(sim)$sim4r(sim) = SUM(k,resGlobalperc("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_2020"));

resGlobalFoodPrice_avg(sim)$(sim4r(sim) and SUM(k,resGlobalPriceObs(k,"ModelB_2020")))  = SUM(k,resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k,resGlobalPriceObs(k,"ModelB_2020"));
resGlobalCropPrice_avg(sim)$(sim4r(sim) and SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_2020")))  = SUM(k$kcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kcrop(k),resGlobalPriceObs(k,"ModelB_2020"));               
resGlobalPollPrice_avg(sim)$(sim4r(sim) and SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_2020"))) = SUM(k$kpollcrop(k),resGlobalperc_food("World_Market_Price",k,sim)) / SUM(k$kpollcrop(k),resGlobalPriceObs(k,"ModelB_2020"));  

* Change in crop group prices
resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2020")$(PW.L(k) and sim4r(sim) and mapping_k_cropgroup(k,cropgroup)) = 1;

resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2020") = SUM(k$k4(k),resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2020"));

resGlobalCropGroupPrice_avg(cropgroup,sim)$(sim4r(sim) and resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2020"))    =  SUM(k$mapping_k_cropgroup(k,cropgroup),resGlobalperc_food("World_Market_Price",k,sim)) /
*                                                                SUM(k,resGlobalPriceObs_CropGroup(cropgroup,k,"ModelB_2020"));
                                                                resGlobalPriceTotalObs_cropgroup(cropgroup,"ModelB_2020");

resGlobalCropGroupPrice_wgt(cropgroup,sim)$sim4r(sim)  = SUM(k$mapping_k_cropgroup(k,cropgroup),
                                                resPWperc(k,sim) *value_shr_cropgroup(k,cropgroup, "ModelB_2020")) ;
                                                
** Change in Trade Balances in billion USD 
resTradeBalance(FAOsubreg,cropgroup,sim)$sim4r(sim) = SUM((k, i)$ ( mapping_k_cropgroup(k,cropgroup) and map_i_FAOsubreg(i,FAOsubreg)), resNX(i,k,sim) * resPW(k,sim)) / 10**9;           
resTradeBalance_regional(reg,cropgroup,sim)$sim4r(sim) = SUM((i,k)$(mapping_k_cropgroup(k,cropgroup) and map_reg_i(reg,i)), resNX(i,k,sim)*resPW(k,sim))  / 10**9;  
                 
resFoodDemand_reg(FAOsubreg,sim)$sim4r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim))); 
resFoodDemand_reg_perc(FAOsubreg,sim)$(sim4r(sim) and resFoodDemand_reg(FAOsubreg,"Basemod4")) = resFoodDemand_reg(FAOsubreg,sim)/resFoodDemand_reg(FAOsubreg,"Basemod4") - 1;
      
resFoodDemandValue_reg(FAOsubreg,sim)$sim4r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resX(i,k,sim)*resPW(k,sim))); 
resFoodDemandValue_reg_perc(FAOsubreg,sim)$(sim4r(sim) and resFoodDemandValue_reg(FAOsubreg,"Basemod4")) = resFoodDemandValue_reg(FAOsubreg,sim)/resFoodDemandValue_reg(FAOsubreg,"Basemod4") - 1;
   
   
resFoodProd_reg(FAOsubreg,sim)$sim4r(sim)  = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, resQ(i,k,sim))); 
resFoodProd_reg_perc(FAOsubreg,sim)$(sim4r(sim) and resFoodProd_reg(FAOsubreg,"Basemod4")) = resFoodProd_reg(FAOsubreg,sim)/resFoodProd_reg(FAOsubreg,"Basemod4") - 1;
                     
           
  
** Change in regional nutrient intake / availability
** nutrients are multiplied with quantities in metric - but nutrient contents are measured per 100g
* => adjustment by factor 10 to arrive at intake in vitamin A in 1000 IU; change in vitamin B6, C, Folate and Iron in gram (mg * 10**4) and protein in kg

resNutrients_reg(FAOsubreg,n,sim)$sim4r(sim)      = SUM(i$map_i_FAOsubreg(i,FAOsubreg),SUM(k, nutritionmatrix(k,n) *  resX(i,k,sim)*10));             

resNutrients_reg_pc(FAOsubreg,n,sim)$sim4r(sim)    = resNutrients_reg(FAOsubreg,n,sim)/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));
                                                
resNutrients_reg_abs_pc(FAOsubreg,n,sim)$sim4r(sim)   = (resNutrients_reg(FAOsubreg,n,sim)-resNutrients_reg(FAOsubreg,n,"Basemod4"))/
                                                SUM(i$map_i_FAOsubreg(i,FAOsubreg), SubRegPop(i));  

resNutrients_reg_perc(FAOsubreg,n,sim)$(resNutrients_reg(FAOsubreg,n,"Basemod4") and sim4r(sim)) =  resNutrients_reg(FAOsubreg,n,sim) / resNutrients_reg(FAOsubreg,n,"Basemod4") -1 ;             
                  
** Change in global nutrient intake / availability
resGlobalNutrients(n,sim)$sim4r(sim)     = SUM((i,k), nutritionmatrix(k,n) *  resX(i,k,sim));             
resGlobalNutrients_perc(n,sim)$sim4r(sim) =  resGlobalNutrients(n,sim) / resGlobalNutrients(n,"Basemod4") -1 ;             


** Calculate welfare changes
* Consumer surplus
** demand curve         P(i,k) =E= R(i) * bshare4(i,k) / Q(i,k);
resCS(i,k,sim)$(sim4r(sim) and Q04(i,k)) = ((R.L(i) * bshare4(i,k) * log(Q.L(i,k)) - R.L(i) * bshare4(i,k) * log(0.0001))  - PW.L(k) * Q.L(i,k) ) / 10**6;
resCSchg(i,k,sim)$sim4r(sim) = (resCS(i,k,sim) - resCS(i,k,"Basemod4")) ;

* Producer surplus is simply the half of the domestic production value (because it is a linear supply function)
resPS(i,k,sim)$(sim4r(sim) and Q04(i,k)) = ((P.L(i,k) * Q.L(i,k)) / 2) / 10**6;
resPSchg(i,k,sim)$sim4r(sim)     =  resPS(i,k,sim) - resPS(i,k,"Basemod4");

resCS_subreg(i,sim)$sim4r(sim)   = SUM(k,resCS(i,k,sim) )  ;
resCSchg_subreg(i,sim)$sim4r(sim)   = SUM(k,resCSchg(i,k,sim) )  ;
resCS_global(sim)$sim4r(sim)     = SUM(i,resCS_subreg(i,sim) )  ;
resCSchg_global(sim)$sim4r(sim)     = SUM(i,resCSchg_subreg(i,sim) )  ;

resPS_subreg(i,sim)$sim4r(sim)     = SUM(k,resPS(i,k,sim) )  ;            
resPSchg_subreg(i,sim)$sim4r(sim)     = SUM(k,resPSchg(i,k,sim) )  ;            
resPS_global(sim)$sim4r(sim)       = SUM(i,resPS_subreg(i,sim) )  ;       
resPSchg_global(sim)$sim4r(sim)       = SUM(i,resPSchg_subreg(i,sim) )  ;       

resWF_subreg(i,sim)$sim4r(sim)    =  resCS_subreg(i,sim) + resPS_subreg(i,sim); 
resWFchg_subreg(i,sim)$sim4r(sim)    =  resCSchg_subreg(i,sim) + resPSchg_subreg(i,sim); 
resWF_global(sim)$sim4r(sim)      = SUM(i, resWF_subreg(i,sim))  ; 
resWFchg_global(sim)$sim4r(sim)      = SUM(i, resWFchg_subreg(i,sim))  ; 

resCSchg_subreg_perc(i,sim)$(sim4r(sim) and resCS_subreg(i,"Basemod4")) = resCS_subreg(i,sim)  / resCS_subreg(i,"Basemod4")  -1 ; 
resCSchg_global_perc(sim)$(sim4r(sim) and resCS_global("Basemod4"))   = resCS_global(sim) / resCS_global("Basemod4")  - 1;  

resPSchg_subreg_perc(i,sim)$(sim4r(sim) and resPS_subreg(i,"Basemod4")) = resPS_subreg(i,sim)  / resPS_subreg(i,"Basemod4")  -1 ; 
resPSchg_global_perc(sim)$(sim4r(sim) and resPS_global("Basemod4"))   = resPS_global(sim) / resPS_global("Basemod4")  - 1;  

resWFchg_subreg_perc(i,sim)$(sim4r(sim) and resWF_subreg(i,"Basemod4")) = resWF_subreg(i,sim) / resWF_subreg(i,"Basemod4")-1;
resWFchg_global_perc(sim)$(sim4r(sim) and resWF_global("Basemod4")) = resWF_global(sim) / resWF_global("Basemod4") - 1;  
* end of simulation loop
);

