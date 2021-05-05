/* H4. Baby Facts - Updated
Name: Stephanie D. Cheng
Date Created: 6-4-20
Date Updated: 10-14-20

This .do file performs analysis for the children paper.

*/

global FIELD "Bio Sciences"

global MAIN "H:/SDC_Postdocs"
global DATA "${MAIN}/Data"
global RESULTS "${MAIN}/Results/Baby Facts/FINAL BABY TABLES"
global TEMP "${MAIN}/Temp"
global LOOKUPS "${MAIN}/Lookups"
global NFD "${RESULTS}/Not For Disclosure"

global COUNT "${TEMP}/Count Tables"
global TOCLEAN "${TEMP}/Clean for Disclosure"

********************************

*** 1. Summary Statistics of When Have Kids ***

// YOB range check
use "${DATA}/OOI_workingsample.dta", clear

	// Keep one copy for each refid
	keep refid phd_supField phdcy_min yob_*
	duplicates drop

	// How large is range for first child
	gen yob_1range = yob_1late - yob_1early
	sum yob_1range, d
	tab yob_1range
	tab yob_1range if phdcy_min>=1990 & phdcy_min<2000
	
	sum yob_1range if phd_supField=="Bio Sciences", d
	tab yob_1range if phd_supField=="Bio Sciences"
	
	tab yob_1range if phdcy_min>=1990 & phdcy_min<2000 & phd_supField=="Bio Sciences"

// # of Children
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField=="${FIELD}"
keep if phdcy_min>=1990 & phdcy_min<2000

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)
	bys refid: egen everChildTEST = max(anyChildORIG)
	
	// # of Children if have kids
	merge m:1 refid using "${TEMP}/NumOfKids.dta"
	drop if _merge==2

	// When Have Children
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Determine age at child
	gen parentAge = yob_1avg - byear
	
	// Identify 0-5 Yrs Post-PhD, 6-10 Yrs Post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0 & everChild==1
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5 & everChild==1
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10 & everChild==1
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=. & everChild==1

	keep refid everChild totCh male wtsurvy1_f whenKids PhDto1Child parentAge
	duplicates drop
	
	tab everChild male [aw=wtsurvy1_f], col
	tab whenKids male [aw=wtsurvy1_f] if whenKids!="Never" & whenKids!="", col

	sum male
	bys male: sum totCh PhDto1Child parentAge [aw=wtsurvy1_f]	

// Other Worker Characteristics
	use "${DATA}/OOI_workerchar.dta", clear
	keep if STEM==1
	keep if phd_supField=="${FIELD}"
	keep if phdcy_min>=1990 & phdcy_min<2000

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)
	
	// When Have Children
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Determine age at child
	gen parentAge = yob_1avg - byear
	
	// Identify 0-5 Yrs Post-PhD, 6-10 Yrs Post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0 & everChild==1
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5 & everChild==1
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10 & everChild==1
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=. & everChild==1
	
	// Has professional degree at time of PhD graduation
	gen indProf = (profdeg!=.)
	
	// Keep one copy
	keep refid male everChild whenKids R_* USnative bacarn_* macarn_* phdcarn_* gradYrs indProf wtsurvy1_f
	duplicates drop
	
	// Save non-changing characteristics
	bys male everChild: sum R_* USnative *carn_* gradYrs indProf [aw=wtsurvy1_f]
	bys male everChild: sum R_* USnative *carn_* gradYrs indProf // unweighted for disclosure checks
	
	bys male whenKids: sum *carn_* [aw=wtsurvy1_f]
	
	// Citizenship at graduation
		use "${DATA}/OOI_workerchar.dta", clear
		keep if STEM==1
		keep if phd_supField=="${FIELD}"
		keep if phdcy_min>=1990 & phdcy_min<2000
		
		// Ever Have Children
		bys refid: egen everChild = max(anyChild)
		
		keep if phdcy_min==refyr
	
		bys male everChild: sum US* [aw=wtsurvy1_f]
		bys male everChild: sum US* // unweighted for disclosure checks
		
// Job Experience
	use "${DATA}/OOI_workerchar.dta", clear
	keep if STEM==1
	keep if phd_supField=="${FIELD}"
	keep if phdcy_min>=1990 & phdcy_min<2000

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)
	
	// Job type experience
	foreach i in PD AC TE GV ID NP UN NL {
		bys refid: egen MAXyrs`i' = max(yrs`i')
		replace MAXyrs`i' = . if MAXyrs`i'==0
		gen ever`i' = MAXyrs`i'!=.
	}
	
	// Keep one copy	
	keep refid male ever* MAX* wtsurvy1_f
	duplicates drop
	
	bys male everChild: sum ever* MAX* [aw=wtsurvy1_f]	
	bys male everChild: sum ever* MAX* // for disclosure purposes

// Job Characteristics
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField=="${FIELD}"
keep if phdcy_min>=1990 & phdcy_min<2000

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)	
	
	// Keep if actual job
	keep if jobID!=.
	
		// Summarize overall sample
		tab male everChild
		
		bys male everChild: sum SAL* jobins jobpens jobproft jobvac ///
			hrswk fullTimeP act* wa* mgr* sup* tenured ocedrlp_n sat* [aw=wtsurvy1_f]
				
		bys male everChild: tab wapri if wapri!="L" & wapri!="LL"

// Reasons for Working
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField=="${FIELD}"
keep if phdcy_min>=1990 & phdcy_min<2000

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)	
	
	// Summarize overall sample
	tab male everChild
	
	bys male everChild: sum sp* ch* nr* nw* pt* [aw=wtsurvy1_f]
	bys male everChild: sum sp* ch* nr* nw* pt*	// unweighted for disclosure purposes
		
	bys male everChild: sum sat* [aw=wtsurvy1_f]
	
*** 2. Job Type by Timing of First Child - Figs. 2, 4, 7a ***
use "${DATA}/OOI_fullsample.dta", clear

	// Drop if no refyr (not entirely sure how this occurred...)
	drop if refyr==.

	// Exit survey at age 76; only keep if it's a DRF or SDR original
	drop if age>76 & age!=. & SDRorig==. & DRForig==.

	// Keep only STEM
	keep if STEM==1

	keep if phd_supField == "${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Keep within 10 years before/after having kid
	keep if yrsTo1Child>=-10 & yrsTo1Child<=10
	
	// Create indicator for before complete PhD
	gen indGR = (refyr<phdcy_min)
	
	// Create job indicators
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i' = (`i'i>0 & `i'i!=.)
	}
	gen indNI = (indGR==0 & indPD==0 & indAC==0 & indTE==0 & indGV==0 & indID==0 & indNP==0 & indUN==0 & indNL==0)
	
	// Keep only if have job info or still in grad school
	drop if indNI==1	
	
	// Normalize
	egen totNum = rowtotal(ind*)
	foreach i in GR PD AC TE GV ID NP UN NL {
		gen ind`i'_n = ind`i' / totNum
	}
	
	// Drop before 1960
	drop if phdcy_min<1960
	
	// Count # of individuals in each job type in each decade + years to 1st baby
	gen count = 1
	collapse (mean) m_indGR=indGR_n m_indPD=indPD_n m_indAC=indAC_n m_indTE=indTE_n m_indGV=indGV_n m_indID=indID_n m_indNP=indNP_n m_indUN=indUN_n m_indNL=indNL_n ///
			(sem) se_indGR=indGR_n se_indPD=indPD_n se_indAC=indAC_n se_indTE=indTE_n se_indGV=indGV_n se_indID=indID_n se_indNP=indNP_n se_indUN=indUN_n se_indNL=indNL_n ///
			(sum) count [aw=wtsurvy1_f], by(phdcy_DEC yrsTo1Child male)

	// Create error bars
	foreach i in GR PD AC TE ID NP GV NL UN {
		gen ind`i'_hi = m_ind`i' + invttail(count-1,0.025)*se_ind`i'
		gen ind`i'_lo = m_ind`i' - invttail(count-1,0.025)*se_ind`i'			
	}		
	
	label define male 0 "Female" 1 "Male"
	label val male male	
	
	label var yrsTo1Child "Years to First Child Birth"	
	
	/* Graduate Student -> not used
		twoway (scatter m_indGR yrsTo1Child if count>=50 & m_indGR!=. & m_indGR*count>=5 & (1-m_indGR)*count>=5  & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indGR_hi indGR_lo yrsTo1Child if count>=50 & m_indGR!=. & m_indGR*count>=5 & (1-m_indGR)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
				(scatter m_indGR yrsTo1Child if count>=50 & m_indGR!=. & m_indGR*count>=5 & (1-m_indGR)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indGR_hi indGR_lo yrsTo1Child if count>=50 & m_indGR!=. & m_indGR*count>=5 & (1-m_indGR)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
				legend(order(1 "Female" 3 "Male")) title("Percent Pre-PhD Within 10 Years of 1st Child's Birth", size(medlarge)) subtitle("For 1990s ${FIELD} PhDs by Gender") ///
				ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/PerGR Child Birth ${FIELD} 1990s.eps", as(png) replace	
	*/
		
	// Postdoc
	twoway (scatter m_indPD yrsTo1Child if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indPD_hi indPD_lo yrsTo1Child if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indPD yrsTo1Child if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indPD_hi indPD_lo yrsTo1Child if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction Postdoc", size(medlarge)) ///
			ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)	
	graph export "${RESULTS}/PerPD Child Birth ${FIELD} 1990s.pdf", as(pdf) replace
	
	// Tenure-Track
	twoway (scatter m_indAC yrsTo1Child if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indAC_hi indAC_lo yrsTo1Child if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indAC yrsTo1Child if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indAC_hi indAC_lo yrsTo1Child if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction Academic Tenure-Track", size(medlarge)) ///
			ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)
	graph export "${RESULTS}/PerAC Child Birth ${FIELD} 1990s.pdf", as(pdf) replace
	
	// Non-Tenure Track
	twoway (scatter m_indTE yrsTo1Child if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indTE_hi indTE_lo yrsTo1Child if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indTE yrsTo1Child if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indTE_hi indTE_lo yrsTo1Child if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction Non-Tenure Track", size(medlarge)) ///
			ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)	
	graph export "${RESULTS}/PerTE Child Birth ${FIELD} 1990s.pdf", as(pdf) replace	
	
	// Industry
	twoway (scatter m_indID yrsTo1Child if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indID_hi indID_lo yrsTo1Child if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indID yrsTo1Child if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indID_hi indID_lo yrsTo1Child if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction Industry", size(medlarge)) ///
			ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)	
	graph export "${RESULTS}/PerID Child Birth ${FIELD} 1990s.pdf", as(pdf) replace	
	
	// Out of Labor Force
	twoway (scatter m_indNL yrsTo1Child if count>=50 & m_indNL!=. & m_indNL*count>5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indNL_hi indNL_lo yrsTo1Child if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indNL yrsTo1Child if count>=50 & m_indNL!=. & m_indNL*count>5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indNL_hi indNL_lo yrsTo1Child if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction Not in Labor Force", size(medlarge)) ///
			ytitle("Fraction of Group") xlab(-10(2)10) graphregion(color(white)) bgcolor(white)	
	graph export "${RESULTS}/PerNL Child Birth ${FIELD} 1990s.pdf", as(pdf) replace	
					
	****************************************
	
	// Create count table
	preserve
		foreach i in GR PD AC TE GV ID NP UN NL {
			gen n_ind`i' = m_ind`i'*count
			replace n_ind`i' = . if n_ind`i'<5
		}
	
		// Drop ones not submitting for disclosure (GV, NP, UN)
		drop n_indGV n_indNP n_indUN
		keep if phdcy_DEC==1980 | phdcy_DEC==1990 | phdcy_DEC==2000

		keep phdcy_DEC male yrsTo1Child n_ind* count
		save "${COUNT}/${FIELD} BabyFacts Job Types.dta", replace
	
	restore
	*****************************************

*** 3. Hours Worked by Timing of First Child - Fig. 7b ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Keep within 10 years before/after having kid
	keep if yrsTo1Child>=-10 & yrsTo1Child<=10
	
	// Drop before 1960
	drop if phdcy_min<1960
	
	// Average of hours worked
	gen count = 1
	collapse (mean) m_hrswk=hrswk (sem) se_hrswk=hrswk (p50) p50_hrswk=hrswk (p25) p25_hrswk=hrswk (p75) p75_hrswk=hrswk ///
				(sum) count [aw=wtsurvy1_f], by(male phdcy_DEC yrsTo1Child)
		
	// Create error bars
	foreach i in hrswk {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}	
	
	twoway (scatter m_hrswk yrsTo1Child if count>=50 & m_hrswk!=. & phdcy_DEC==1990 & male==0, color(maroon)) (rcap hrswk_hi hrswk_lo yrsTo1Child if count>=50 & m_hrswk!=. & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_hrswk yrsTo1Child if count>=50 & m_hrswk!=. & phdcy_DEC==1990 & male==1, color(navy)) (rcap hrswk_hi hrswk_lo yrsTo1Child if count>=50 & m_hrswk!=. & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Hours Worked", size(medlarge)) ///
			ytitle("Weekly Hours") xlab(-10(2)10) ylab(30(5)60) xtitle("Years to First Child Birth") graphregion(color(white)) bgcolor(white)	
	graph export "${RESULTS}/HrsWk Child Birth ${FIELD}.pdf", as(pdf) replace

*** 4. Salary by Timing of First Child - Fig. 11 ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Keep within 10 years before/after having kid
	keep if yrsTo1Child>=-10 & yrsTo1Child<=10

	// Drop before 1960
	drop if phdcy_min<1960
	
	// Divide salary by 1000 to make easier to read
	gen SAL1000 = SALi_Adj/1000
	
	// Collapse on adjusted salary
	gen count = 1
	collapse (mean) meanSAL1000=SAL1000 (sem) seSAL1000=SAL1000 ///
			(sum) count [aw=wtsurvy1_f], by(phdcy_DEC yrsTo1Child male)
			
	// Create error bars
	gen SAL1000hi = meanSAL1000 + invttail(count, 0.025)*seSAL1000
	gen SAL1000lo = meanSAL1000 - invttail(count, 0.025)*seSAL1000 
	
	// Graph salary by years 
	twoway (scatter meanSAL1000 yrsTo1Child if count>=50 & male==0 & phdcy_DEC==1990, mcolor(maroon)) (rcap SAL1000hi SAL1000lo yrsTo1Child if count>=50 & male==0 & phdcy_DEC==1990, lcolor(maroon)) ///
			(scatter meanSAL1000 yrsTo1Child if count>=50 & male==1 & phdcy_DEC==1990, mcolor(navy)) (rcap SAL1000hi SAL1000lo yrsTo1Child if count>=50 & male==1 & phdcy_DEC==1990, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Salary") ytitle("Salary (Thousands of 2015 Dollars)", size(medium)) xlab(-10(2)10) xtitle("Years to 1st Child Birth") ///
			graphregion(color(white)) bgcolor(white)
	graph export "${RESULTS}/Salary Child Birth ${FIELD}.pdf", as(pdf) replace	
	
*** 5. Group by When Have Kids (Never, Pre-PhD, 0-5 Yrs Post, 6-10 Yrs Post) - Figs. 1, 3, 5, 6, 8 ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField=="${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Determine ever have child
	bys refid: egen everChild = max(anyChild)
	
	// Split sample into 0 children, child pre-PhD, child 0-5 yrs post-PhD, child 6-10 yrs post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=.

	// Make numeric so can order properly
	gen whenKidsNum = .
	replace whenKidsNum = 0 if whenKids=="Never"
	replace whenKidsNum = 1 if whenKids=="PrePhD"
	replace whenKidsNum = 2 if whenKids=="Post05"
	replace whenKidsNum = 3 if whenKids=="Post610"
	replace whenKidsNum = 4 if whenKids=="Post11"

	label define whenKids 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs Post-PhD" 3 "6-10 Yrs Post-PhD" 4 "11+ Yrs Post-PhD", replace
	label val whenKidsNum whenKids
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Determine years since PhD
	gen yrsOut = refyr - phdcy_min
	
	// Only keep first 10 years after PhD
	keep if yrsOut>=0 & yrsOut<=10
	
	// Create job indicators
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i' = (`i'i>0 & `i'i!=.)
	}
	gen indNI = (indPD==0 & indAC==0 & indTE==0 & indGV==0 & indID==0 & indNP==0 & indUN==0 & indNL==0)
	
	// Keep only if have job info
	drop if indNI==1

	// Normalize
	egen totNum = rowtotal(ind*)
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i'_n = ind`i' / totNum
	}
	
	// Drop before 1960
	drop if phdcy_min<1960
	
	// Make salary in thousands of dollars so easier to read axes
	gen SAL1000 = SALi_Adj/1000
	
	// Count # of individuals in each job type in each decade + years to 1st baby
	gen count = 1
	collapse (mean) m_indPD=indPD_n m_indAC=indAC_n m_indTE=indTE_n m_indGV=indGV_n m_indID=indID_n m_indNP=indNP_n m_indUN=indUN_n m_indNL=indNL_n m_SAL1000=SAL1000 m_hrswk=hrswk ///
			(sem) se_indPD=indPD_n se_indAC=indAC_n se_indTE=indTE_n se_indGV=indGV_n se_indID=indID_n se_indNP=indNP_n se_indUN=indUN_n se_indNL=indNL_n se_SAL1000=SAL1000 se_hrswk=hrswk ///
			(sum) count [aw=wtsurvy1_f], by(phdcy_DEC yrsOut male whenKids*)

	// Create error bars
	foreach i in PD AC TE ID NP GV NL UN {
		gen ind`i'_hi = m_ind`i' + invttail(count-1,0.025)*se_ind`i'
		gen ind`i'_lo = m_ind`i' - invttail(count-1,0.025)*se_ind`i'			
	}	
	foreach i in SAL1000 hrswk {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'
	}

	label define male 0 "Female" 1 "Male"
	label val male male	
	
	label var yrsOut "Years Since PhD"	
	
	// For now, don't worry about kids 11+ yrs postPhD
	drop if whenKids=="Post11"
		
	*** 5a. Tenure-Track: Create separate graphs for each - Figs. 1, 3 ***
		twoway (scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Never", color(maroon)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Never", lcolor(maroon)) ///
			(scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Never", color(navy)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Never", lcolor(navy)), ///
			title("Fraction Academic Tenure-Track") subtitle("Among PhDs Who Never Have Children") xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.1).5) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/AC No Kids.pdf", as(pdf) replace
	
		twoway (scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="PrePhD", color(maroon)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="PrePhD", lcolor(maroon)) ///
			(scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="PrePhD", color(navy)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="PrePhD", lcolor(navy)), ///
			title("Fraction Academic Tenure-Track") subtitle("Among PhDs Whose First Child Pre-PhD") xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.1).5) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/AC PrePhD.pdf", as(pdf) replace		
		
		twoway (scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post05", color(maroon)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post05", lcolor(maroon)) ///
			(scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post05", color(navy)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post05", lcolor(navy)), ///
			title("Fraction Academic Tenure-Track") subtitle("Among PhDs Whose First Child 0-5 Years Post-PhD") xtitle("Years Since PhD") ylab(0(.1).5) xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/AC 05 Years.pdf", as(pdf) replace
			
		twoway (scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post610", color(maroon)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post610", lcolor(maroon)) ///
			(scatter m_indAC yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post610", color(navy)) (rcap indAC_hi indAC_lo yrsOut if count>=50 & m_indAC!=. & m_indAC*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post610", lcolor(navy)), ///
			title("Fraction Academic Tenure-Track") subtitle("Among PhDs Whose First Child 6-10 Years Post-PhD") xtitle("Years Since PhD") ylab(0(.1).5) xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/AC 610 Years.pdf", as(pdf) replace	
	
	*** 5b. Out of Labor Force: Create separate graphs for each - Figs. 6a, 8a ***
		twoway (scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Never", color(maroon)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Never", lcolor(maroon)) ///
			(scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Never", color(navy)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Never", lcolor(navy)), ///
			title("Fraction Not in Labor Force") subtitle("Among PhDs Who Never Have Children") xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.05).15) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/NL No Kids.pdf", as(pdf) replace	
	
		twoway (scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="PrePhD", color(maroon)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="PrePhD", lcolor(maroon)) ///
			(scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="PrePhD", color(navy)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="PrePhD", lcolor(navy)), ///
			title("Fraction Not in Labor Force") subtitle("Among PhDs Whose First Child Pre-PhD") xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.05).15) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/NL PrePhD.pdf", as(pdf) replace	
	
		twoway (scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post05", color(maroon)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post05", lcolor(maroon)) ///
			(scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post05", color(navy)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post05", lcolor(navy)), ///
			title("Fraction Not in Labor Force") subtitle("Among PhDs Whose First Child 0-5 Years Post-PhD")xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.05).15) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/NL 05 Years.pdf", as(pdf) replace	
	
		twoway (scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post610", color(maroon)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post610", lcolor(maroon)) ///
			(scatter m_indNL yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post610", color(navy)) (rcap indNL_hi indNL_lo yrsOut if count>=50 & m_indNL!=. & m_indNL*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post610", lcolor(navy)), ///
			title("Fraction Not in Labor Force") subtitle("Among PhDs Whose First Child 6-10 Years Post-PhD") xtitle("Years Since PhD") xlab(0(1)10) ylab(0(.05).15) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/NL 610 Years.pdf", as(pdf) replace	
	
	*** 5c. Hours Worked: Create separate graphs for each - Fig. 6b, 8b ***
		twoway (scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Never", color(maroon)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Never", lcolor(maroon)) ///
			(scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Never", color(navy)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Never", lcolor(navy)), ///
			title("Hours Worked") subtitle("Among PhDs Who Never Have Children")  xtitle("Years Since PhD") xlab(0(1)10) ytitle("Weekly Hours") ylab(35(5)60) legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/Hrswk No Kids.pdf", as(pdf) replace	
	
		twoway (scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="PrePhD", color(maroon)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="PrePhD", lcolor(maroon)) ///
			(scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="PrePhD", color(navy)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="PrePhD", lcolor(navy)), ///
			title("Hours Worked") subtitle("Among PhDs Who First Child Pre-PhD") xtitle("Years Since PhD") xlab(0(1)10) ytitle("Weekly Hours") ylab(35(5)60) legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/Hrswk PrePhD.pdf", as(pdf) replace	
	
		twoway (scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post05", color(maroon)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post05", lcolor(maroon)) ///
			(scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post05", color(navy)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post05", lcolor(navy)), ///
			title("Hours Worked") subtitle("Among PhDs Who First Child 0-5 Years Post-PhD") xtitle("Years Since PhD") xlab(0(1)10) ytitle("Weekly Hours") ylab(35(5)60) legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/Hrswk 05 Years.pdf", as(pdf) replace		
		
		twoway (scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0 & whenKids=="Post610", color(maroon)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==0  & whenKids=="Post610", lcolor(maroon)) ///
			(scatter m_hrswk yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1 & whenKids=="Post610", color(navy)) (rcap hrswk_hi hrswk_lo yrsOut if count>=50 & m_hrswk!=. & m_hrswk*count>=5 & phdcy_DEC==1990 & male==1  & whenKids=="Post610", lcolor(navy)), ///
			title("Hours Worked") subtitle("Among PhDs Who First Child 6-10 Years Post-PhD") xtitle("Years Since PhD") xlab(0(1)10) ytitle("Weekly Hours") ylab(35(5)60) legend(order(1 "Female" 3 "Male")) graphregion(color(white)) bgcolor(white)
		graph export "${RESULTS}/Hrswk 610 Years.pdf", as(pdf) replace			
	
	*** 5d. Postdoc, Industry, Non-Tenure Track: Grouped graphs - Fig. 5 ***
	
		// Postdoc
		twoway (scatter m_indPD yrsOut if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indPD_hi indPD_lo yrsOut if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_indPD yrsOut if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indPD_hi indPD_lo yrsOut if count>=50 & m_indPD!=. & m_indPD*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			by(whenKidsNum, title("Fraction Postdoc") note("") graphregion(color(white)) bgcolor(white)) xtitle("Years Since PhD") xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) 
		graph export "${RESULTS}/PerPD 10 Years by Kids Gender ${FIELD} 1990s.pdf", as(pdf) replace
			
		// Non-Tenure Track
		twoway (scatter m_indTE yrsOut if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indTE_hi indTE_lo yrsOut if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
				(scatter m_indTE yrsOut if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indTE_hi indTE_lo yrsOut if count>=50 & m_indTE!=. & m_indTE*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
				by(whenKidsNum, title("Fraction Non-Tenure Track") note("") graphregion(color(white)) bgcolor(white)) xtitle("Years Since PhD") xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) 
		graph export "${RESULTS}/PerTE 10 Years by Kids Gender ${FIELD} 1990s.pdf", as(pdf) replace	
		
		// Industry
		twoway (scatter m_indID yrsOut if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap indID_hi indID_lo yrsOut if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
				(scatter m_indID yrsOut if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap indID_hi indID_lo yrsOut if count>=50 & m_indID!=. & m_indID*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
				by(whenKidsNum, title("Fraction Industry") note("") graphregion(color(white)) bgcolor(white)) xtitle("Years Since PhD") xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male")) 
		graph export "${RESULTS}/PerID 10 Years by Kids Gender ${FIELD} 1990s.pdf", as(pdf) replace	
		
*** 6a. Hours Worked by Job Type and When Have Kids - Fig. 9 ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)	
	
	// When Have Children
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Identify 0-5 Yrs Post-PhD, 6-10 Yrs Post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0 & everChild==1
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5 & everChild==1
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10 & everChild==1
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=. & everChild==1

	label define male 0 "Female" 1 "Male"
	label val male male	

	// Combine pjUN=. with pjUN=0
	replace pjUN=0 if pjUN==.
	
	// Collapse hours worked by principal job
	gen count = 1
	collapse (mean) m_hrswk=hrswk (sem) se_hrswk=hrswk ///
			(sum) count [aw=wtsurvy1_f], by(pj* male whenKids)
	
	// Create error bars
	foreach i in hrswk {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}		
	
	// Keep only the single principal job groups
	egen tempTot = rowtotal(pj*)
	keep if tempTot==1
	
	gen pj = "PD" if pjPD==1
	foreach i in AC TE ID NP GV NL UN {
		replace pj = "`i'" if pj`i'==1
	}
	order pj m_* se_* count *_hi *_lo
	
	// Graph order
	gen pjOrder = 1 if pj=="PD"
	replace pjOrder = 2 if pj=="AC"
	replace pjOrder = 3 if pj=="TE"
	replace pjOrder = 4 if pj=="ID"
	replace pjOrder = 5 if pj=="NP"
	replace pjOrder = 6 if pj=="GV"
	
	// Make numeric so can order properly
	gen whenKidsNum = 0 if whenKids=="Never"
	replace whenKidsNum = 1 if whenKids=="PrePhD"
	replace whenKidsNum = 2 if whenKids=="Post05"
	replace whenKidsNum = 3 if whenKids=="Post610"
	
	// Label for better graphs
	label define whenKids 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs", replace
	label val whenKidsNum whenKids

	label define jobType 1 "Postdoc" 2 "Ten-Track (TT)" 3 "Non-TT" 4 "For-Profit" 5 "Non-Profit" 6 "Government", modify
	label val pjOrder jobType	
	
	// Graph hrswk by job type and when have kids
	twoway (scatter m_hrswk whenKidsNum if pj=="PD" & count>=50 & whenKidsNum!=., color(gold) msymbol(Th)) (rcap hrswk_hi hrswk_lo whenKidsNum if pj=="PD" & count>=50 & whenKidsNum!=., lcolor(gold)) ///
			(scatter m_hrswk whenKidsNum if pj=="AC" & count>=50 & whenKidsNum!=., color(navy) msymbol(Oh)) (rcap hrswk_hi hrswk_lo whenKidsNum if pj=="AC" & count>=50 & whenKidsNum!=., lcolor(navy)) ///
			(scatter m_hrswk whenKidsNum if pj=="TE" & count>=50 & whenKidsNum!=., color(purple) msymbol(Dh)) (rcap hrswk_hi hrswk_lo whenKidsNum if pj=="TE" & count>=50 & whenKidsNum!=., lcolor(purple)) ///
			(scatter m_hrswk whenKidsNum if pj=="ID" & count>=50 & whenKidsNum!=., color(maroon) msymbol(Sh)) (rcap hrswk_hi hrswk_lo whenKidsNum if pj=="ID" & count>=50 & whenKidsNum!=., lcolor(maroon)), ///
			by(male, graphregion(color(white)) bgcolor(white) title("Hours Worked in Each Job Type") note("")) ///
			legend(order(1 "Postdoc" 3 "Tenure-Track" 5 "Non-Tenure Track" 7 "Industry")) xlab(-0.5 " " 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs" 3.5 " ") xtitle("Timing of First Child") ytitle("Weekly Hours")
	graph export "${RESULTS}/Hrswk by Job WhenKids ${FIELD}.pdf", as(pdf) replace

		// Create Counts Table
		preserve
		
			// Only graphing PD, AC, TE, ID
			keep if pj=="PD" | pj=="AC" | pj=="TE" | pj=="ID"
			
			// Only graphing if have kid info
			keep if whenKidsNum!=.
			
			rename count pop
			keep pj whenKidsNum m_hrswk se_hrswk pop
			
			save "${COUNT}/${FIELD} HrsWk by Job WhenKids.dta", replace
			
		restore			
	
*** 6b. Work Activities by Job Type and When Have Kids - Fig. 10 ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)	
	
	// When Have Children
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Identify 0-5 Yrs Post-PhD, 6-10 Yrs Post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0 & everChild==1
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5 & everChild==1
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10 & everChild==1
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=. & everChild==1

	label define male 0 "Female" 1 "Male"
	label val male male	

	// Combine pjUN=. with pjUN=0
	replace pjUN=0 if pjUN==.
	
	// Tabulate wapri to create indicators
	tab wapri, gen(wapri_)
	
	// Combine pjUN=. with pjUN=0
	replace pjUN=0 if pjUN==.
	
		// Prepare unweighted numbers for disclosure purposes
		preserve
			gen count = 1
			collapse (sum) m_wapri_2=wapri_2 m_wapri_3=wapri_3 m_wapri_8=wapri_8 m_wapri_13=wapri_13 count, by(pj* male whenKids)
			
			rename m_* un_n_*
			rename count un_count
			
			save "${TEMP}/Unweighted Work Activities.dta", replace
		restore
	
	// Collapse work activity variables by principal job
	gen count = 1
	collapse (mean) m_wapri_2=wapri_2 m_wapri_3=wapri_3 m_wapri_8=wapri_8 m_wapri_13=wapri_13 ///
			(sem) se_wapri_2=wapri_2 se_wapri_3=wapri_3 se_wapri_8=wapri_8 se_wapri_13=wapri_13 ///
			(sum) count [aw=wtsurvy1_f], by(pj* male whenKids)
	
		// Merge in unweighted numbers
		merge 1:1 pj* male whenKids using "${TEMP}/Unweighted Work Activities.dta"
	
	// Create error bars
	foreach i in wapri_2 wapri_3 wapri_8 wapri_13 {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}		
	
	// Keep only the single principal job groups
	egen tempTot = rowtotal(pj*)
	keep if tempTot==1
	
	gen pj = "PD" if pjPD==1
	foreach i in AC TE ID NP GV NL UN {
		replace pj = "`i'" if pj`i'==1
	}
	order pj m_* se_* count *_hi *_lo
	
	// Graph order
	gen pjOrder = 1 if pj=="PD"
	replace pjOrder = 2 if pj=="AC"
	replace pjOrder = 3 if pj=="TE"
	replace pjOrder = 4 if pj=="ID"
	replace pjOrder = 5 if pj=="NP"
	replace pjOrder = 6 if pj=="GV"
	
	// Make numeric so can order properly
	gen whenKidsNum = 0 if whenKids=="Never"
	replace whenKidsNum = 1 if whenKids=="PrePhD"
	replace whenKidsNum = 2 if whenKids=="Post05"
	replace whenKidsNum = 3 if whenKids=="Post610"
	
	// Label for better graphs
	label define whenKids 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs", replace
	label val whenKidsNum whenKids

	label define jobType 1 "Postdoc" 2 "Ten-Track (TT)" 3 "Non-TT" 4 "For-Profit" 5 "Non-Profit" 6 "Government", modify
	label val pjOrder jobType	
	
	// Only graph if count>=50 or count>=5
		foreach i in 2 3 8 13 {
		    replace m_wapri_`i' = . if un_count<50
			replace se_wapri_`i' = . if un_count<50
			replace wapri_`i'_hi = . if un_count<50
			replace wapri_`i'_lo = . if un_count<50
			
			replace m_wapri_`i' = . if un_n_wapri_`i'<5
			replace se_wapri_`i' = . if un_n_wapri_`i'<5
			replace wapri_`i'_hi = . if un_n_wapri_`i'<5
			replace wapri_`i'_lo = . if un_n_wapri_`i'<5		
		}	
	
	// Graph for each job type
	twoway (scatter m_wapri_2 whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_2>=5, color(maroon) msymbol(Sh)) (rcap wapri_2_hi wapri_2_lo whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_2>=5, lcolor(maroon)) ///
			(scatter m_wapri_3 whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_3>=5, color(navy) msymbol(Oh)) (rcap wapri_3_hi wapri_3_lo whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_3>=5, lcolor(navy)) ///
			(scatter m_wapri_8 whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_8>=5, color(forest_green) msymbol(Th)) (rcap wapri_8_hi wapri_8_lo whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_8>=5, lcolor(forest_green)) ///
			(scatter m_wapri_13 whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_13>=5, color(purple) msymbol(Dh)) (rcap wapri_13_hi wapri_13_lo whenKidsNum if pj=="PD" & un_count>=50 & un_n_wapri_13>=5, lcolor(purple)), ///
			by(male, graphregion(color(white)) bgcolor(white) title("Postdoc") note("")) ///
			legend(order(1 "Applied Research" 3 "Basic Research" 5 "Management" 7 "Teaching")) xlab(-0.5 " " 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs" 3.5 " ") xtitle("Timing of First Child") ytitle("Fraction of Jobs") ylab(0(.2).8)
	graph export "${RESULTS}/Scatter PD Work Activity by WhenKids ${FIELD}.pdf", as(pdf) replace
				
	twoway (scatter m_wapri_2 whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_2>=5, color(maroon) msymbol(Sh)) (rcap wapri_2_hi wapri_2_lo whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_2>=5, lcolor(maroon)) ///
			(scatter m_wapri_3 whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_3>=5, color(navy) msymbol(Oh)) (rcap wapri_3_hi wapri_3_lo whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_3>=5, lcolor(navy)) ///
			(scatter m_wapri_8 whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_8>=5, color(forest_green) msymbol(Th)) (rcap wapri_8_hi wapri_8_lo whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_8>=5, lcolor(forest_green)) ///
			(scatter m_wapri_13 whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_13>=5, color(purple) msymbol(Dh)) (rcap wapri_13_hi wapri_13_lo whenKidsNum if pj=="AC" & un_count>=50 & un_n_wapri_13>=5, lcolor(purple)), ///
			by(male, graphregion(color(white)) bgcolor(white) title("Tenure-Track") note("")) ///
			legend(order(1 "Applied Research" 3 "Basic Research" 5 "Management" 7 "Teaching")) xlab(-0.5 " " 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs" 3.5 " ") xtitle("Timing of First Child") ytitle("Fraction of Jobs") ylab(0(.2).8)
	graph export "${RESULTS}/Scatter AC Work Activity by WhenKids ${FIELD}.pdf", as(pdf) replace
	
	twoway (scatter m_wapri_2 whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_2>=5, color(maroon) msymbol(Sh)) (rcap wapri_2_hi wapri_2_lo whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_2>=5, lcolor(maroon)) ///
			(scatter m_wapri_3 whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_3>=5, color(navy) msymbol(Oh)) (rcap wapri_3_hi wapri_3_lo whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_3>=5, lcolor(navy)) ///
			(scatter m_wapri_8 whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_8>=5, color(forest_green) msymbol(Th)) (rcap wapri_8_hi wapri_8_lo whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_8>=5, lcolor(forest_green)) ///
			(scatter m_wapri_13 whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_13>=5, color(purple) msymbol(Dh)) (rcap wapri_13_hi wapri_13_lo whenKidsNum if pj=="TE" & un_count>=50 & un_n_wapri_13>=5, lcolor(purple)), ///
			by(male, graphregion(color(white)) bgcolor(white) title("Non-Tenure Track") note("")) ///
			legend(order(1 "Applied Research" 3 "Basic Research" 5 "Management" 7 "Teaching")) xlab(-0.5 " " 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs" 3.5 " ") xtitle("Timing of First Child") ytitle("Fraction of Jobs") ylab(0(.2).8)
	graph export "${RESULTS}/Scatter TE Work Activity by WhenKids ${FIELD}.pdf", as(pdf) replace
		
	twoway (scatter m_wapri_2 whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_2>=5, color(maroon) msymbol(Sh)) (rcap wapri_2_hi wapri_2_lo whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_2>=5, lcolor(maroon)) ///
			(scatter m_wapri_3 whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_3>=5, color(navy) msymbol(Oh)) (rcap wapri_3_hi wapri_3_lo whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_3>=5, lcolor(navy)) ///
			(scatter m_wapri_8 whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_8>=5, color(forest_green) msymbol(Th)) (rcap wapri_8_hi wapri_8_lo whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_8>=5, lcolor(forest_green)) ///
			(scatter m_wapri_13 whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_13>=5, color(purple) msymbol(Dh)) (rcap wapri_13_hi wapri_13_lo whenKidsNum if pj=="ID" & un_count>=50 & un_n_wapri_13>=5, lcolor(purple)), ///
			by(male, graphregion(color(white)) bgcolor(white) title("Industry") note("")) ///
			legend(order(1 "Applied Research" 3 "Basic Research" 5 "Management" 7 "Teaching")) xlab(-0.5 " " 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs" 3 "6-10 Yrs" 3.5 " ") xtitle("Timing of First Child") ytitle("Fraction of Jobs") ylab(0(.2).8)
	graph export "${RESULTS}/Scatter ID Work Activity by WhenKids ${FIELD}.pdf", as(pdf) replace
			
		// Create Counts Table
		preserve
		
			// Only graphing PD, AC, TE, ID
			keep if pj=="PD" | pj=="AC" | pj=="TE" | pj=="ID"
			
			// Only keep if whenKids is Never, PrePhD, 0-5 Yrs, 6-10 Yrs
			drop if whenKidsNum==.
			
			// Only graph if count is greater than 50 or cell is greater than 5
			foreach i in 2 3 8 13 {
			    
				replace un_m_wapri_`i' = . if un_count<50
				replace un_se_wapri_`i' = . if un_count<50
				replace un_count = . if un_count<50
				
				replace un_m_wapri_`i' = . if un_n_wapri_`i'<5
				replace un_se_wapri_`i' = . if un_n_wapri_`i'<5				
				replace un_n_wapri_`i' = . if un_n_wapri_`i'<5
			}			
			
			keep pj male whenKids *m_wapri_* *se_wapri_* un_n_wapri_* un_count
			
			save "${COUNT}/${FIELD} Most Hours Worked by WhenKids.dta", replace
			
		restore	
		
*** 7a. Carnegie Classification by Timing of First Child ***
use "${DATA}/OOI_fullsample.dta", clear

// Drop if no refyr (not entirely sure how this occurred...)
drop if refyr==.

// Exit survey at age 76; only keep if it's a DRF or SDR original
drop if age>76 & age!=. & SDRorig==. & DRForig==.

// Keep only STEM
keep if STEM==1

keep if phd_supField == "${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Keep within 10 years before/after having kid
	keep if yrsTo1Child>=-10 & yrsTo1Child<=10
		
	// Create indicator for before complete PhD -> for now, will just use PhD's CC (but might want to think about using geyear, phdentry)
	gen indGR = (refyr<phdcy_min)
	
	// Create job indicators
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i' = (`i'i>0 & `i'i!=.)
	}
	gen indNI = (indGR==0 & indPD==0 & indAC==0 & indTE==0 & indGV==0 & indID==0 & indNP==0 & indUN==0 & indNL==0)
	
	// Keep only if have job info or still in grad school
	drop if indNI==1

	// Merge on Carnegie classifications for current institutions
	merge m:1 refyr instcod using "${LOOKUPS}/CCbyYear_max.dta"
	drop if _merge==2
	drop _merge
	
		// If in grad school, replace with grad school's CC
		foreach i in R1 R2 D1 D2 {
		    replace `i' = phdcarn_`i' if indGR==1
		}

	// Indicator for no CC even though academic position
	gen noCC = 0 if (indGR==1 | indPD==1 | indAC==1 | indTE==1)
	replace noCC = 1 if (indGR==1 | indPD==1 | indAC==1 | indTE==1) & (R1==. & R2==. & D1==. & D2==.)
	
	// Percent in Each Carnegie Classification
	gen count = 1
	collapse (mean) m_R1=R1 m_R2=R2 m_D1=D1 m_D2=D2 (sem) se_R1=R1 se_R2=R2 se_D1=D1 se_D2=D2 ///
			(sum) count [aw=wtsurvy1_f], by(phdcy_DEC yrsTo1Child male)
	
	// Create error bars
	foreach i in R1 R2 D1 D2 {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}		
		
	// Graph % in R1 Positions
	twoway (scatter m_R1 yrsTo1Child if count>=50 & m_R1!=. & m_R1*count>=5 & (1-m_R1)*count>=5  & phdcy_DEC==1990 & male==0, color(maroon)) (rcap R1_hi R1_lo yrsTo1Child if count>=50 & m_R1!=. & m_R1*count>=5 & (1-m_R1)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_R1 yrsTo1Child if count>=50 & m_R1!=. & m_R1*count>=5 & (1-m_R1)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap R1_hi R1_lo yrsTo1Child if count>=50 & m_R1!=. & m_R1*count>=5 & (1-m_R1)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction in R1 Institutions") ytitle("Fraction of Group") xlab(-10(2)10) xtitle("Timing of First Child") graphregion(color(white)) bgcolor(white) 
	graph export "${RESULTS}/PerR1 Child Birth ${FIELD} 1990s.pdf", as(pdf) replace
	
	twoway (scatter m_R2 yrsTo1Child if count>=50 & m_R2!=. & m_R2*count>=5 & (1-m_R2)*count>=5  & phdcy_DEC==1990 & male==0, color(maroon)) (rcap R2_hi R2_lo yrsTo1Child if count>=50 & m_R2!=. & m_R2*count>=5 & (1-m_R2)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_R2 yrsTo1Child if count>=50 & m_R2!=. & m_R2*count>=5 & (1-m_R2)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap R2_hi R2_lo yrsTo1Child if count>=50 & m_R2!=. & m_R2*count>=5 & (1-m_R2)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Fraction in R2 Institutions") ytitle("Fraction of Group") xlab(-10(2)10) xtitle("Timing of First Child") graphregion(color(white)) bgcolor(white) 
	graph export "${RESULTS}/PerR2 Child Birth ${FIELD} 1990s.pdf", as(pdf) replace	
		
*** 7b. Carnegie Classifications Grouped by When Have Kids		
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Ever Have Children
	bys refid: egen everChild = max(anyChild)	
	
	// When Have Children
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine time since PhD and first child
	gen PhDto1Child = yob_1avg - phdcy_min
	
	// Identify 0-5 Yrs Post-PhD, 6-10 Yrs Post-PhD
	gen whenKids = ""
	replace whenKids = "Never" if everChild==0
	replace whenKids = "PrePhD" if PhDto1Child<0 & everChild==1
	replace whenKids = "Post05" if PhDto1Child>=0 & PhDto1Child<=5 & everChild==1
	replace whenKids = "Post610" if PhDto1Child>=6 & PhDto1Child<=10 & everChild==1
	replace whenKids = "Post11" if PhDto1Child>=11 & PhDto1Child!=. & everChild==1

	label define male 0 "Female" 1 "Male"
	label val male male	
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Determine years since PhD
	gen yrsOut = refyr - phdcy_min
	
	// Only keep first 10 years after PhD
	keep if yrsOut>=0 & yrsOut<=10
	
	// Create job indicators
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i' = (`i'i>0 & `i'i!=.)
	}
	gen indNI = (indPD==0 & indAC==0 & indTE==0 & indGV==0 & indID==0 & indNP==0 & indUN==0 & indNL==0)
	
	// Keep only if have job info
	drop if indNI==1
	
	// Merge on Carnegie classifications for current institutions
	merge m:1 refyr instcod using "${LOOKUPS}/CCbyYear_max.dta"
	drop if _merge==2
	drop _merge
	
	// Indicator for no CC even though academic position
	gen noCC = 0 if (indPD==1 | indAC==1 | indTE==1)
	replace noCC = 1 if (indPD==1 | indAC==1 | indTE==1) & (R1==. & R2==. & D1==. & D2==.)
	
	// Percent in Each Carnegie Classification
	gen count = 1
	collapse (mean) m_R1=R1 m_R2=R2 m_D1=D1 m_D2=D2 (sem) se_R1=R1 se_R2=R2 se_D1=D1 se_D2=D2 ///
			(sum) count [aw=wtsurvy1_f], by(phdcy_DEC yrsOut male whenKids)
	
	// Create error bars
	foreach i in R1 R2 D1 D2 {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}			
	
	// Make numeric so can order properly
	gen whenKidsNum = .
	replace whenKidsNum = 0 if whenKids=="Never"
	replace whenKidsNum = 1 if whenKids=="PrePhD"
	replace whenKidsNum = 2 if whenKids=="Post05"
	replace whenKidsNum = 3 if whenKids=="Post610"
	replace whenKidsNum = 4 if whenKids=="Post11"

	label define whenKids 0 "Never" 1 "Pre-PhD" 2 "0-5 Yrs Post-PhD" 3 "6-10 Yrs Post-PhD" 4 "11+ Yrs Post-PhD", replace
	label val whenKidsNum whenKids
	
	drop if whenKids=="Post11"
	
	// Graph % in R1 Positions
	twoway (scatter m_R1 yrsOut if count>=50 & m_R1!=. & m_R1*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap R1_hi R1_lo yrsOut if count>=50 & m_R1!=. & m_R1*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
		(scatter m_R1 yrsOut if count>=50 & m_R1!=. & m_R1*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap R1_hi R1_lo yrsOut if count>=50 & m_R1!=. & m_R1*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
		by(whenKidsNum, title("Fraction in R1 Institutions") note("") graphregion(color(white)) bgcolor(white)) xtitle("Years Since PhD") xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male"))
	graph export "${RESULTS}/PerR1 10 Years by Kids Gender ${FIELD} 1990s.pdf", as(pdf) replace
		
	twoway (scatter m_R2 yrsOut if count>=50 & m_R2!=. & m_R2*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap R2_hi R2_lo yrsOut if count>=50 & m_R2!=. & m_R2*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
		(scatter m_R2 yrsOut if count>=50 & m_R2!=. & m_R2*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap R2_hi R2_lo yrsOut if count>=50 & m_R2!=. & m_R2*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
		by(whenKidsNum, title("Fraction in R2 Institutions") note("") graphregion(color(white)) bgcolor(white)) xtitle("Years Since PhD") xlab(0(1)10) ytitle("Fraction of Group") legend(order(1 "Female" 3 "Male"))
	graph export "${RESULTS}/PerR2 10 Years by Kids Gender ${FIELD} 1990s.pdf", as(pdf) replace
	
*** 8. Reasons for Changing Work Situation ***
use "${DATA}/OOI_workingsample.dta", clear
keep if phd_supField == "${FIELD}"

	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	
	// Separate into decades
	egen phdcy_DEC = cut(phdcy_min), at(1960, 1970, 1980, 1990, 2000, 2010, 2020)
	
	// Keep within 10 years before/after having kid
	keep if yrsTo1Child>=-10 & yrsTo1Child<=10
	
	// Drop before 1960
	drop if phdcy_min<1960
	
	// Average of hours worked
	gen count = 1
	collapse (mean) m_nrfam=nrfam m_chfam=chfam m_nwfam=nwfam m_ptfam=ptfam ///
			(sem) se_nrfam=nrfam se_chfam=chfam se_nwfam=nwfam se_ptfam=ptfam ///
				(sum) count [aw=wtsurvy1_f], by(male phdcy_DEC yrsTo1Child)
		
	// Create error bars
	foreach i in nrfam chfam nwfam ptfam {
		gen `i'_hi = m_`i' + invttail(count-1,0.025)*se_`i'
		gen `i'_lo = m_`i' - invttail(count-1,0.025)*se_`i'			
	}	
	
	// Outside Field
	twoway (scatter m_nrfam yrsTo1Child if count>=50 & m_nrfam!=. & m_nrfam*count>=5 & (1-m_nrfam)*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap nrfam_hi nrfam_lo yrsTo1Child if count>=50 & m_nrfam!=. & m_nrfam*count>=5 & (1-m_nrfam)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_nrfam yrsTo1Child if count>=50 & m_nrfam!=. & m_nrfam*count>=5 & (1-m_nrfam)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap nrfam_hi nrfam_lo yrsTo1Child if count>=50 & m_nrfam!=. & m_nrfam*count>=5 & (1-m_nrfam)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Family Reason Working Outside PhD Field") ///
			ytitle("Fraction of Group") xlab(-10(2)10) xtitle("Years to First Child Birth") graphregion(color(white)) bgcolor(white)
	graph export "${RESULTS}/nrfam Child Birth ${FIELD}.pdf", as(pdf) replace
		
	// Change Jobs	
	twoway (scatter m_chfam yrsTo1Child if count>=50 & m_chfam!=. & m_chfam*count>=5 & (1-m_chfam)*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap chfam_hi chfam_lo yrsTo1Child if count>=50 & m_chfam!=. & m_chfam*count>=5 & (1-m_chfam)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_chfam yrsTo1Child if count>=50 & m_chfam!=. & m_chfam*count>=5 & (1-m_chfam)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap chfam_hi chfam_lo yrsTo1Child if count>=50 & m_chfam!=. & m_chfam*count>=5 & (1-m_chfam)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Family Reason Change Jobs") ///
			ytitle("Fraction of Group") xlab(-10(2)10) xtitle("Years to First Child Birth") graphregion(color(white)) bgcolor(white)
	graph export "${RESULTS}/chfam Child Birth ${FIELD}.pdf", as(pdf) replace	
	
	// Not Working
	twoway (scatter m_nwfam yrsTo1Child if count>=50 & m_nwfam!=. & m_nwfam*count>=5 & (1-m_nwfam)*count>=5 & phdcy_DEC==1990 & male==0, color(maroon)) (rcap nwfam_hi nwfam_lo yrsTo1Child if count>=50 & m_nwfam!=. & m_nwfam*count>=5 & (1-m_nwfam)*count>=5 & phdcy_DEC==1990 & male==0, lcolor(maroon)) ///
			(scatter m_nwfam yrsTo1Child if count>=50 & m_nwfam!=. & m_nwfam*count>=5 & (1-m_nwfam)*count>=5 & phdcy_DEC==1990 & male==1, color(navy)) (rcap nwfam_hi nwfam_lo yrsTo1Child if count>=50 & m_nwfam!=. & m_nwfam*count>=5 & (1-m_nwfam)*count>=5 & phdcy_DEC==1990 & male==1, lcolor(navy)), ///
			legend(order(1 "Female" 3 "Male")) title("Family Reason Not Working") ///
			ytitle("Fraction of Group") xlab(-10(2)10) xtitle("Years to First Child Birth") graphregion(color(white)) bgcolor(white)
	graph export "${RESULTS}/nwfam Child Birth ${FIELD}.pdf", as(pdf) replace	

*** 9. Regressions ***
use "${DATA}/OOI_workingsample.dta", clear

	/* Add in estimated salary with baby male terms (See "E3. Estimated Salary.do")
	merge 1:1 refid refyr using "${TEMP}/Salary PAIMC.dta", keepusing(SAL_pPAIMC)
	drop _merge
	*/
	
	// Create indicators
	tab phd_supField, gen(phd_f)
	
	// Create interactions
	gen female = (male==0)
	gen marrFemale = married*female
	gen childFemale = anyChild*female
	
	// Has professional degree at time of PhD graduation
	gen indProf = (profdeg!=.)
	
	// Take middle of first child YOB range, round down
	egen yob_1avg = rowmean(yob_1early yob_1late)
	replace yob_1avg = round(yob_1avg)
	
	// Determine year from this date
	gen yrsTo1Child = refyr - yob_1avg
	gen femaleYrsTo1Child = female*(yrsTo1Child)
	
	// Distinguish between years before child and years after
	gen absYrsTo1Child = abs(yrsTo1Child)
	gen afterChild = (yrsTo1Child>0) if yrsTo1Child!=.
	gen yrsAfter1Child = absYrsTo1Child*(afterChild)
	
	gen femAbsYrsTo1Child = female*absYrsTo1Child
	gen femYrsAfter1Child = female*yrsAfter1Child
	
	// Quadratic
	foreach i in absYrsTo1Child yrsAfter1Child femAbsYrsTo1Child femYrsAfter1Child {
		gen `i'2 = `i'*`i'
	}
	
	// Years Since PhD
	gen yrsSincePhD = refyr - phdcy_min
	
	// Log Salary
	gen lnSALi_Adj = ln(SALi_Adj)
	
	// Label Variables
	label var female "Female"
	label var R_hisp "Race: Hispanic"
	label var R_black "Race: Black"
	label var R_asian "Race: Asian"
	label var R_namer "Race: Native American"
	label var R_other "Race: Other"
	label var age "Age"
	label var age2 "Age-Squared"
	label var married "Married"
	label var marrFemale "Married & Female"
	label var anyChild "Parent"
	label var childFemale "Parent & Female"
	label var USnative "US Native"
	label var USnatur "US Naturalized"
	label var gradYrs "Years in Grad School"
	label var togephd "Time Out of Grad School"
	label var bacarn_R1 "Research Intensive BA"
	label var macarn_R1 "Research Intensive MA"
	label var phdcarn_R1 "Research Intensive PhD"
	label var yrsPD "Experience: Years Postdoc"
	label var yrsAC "Experience: Years Tenure-Track"
	label var yrsTE "Experience: Years Non-Tenure Track"
	label var yrsGV "Experience: Years Government"
	label var yrsID "Experience: Years Industry"
	label var yrsNP "Experience: Years Non-Profit"
	label var yrsUN "Experience: Years Unemployed"
	label var yrsNL "Experience: Years Not in Labor Force"
	label var hrswk "Hours Worked"
	label var indProf "Professional Degree at PhD Grad"

	// Indicator for job type
	foreach i in PD AC TE GV ID NP UN NL {
		gen ind`i' = (`i'i>0 & `i'i!=.)
	}
	label var indPD "Job: Postdoc"
	label var indAC "Job: Tenure-Track"
	label var indTE "Job: Non-Tenure Track"
	label var indGV "Job: Government"
	label var indID "Job: Industry"
	label var indNP "Job: Non-Profit"	
	label var indUN "Job: Unemployed"
	label var indNL "Job: Not in Labor Force"
	
	* Regressions for job type
	eststo clear
	foreach i in PD AC TE GV ID NP UN NL {
		eststo: logit ind`i' female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr, cluster(phd_supField) 
	}
		// Impact on Hours Worked
		eststo: regress hrswk female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr, cluster(phd_supField) 
		eststo: regress hrswk female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr ind*, cluster(phd_supField) 
	
		// Impact on Salary
		eststo: regress SALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr, cluster(phd_supField) 
		eststo: regress SALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr ind*, cluster(phd_supField) 
	
		// Impact on Log Salary
		eststo: regress lnSALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr, cluster(phd_supField) 
		eststo: regress lnSALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 phd_f* i.refyr ind*, cluster(phd_supField) 
			
	esttab using "${RESULTS}/Logit of Job Type on Childbearing v3.csv", se star(* 0.10 ** 0.05 *** 0.01) replace	
		
	* Only for bio sciences
	eststo clear
	foreach i in PD AC TE GV ID NP UN NL {
		eststo: logit ind`i' female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 i.refyr if phd_supField=="Bio Sciences" 
	}
		// Impact on Hours Worked 
		eststo: regress hrswk female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 i.refyr ind* if phd_supField=="Bio Sciences" 
	
		// Impact on Salary
		eststo: regress SALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 i.refyr ind* if phd_supField=="Bio Sciences"
	
		// Impact on Log Salary
		eststo: regress lnSALi_Adj female absYrsTo1Child absYrsTo1Child2 femAbsYrsTo1Child femAbsYrsTo1Child2 yrsAfter1Child yrsAfter1Child2 femYrsAfter1Child femYrsAfter1Child2 R_hisp R_black R_asian R_namer R_other age age2 married marrFemale anyChild childFemale USnative USnatur gradYrs togephd *carn_R1 i.refyr ind* if phd_supField=="Bio Sciences"
	esttab using "${RESULTS}/Logit of Job Type on Childbearing Bio v3.csv", se star(* 0.10 ** 0.05 *** 0.01) replace	
		
		