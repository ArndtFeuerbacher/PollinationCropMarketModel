Set
settoorder Important to have this set otherwise the order of numbered sets is off
/
1*10000
/

year Year
/
2010
2020
2022
/

flow Trade flow
/
Import
Export
/

intens intensity
/
Mean
Min
Max
/

FAOsubreg FAO sub-regions
/
NorthernAfrica                  
WesternAfrica      
EasternAfrica      
MiddleAfrica       
SouthernAfrica

NorthernAmerica
CentralAmerica
Caribbean  
SouthAmerica
       
EasternAsia        
SouthernAsia       
SouthEasternAsia
CentralAsia        
WesternAsia  
    
EasternEurope      
NorthernEurope     
WesternEurope
SouthernEurope

AustraliaNewZealand
Melanesia          
Micronesia         
Polynesia               

/


i Sub-Regions /
5 South America
11 Western Africa
13 Central America
14 Eastern Africa
15 Northern Africa
17 Middle Africa
18 Southern Africa
21 Northern America
29 Caribbean
30 Eastern Asia

34 Southern Asia
35 SouthEastern Asia
39 Southern Europe
53 Australia NewZealand
54 Melanesia
57 Micronesia
61 Polynesia
143 Central Asia
145 Western Asia
151 Eastern Europe
154 Northern Europe
155 Western Europe
/


map_i_FAOsubreg(i,FAOsubreg) Mapping between coded Sub-egions and Sub-Region names
/
5.SouthAmerica
11.WesternAfrica
13.CentralAmerica
14.EasternAfrica
15.NorthernAfrica
17.MiddleAfrica
18.SouthernAfrica
21.NorthernAmerica
29.Caribbean
30.EasternAsia
34.SouthernAsia
35.SouthEasternAsia
39.SouthernEurope
53.AustraliaNewZealand
54.Melanesia
57.Micronesia
61.Polynesia
143.CentralAsia
145.WesternAsia
151.EasternEurope
154.NorthernEurope
155.WesternEurope
/


reg Macro regions (continents)

/
Africa
America
Asia
Europe
Oceania
/

map_reg_FAOsubreg(reg,FAOsubreg) Mapping between Continents and FAO subregions
/
Africa.NorthernAfrica 
Africa.WesternAfrica      
Africa.EasternAfrica      
Africa.MiddleAfrica       
Africa.SouthernAfrica

America.NorthernAmerica
America.CentralAmerica
America.Caribbean  
America.SouthAmerica
       
Asia.EasternAsia        
Asia.SouthernAsia       
Asia.SouthEasternAsia
Asia.CentralAsia        
Asia.WesternAsia

Europe.EasternEurope      
Europe.NorthernEurope     
Europe.WesternEurope
Europe.SouthernEurope 
    
Oceania.AustraliaNewZealand
Oceania.Melanesia          
Oceania.Micronesia         
Oceania.Polynesia          
/

table4 items from table 4 from the Uwingabire and Gallai study
/
budget      Food and beverage budget
CSchg       Consumer surplus change
PSchg       Producer surplus change
NWFchg      Net welfare change (CSchg + PSchg)
VitA    Vitamin A
VitC    Vitamin C
VitB6   Vitamin B6
Folate  Folate
Iron    Iron
Protein Protein

foodprice_avg           Food price change - simple average
cropprice_avg           Crop price change - simple average
pollcropprice_avg       Poll crop price change - simple average
foodprice_wgt           Food price change - weighted average
cropprice_wgt           Crop price change - weighted average
pollcropprice_wgt       Poll crop price change - weighted average

*Production and Demand is the same at the global level
FoodProduction
CropProduction
PollCropProduction

*add demand change in crop types
/

n(table4)   Nutrients
/
VitA    Vitamin A
VitC    Vitamin C
VitB6   Vitamin B6
Folate  Folate
Iron    Iron
Protein Protein
/

modeltype
/
BaseDataBC  Base Data before Cleaning
BaseDataAC  Base Data after Cleaning

UnG     Uwingabire and Gallai results
ModelA    Replication model 1 like in UG
ModelB_2010_scaled    Replication model 2 based on food budget prices but with heterogenous preferences
ModelB_2010    Replication model 3 based on producer prices with heterogenous preferences
ModelB_2020    Replication model 4 - like model 3 yet for 2020
/

;

Set
map_reg_i(reg,i);

map_reg_i(reg,i) = SUM(FAOsubreg, map_reg_FAOsubreg(reg,FAOsubreg) * map_i_FAOsubreg(i,FAOsubreg) );

$INCLUDE FAOcountries_crops.inc
 
Alias(k,kp), (i,ip);

Set
u set for iterations for making the trade data consistent
/1*50/;