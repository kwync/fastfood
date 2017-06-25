
*REGENERATE 0624
*****************************
set more off
global CHNS "/Users/kwync/Documents/Research/CHNS/"

use "${CHNS}CHNS_stata/mast_pub_01.dta",clear
merge 1:m IDind using "${CHNS}CHNS_stata/surveys_pub_01.dta", generate(_merge1)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/rst_00.dta", generate(_merge2)
format IDind IDind_f IDind_m %12.0f
merge 1:1 IDind wave using "${CHNS}CHNS_stata/pexam_00.dta", generate(_merge3)
merge m:1 hhid wave using "${CHNS}CHNS_stata/hhinc_pub_00.dta", generate(_merge4)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/educ_00.dta", generate(_merge5)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/jobs_00.dta", generate(_merge7)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/wages_01_reshpae wide.dta", generate(_merge8)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/pact_00.dta",generate(_merge10)
merge 1:1 IDind wave using "${CHNS}CHNS_stata/EwmWedPrg.dta",generate(_merge11)



*age, t7(survey date)
*fully matched
replace age=. if age<0
gen age2=age^2
gen age3=age^3
gen minor=(age<18)
bys hhid wave: egen numkids=total(minor)

format IDind IDind_f IDind_m %12.0f
gen Age=int(age)
*line & IDind IDind_f _m _s, child A8(marital status) T1(province)
*  641  (_merge2==1)
gen single		=(A8==1) if inrange(A8,1,5)
gen married		=(A8==2) if inrange(A8,1,5)
gen divorced	=(A8==3) if inrange(A8,1,5)
gen widowed		=(A8==4) if inrange(A8,1,5)
gen separated	=(A8==5) if inrange(A8,1,5)

gen singlemother=0
replace singlemother=1 if (widowed==1 | separated==1) & numkids>0

gen MaritalStatus=0 if single==1
replace MaritalStatus=1 if married==1
replace MaritalStatus=2 if divorced==1
replace MaritalStatus=2 if separated==1
replace MaritalStatus=3 if widowed==1
gen outofmarriage=inlist(1,single, divorced, widowed, separated) if inrange(separated,0,1)




gen becamenohusband=0 if gender==2
replace becamenohusband=. if MaritalStatus==.
bys IDind (wave): replace becamenohusband=1 if MaritalStatus[_n-1]==1 & inrange(MaritalStatus[_n],2,3) & gender==2
*922 out of 17997women became no husband


gen Beijing=(T1==11)
gen Liaoning=(T1==21)
gen Heilongjiang=(T1==23)
gen Shanghai=(T1==31)
gen Jiangsu=(T1==32)
gen Shandong=(T1==37)
gen Henan=(T1==41)
gen Hubei=(T1==42)
gen Hunan=(T1==43)
gen Guangxi=(T1==45)
gen Guizhou=(T1==52)
gen Chongqing=(T1==55)

*****HUKOU
gen HukouUrban=(A8B1==1) if !missing(A8B1)
gen HukouRural=(A8B1==2) if !missing(A8B1)

gen RsdUrban=(T2==1)
gen RsdRural=(T2==2)
format IDind %12.0f
*only available from 1993
*drop if A8B1==.
bysort IDind (HukouUrban) : gen AlwaysUrban = (HukouUrban[1]== HukouUrban[_N] & HukouUrban[_N]==1)
bysort IDind (RsdUrban) : replace AlwaysUrban=0 if RsdUrban[1]==0 | RsdUrban[_N]==0

bysort IDind (HukouRural) : gen AlwaysRural = (HukouRural[1]== HukouRural[_N] & HukouRural[_N]==1)
bysort IDind (RsdRural) : replace AlwaysRural=0 if RsdRural[1]==0 | RsdRural[_N]==0


sort IDind HukouRural RsdUrban
bysort IDind (HukouRural) : gen Migrant = (HukouRural[1]== HukouRural & HukouRural==1 & RsdUrban==1)
bysort IDind (wave) : gen BecameUrban=(HukouRural[1]==1 & HukouUrban==1)

gen Tiers=1 if AlwaysUrban==1
replace Tiers =2 if BecameUrban==1
replace Tiers =3 if Migrant==1
replace Tiers =4 if AlwaysRural==1 



#delimit ;
label define relhead 0 "Head of Household"
1 "Spouse" 2 "Father/mother"
3 "Son/daughter"
4 "Brother/sister"
5 "Grandson (-in-law)/granddaughter (-in-law)"
6 "Father-in-law/mother-in-law"
7 "Son-in-law/daughter-in-law"
8 "Other relative"
9 "Maid"
10 "Other non-relative";

label values A5 relhead;

label define wherelivenow 
1 "Same Village/Neighborhood"
2 "Same County"
3 "Same City"
4 "Same Province"
5 "Other City/Province"
6 "Other Country"
7 "Dead";
label values AA13 wherelivenow;

label define province 
11 "Beijing, Added 2011"
21 "Liaoning, Missed 1997"
23 "Heilongjiang, Added 1997"
31 "Shanghai, Added 2011"
32 "Jiangsu"
37 "Shandong"
41 "Henan"
42 "Hubei"
43 "Hunan"
45 "Guangxi"
52 "Guizhou"
55 "Chongqing, Added 2011";
label values T1 province;
#delimit ;
label define maritalstatus
1 "Never married"
2 "Married"
3 "Divorced"
4 "Widowed"
5 "Separated";
label values A8 maritalstatus;

label variable weightforheight "Weight for height"


#delimit cr



*46,837  (_merge3==1)
*systol diastol heght weight diabetes hypertension stroke cancer types

gen SBP=(SYSTOL1+SYSTOL2+SYSTOL3)/3
gen DBP=(DIASTOL1+DIASTOL2+DIASTOL3)/3
*69877 missing values generated
/*
Adult hypertension was determined (according to the IDF cut point (SBP/DBP
≥140/90 mmHg) or taking blood pressure medication. For youth <18 years, hypertension
risk was defined as blood pressure above the 85th age, sex, and height-specific reference*/

*Prehypertension and hypertension is generated in prehypertension and hypertension_V1.do on 20151109

*growth
ren wave year

foreach y in 1989 1991 1993 1997 2000 2004 2006 2009 2011 {
gen year_`y'=(year==`y')
}




bys IDind (year): gen heightdif=height-height[_n-1] if minor==1
replace heightdif=0 if heightdif<0
gen year_h=year if height!=. 
bys IDind (year): gen yeardif=year_h-year_h[_n-1] if minor==1
gen growth=heightdif/yeardif

gen weightforheight=weight/height

gen bmi=weight/(height*.01)^2
*54269 missing values generated)
gen health=(5-U48A) if inrange(U48A,1,4)
tab health,gen(health)
*114243 missing values generated

****BMI categories
*net sj 13-2 dm0004_1
*net install dm0004_1
*net get dm0004_1
cd "/Users/kwync/Documents/Research/Z stata/"
replace bmi=. if bmi>46
replace bmi=. if bmi<10
drop if heightforage<-6
drop if heightforage>6

egen bcat = zbmicat(bmi), xvar(age) gender(gender) gencode(male=1, female=2) ageunit(year)
egen heightforage = zanthro(height,ha,WHO), xvar(age) gender(gender) gencode(male=1, female=2) ageunit(year)
egen weightforage = zanthro(weight, wa,US), xvar(age) gender(gender) gencode(male=1, female=2) ageunit(year)

gen overweight_c=bcat==1 if !missing(bcat)
gen obese_c=bcat==2 if !missing(bcat)
gen underweight_c=bcat<0 if !missing(bcat)
gen overweight_a=bmi>25 if !missing(bmi) & age>=18
gen obese_a=bmi>30 if !missing(bmi)& age>=18
gen underweight_a=bmi<18.5 if !missing(bmi)& age>=18

gen overweight=bcat==1 if !missing(bcat)
gen obese=bcat==2 if !missing(bcat)
gen underweight=bcat<0 if !missing(bcat)
replace overweight=bmi>25 if !missing(bmi) & age>=18
replace obese=bmi>30 if !missing(bmi)& age>=18
replace underweight=bmi<18.5 if !missing(bmi)& age>=18

gen OverWeightObese=overweight
replace OverWeightObese=1 if obese==1
replace OverWeightObese=1 if bmi>=25 & age>=18


replace heightforage=. if heightforage<-6
replace heightforage=. if heightforage>6

****************

gen drink		=(U40==1) if inrange(U40,0,1)
gen smoke		=(U25==1) if inrange(U25,0,1)
gen hypertension=(U22==1) if inrange(U22,0,1)
gen diabetes	=(U24A==1) if inrange(U24A,0,1)
gen myocardial	=(U24J==1) if inrange(U24J,0,1)
gen stroke		=(U24L==1) if inrange(U24L,0,1)
gen cancer		=(U24W ==1) if inrange(U24W,0,1)
gen asthma		=(U24Q ==1) if inrange(U24Q,0,1)

foreach h in $hlth {
tab `h' wave
}

gen puberty=0
replace puberty=1 if gender==2 & inrange(age,10,18)
replace puberty=1 if U20==1
replace puberty=0 if U20==0

replace puberty=1 if gender==1 & inrange(age,11,18)

gen Age05=inrange(age,0,5)


drop if IDind==.
*1,728  (_merge4==1)
ren hhsize hhsz
*1,787  missing
gen hhatt=hhinc_cpi
gen lgeqinc=log(hhinc_cpi/(hhsz)^.5)
gen hhatbt=hhincgross_cpi
gen hhexp=hhexpense_cpi
gen ehhatbt=hhatt/hhsz^.5
gen ehhatt=hhatt/hhsz^.5
*1728 missing values generated

forvalues i=1/10 {
gen incdec`i'=0
replace incdec`i'=. if ehhatt==.
}
_pctile ehhatt,n(10)
return list
forvalues i=1/10 {
local j=`i'-1
di `j' `i'
di r(r`j')
di r(r`i')
replace incdec`i'=1 if inrange(ehhatt,r(r`j'),r(r`i'))
}
gen incdec=.
forvalues i=1/10 {
replace incdec=`i' if incdec`i'==1
}


bys IDind (year): gen incdiff = ehhatbt-ehhatbt[_n-1]
bys IDind (year): gen incSF = -(ehhatbt-ehhatbt[_n-1])/ehhatbt[_n-1]
bys year: sum incdiff
bys IDind (year):gen IncSF25=incSF >.25 if !missing(incSF)

***Third income recent three cycles****
*drop IncLT IncDev Shock
gen ehhattp=ehhatt if ehhatt>=0
replace ehhattp=0 if ehhatt<0

bys IDind (year): gen L_ehhattp=ehhattp[_n-1]
bys IDind (year): gen L2_ehhattp=ehhattp[_n-2]
bys IDind (year): replace L_ehhattp=ehhattp[1] if L_ehhattp==.
bys IDind (year): replace L2_ehhattp=ehhattp[1] if L2_ehhattp==.

gen ehhattpRecent3=(ehhattp+L_ehhattp+L2_ehhattp)/3

gen ehhattpDev=(ehhattp-ehhattpRecent3)
gen ehhattpDevPercent=(ehhattp-ehhattpRecent3)/ehhattpRecent3

gen ehhattpDevN=-ehhattpDev if ehhattpDev<0
replace ehhattpDevN=0 if ehhattpDev>=0 & !missing(ehhattpDev)

gen ehhattpDevN2=ehhattpDevN^2
gen ShockN=ehhattpDevPercent<=0.25

*scale to 10,000
gen inc=ehhatt/10000
gen incp=ehhattp/10000
gen L_incp=L_ehhattp/10000
gen L2_incp=L2_ehhattp/10000
gen incpRecent3=ehhattpRecent3/10000
gen incpDev=ehhattpDev/10000
gen incpDevN=ehhattpDevN/10000
gen incpDevN2=incpDevN^2

***log
foreach v in incp incpRecent3 incpDevN {
gen lg_`v'=ln(`v')
}
replace lg_incpDevN=0 if incpDevN==0


gen diflginc=lg_incp-lg_incpRecent3
**Interaction*******
foreach v in inc incp incpRecent3 incpDev incpDevN {
gen Puberty_`v'=puberty*`v'
gen Age05_`v'=Age05*`v'
}






*38,597  (_merge5==1)

gen Nsch=(A12==0) if inrange(A12,0,6)
gen Psch=(A12==1) if inrange(A12,0,6)
gen Msch=(A12==2) if inrange(A12,0,6)
gen Hsch=(A12==3) if inrange(A12,0,6)
gen Voc=(A12==4) if inrange(A12,0,6)
gen Unv=(A12==5) if inrange(A12,0,6)
gen Grd=(A12==6) if inrange(A12,0,6)

gen UnvAbove=0 if inrange(A12,0,6)
replace UnvAbove=1 if Unv==1 | Grd==1

*gen UnvAbove_F=0 if inrange(A12_F,0,6)
*replace UnvAbove_F=1 if Unv_F==1 | Grd_F==1


*gen UnvAbove_M=0 if inrange(A12_M,0,6)
*replace UnvAbove_M=1 if Unv_M==1 | Grd_M==1
*41843 missing values generated


*keep if _merge7==3
gen work=(B2==1) if inrange(B2,0,1)
gen becamenojob =0
replace becamenojob =. if work==.
bys IDind (year): replace becamenojob=1 if work[_n-1]==1 & work[_n]==0 
replace work=1 if inrange(B6,1,9)


gen childdied=(S46==1) if !missing(S46)
gen numbirth=S47A
gen preg=S59 if inrange(S59,0,1)



gen TV=U340_MN+U341_MN
replace TV=U93_MN if missing(TV)

gen HrsPhyAct=U91 if inrange(U91,0,90)






gen ageinmonth=age*12
gen Ageinmonth=int(ageinmonth)
save "/Users/kwync/Dropbox/Weina/Fastfood/data/CHNS/OUTDATA/20160427_HouseholdCommunity_total.dta",replace

import excel "/Users/kwync/Documents/Research/CHNS/DATAOUTSIDE/median BMI who.xlsx", sheet("Sheet1") firstrow clear
merge 1:m Ageinmonth gender using "/Users/kwync/Dropbox/Weina/Fastfood/data/CHNS/OUTDATA/20160427_HouseholdCommunity_total.dta",gen(_medianbmi)
drop if _medianbmi==1
gen dvbmi=bmi-medianbmi
gen pctdvbmi=(bmi-medianbmi)/medianbmi

replace dvbmi=bmi-medianbmi
replace pctdvbmi=(bmi-medianbmi)/medianbmi
gen absdvbmi=abs(dvbmi)
gen abspctdvbmi=abs(pctdvbmi)

gen pctbmi=(bmi/medianbmi)
la var medianbmi "median BMI of age gender group"
la var dvbmi "bmi-median bmi"
la var pctbmi "(bmi-median)/median"

save "/Users/kwync/Dropbox/Weina/Fastfood/data/CHNS/OUTDATA/20160503_HouseholdCommunity_total_V2.dta"

qui destring,replace
gen rank=.

ds hhid year rank child line,not
foreach varP of var `r(varlist)' { 
di "`varP'"
capture gen byte `varP'_F = .
capture gen byte `varP'_M = .
by hhid year (IDind), sort: replace rank = _n
summarize rank, meanonly
forval i = 1 / `r(max)' {
                by hhid year: replace `varP'_F = `varP'[`i'] if IDind_f == IDind[`i'] & !missing(IDind_f)
                by hhid year: replace `varP'_M = `varP'[`i'] if IDind_m == IDind[`i'] & !missing(IDind_m)
				
}
}
save "${CHNS}OUTDATA/20160407_remerged_recoded_rematched_V7.dta",replace


*********DROP OUTLIERS********

drop if numkids==0
drop if age>=18
*drop if year==1989

drop if outofmarriage_M==1 & IDind_f!=.
 
****************************


drop if gender_F!=1
drop if gender_M!=2
drop if married_M!=1
drop if married_F!=1



***IPW*****
foreach y in 1989 1991 1993 1997 2000 2004 2006 2009 2011 {
gen year_`y'=(year==`y')
}

foreach t in 1989 1991 1993 1997 2000 2004 2006 2009 2011 {
gen sample`t'=1 if year_`t'==1
tab sample`t' year
bys IDind (sample`t'): replace sample`t'=sample`t'[1]
tab sample`t' year
}

capture drop sample`t'
capture drop sample89
gen sample89=1 if year==1989
replace sample89=1 if year==1991
replace sample89=1 if year==1993
bys IDind (sample89): replace sample89=sample89[1]
gen sample`t'=1 if year>=19`t'
bys IDind (sample`t'): replace sample`t'=sample`t'[1]
replace sample`t'=0 if sample`t'==.
replace sample`t'=. if sample89!=1
capture drop prob`t' w`t' ipw`t'
logit sample`t' $ipw,vce(cluster hhid)
predict prob`t' if !missing(sample`t'),pr
gen w`t'=.
replace w`t'=1/prob`t'
bys IDind (year): gen ipw`t'=w`t'[1]
bys IDind (year): replace ipw`t'=w`t'[2] if ipw`t'==.

sort IDind year
list IDind year sample89 sample97 prob97 w97 ipw97 in 1000/1100

*******、、

*LIVING ARRANGEMENT***

gen FatherLivesHome=A5A
gen MotherLivesHome=A5C
gen ParentsLiveHome=(FatherLivesHome==1 & MotherLivesHome==1) if !missing(FatherLivesHome,MotherLivesHome)
gen ParentsNotHome		=(FatherLivesHome==0 & MotherLivesHome==0) if !missing(FatherLivesHome,MotherLivesHome)
gen FatherHomeMotherNot=(FatherLivesHome==1 & MotherLivesHome==0) if !missing(FatherLivesHome,MotherLivesHome)
gen MotherHomeFatherNot=(FatherLivesHome==0 & MotherLivesHome==1) if !missing(FatherLivesHome,MotherLivesHome)
gen MotherAway=0  if !missing(FatherLivesHome,MotherLivesHome)
replace MotherAway=1 if MotherLivesHome==0
gen FatherAway=0  if !missing(FatherLivesHome,MotherLivesHome)
replace FatherAway=1 if FatherLivesHome==0



***FREQ FASTFOOD INTAKE******
gen coke=0 if U233==0
replace coke=U234
replace coke=. if U234<0
la var coke "drinking non-chinese soft drink (Liter/week)"
gen fastfoodfreq=U367
replace fastfoodfreq=. if U367<0
la var fastfoodfreq "Times eating at nonChinese Fastfood in last three months"
gen likeFastfood=U389
replace likeFastfood=0 if U389==9
la var likeFastfood "How much do you like fast food"
la define lff 0 "never eat" 1 "not at all" 2 "not much" 3 "somewhat like" 4 "like it very much"
la values likeFastfood lff



drop if IDind==.
xtset IDind year

mean coke fastfoodfreq likeFastfood,over(year)

foreach v in coke fastfoodfreq likeFastfood {
preserve
drop if year<2004
collapse (mean) mean`v'= `v' (sd) sd`v'=`v' (count) n=`v', by(year)
generate hi`v' = mean`v' + invttail(n-1,0.025)*(sd`v' / sqrt(n))
generate lo`v' = mean`v' - invttail(n-1,0.025)*(sd`v' / sqrt(n))
twoway (rarea hi`v' lo`v' year,astyle(ci)) (line mean`v' year,lwidth(vthick)), ///
	  	xlabel( 2004 "2004" 2006 "2006" 2009 "2009" 2011 "2011", noticks) ///	  
       legend(label(1 "95% CI") label(2 "Mean")) note("Source:  CHNS 2004-2011.") 
graph export "${CHNS}GRAPH/20160510_FASTFOOD_`v'.pdf",replace
restore 
}
 
