**##### This code calculates the share of pollination dependent crops in total crop production value, export and import value

Set
kX(k) Subset of all FAO commodities
;


Parameter
onekX(k)        Sets 1 for all k crops
onekX_dep(k)    Sets 1 for all k crops that are pollination dependent
sumkX_dep       Sum of all k crops that are pollination dependent
sumkX_all       Sum of all k crops

ratioDepAll     Ratio of how many crops in k are pollination dependent  

Q0X(i,k,year)   Production quantity
PW0X(k,year)    World market price
NX0X(i,k,year)  Net exports

GlobalExports0X(year)   Global exports

foodprodvalue(k,year)   Food production value
valueatrisk_depMean0X(k,authors,year) Food production value at risk (or depednent on pollination services)
totalprodvalue(year)    Total food production value
totalvalueatrisk(authors,year)  Total food production value at risk

prodvalue_shr_baseX(k,year) Share in total production value
globalprodvalue0X(year)     Total global production value
avg_depratio_prod(authors,year) Average dependence ratio in production weighted by production value

exportvalue_shr_baseX(k,year)   Export value share 
globalexportvalue0X(year)       Global export value
avg_depratio_export(authors,year)   Average dependence ratio in exports weighted by export value

importvalue_shr_baseX(k,year)        Import value share 
globalimportvalue0X(year)           Global import value
avg_depratio_import(authors,year) Average dependence ratio in exports weighted by import value

avg_depratio_trade(authors,year)

IPEV(authors, year) The total economic value of insect pollination (IPEV)
EV(year)           Economic value of production
RV(authors, year)   Ratio of vulnerability (IPEV divided by EV)

;


kX(k)$(avgFAOprices(k,"2020") and ediblecrop(k)) = YES;

** determine what crops to include
kX(k)$(avgFAOprices(k,"2020") EQ 0 or not ediblecrop(k)) = No ;

*Include sugarcane and sugarbeet
kX("156") = YES;
kX("157") = YES;

**count number of pollination dependent crops
onekX(k) = 1;
onekX_dep(k)$depratios(k,"Klein","mean") = 1;
sumkX_all = SUM(k$kX(k),onekX(k));
sumkX_dep = SUM(k$kX(k),onekX_dep(k));

ratioDepAll = sumkX_dep / sumkX_all;


Q0X(i,k,year)$kX(k) = FAOprod(i,k,year);

PW0X(k,year)$kX(k) = avgFAOprices(k,year);

foodprodvalue(k,year)$kX(k)= SUM(i, FAOdemand(i,k,year) * avgFAOprices(k,year));
totalprodvalue(year) = SUM(k,foodprodvalue(k,year) );

valueatrisk_depMean0X(k,authors,year) = foodprodvalue(k,year) * depratios(k,authors,"mean");
totalvalueatrisk(authors,year) = SUM(k, valueatrisk_depMean0X(k,authors,year));

prodvalue_shr_baseX(k,year)$kX(k) = SUM(i, Q0X(i,k,year) * PW0X(k,year)) / SUM((i,kp)$kX(kp),Q0X(i,kp,year) * PW0X(kp,year));

avg_depratio_prod(authors,year) = SUM(k, prodvalue_shr_baseX(k, year) * depratios(k,authors,"mean") );

** in trade

** activate below to calculate with raw data
** Convert trade data into raw equivalents => so far only for pollination dependent items (other items do not experience a change in prices..)
FAOexport(i,k,year)$kX(k) = SUM(j, conversionmatrix(k,j)*FAOexport_allitems(i,j,year));
FAOimport(i,k,year)$kX(k) = SUM(j, conversionmatrix(k,j)*FAOimport_allitems(i,j,year));

*globalexportvalue0X = SUM(k$kX(k), FAOexport(i,k,"2020") * avgFAOprices(k,"2020"));
exportvalue_shr_baseX(k,year)$kX(k) = SUM(i,FAOexport(i,k,year)* PW0X(k,year)) / SUM((i,kp)$kX(kp),FAOexport(i,kp,year)* PW0X(kp,year));

avg_depratio_export(authors,year) = SUM(k, exportvalue_shr_baseX(k,year) * depratios(k,authors,"Mean") );


importvalue_shr_baseX(k,year)$kX(k) = SUM(i,FAOimport(i,k,year)* PW0X(k,year)) / SUM((i,kp)$kX(kp),FAOimport(i,kp,year)* PW0X(kp,year));
avg_depratio_import(authors,year) = SUM(k$kX(k), importvalue_shr_baseX(k,year) * depratios(k,authors,"Mean") );

avg_depratio_trade(authors,year) = (avg_depratio_export(authors,year) + avg_depratio_import(authors,year))/2;

parameter
appendixF(k,authors,year,*);

appendixF(k,authors,year,"productionValue")$onekX_dep(k) = prodvalue_shr_baseX(k,year);
appendixF(k,authors,year,"exportshare")$onekX_dep(k) = exportvalue_shr_baseX(k,year) ;
appendixF(k,authors,year,"importshare")$onekX_dep(k)= importvalue_shr_baseX(k,year) ;
appendixF(k,authors,year,"dependenceratio")$onekX_dep(k) = depratios(k,authors,"Mean");


IPEV(authors, year) = SUM((i,k)$kX(k), FAOdemand(i,k,year) * avgFAOprices(k,year) * depratios(k,authors,"mean")) ;
EV(year)            = SUM((i,k)$kX(k), FAOdemand(i,k,year) * avgFAOprices(k,year) ) ;
RV(authors, year)   = IPEV(authors, year) / EV(year)   ;

