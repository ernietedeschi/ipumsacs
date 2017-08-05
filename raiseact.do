* RAISEACT.DO
* Ernie Tedeschi
* 4 August 2017
*
* This code takes the 2015 IPUMS ACS extract and applies the criteria of the
* RAISE Act as written at the time of analysis to current US citizens, other
* than the points awarded for business investment and extraordinary success
* (Nobel Prize or recent Olympian). 
*

ssc install egenmore      // Need for MHI calculation

gen sample = age >= 18 & citizen >= 0 & citizen <= 2    // Sample flag for US citizens age 18+

bysort statefip: egen mhi = wpctile(hhincome), p(50) weights(hhwt)          // Calculates median household income for each state

recode degfield (11 13 21 24 25 36 37 38 50 51 57 58 59 61 = 1 "STEM")(else = 2 "Non STEM"), gen(stem)      // Assign degree fields to STEM

replace incwage = . if incwage >= 999998
gen incratio = incwage*100/mhi      // Ratio of personal wage & salary to state median household income

** GENERATE AGE POINTS
gen p_age = 0
replace p_age = 6 if age >= 18 & age < 22
replace p_age = 8 if age >= 22 & age < 26
replace p_age = 10 if age >= 26 & age < 31
replace p_age = 8 if age >= 31 & age < 36
replace p_age = 6 if age >= 36 & age < 41
replace p_age = 4 if age >= 41 & age < 46
replace p_age = 2 if age >= 46 & age < 51

** GENERATE EDUCATION POINTS
gen p_edu = 0
replace p_edu = 1 if educd >= 62      // High schoolers
replace p_edu = 6 if educd >= 101     // BA/BS. Assumes all are from US universities
replace p_edu = 8 if educd >= 114 & stem == 1     // STEM Masters. Assumes all are from US universities
replace p_edu = 13 if (educd == 115 & (degfield == 62 | degfield == 32)) | (educd == 116 & stem == 1)     // Law or business professional degress (JD/MBA) or STEM PhD  

** GENERATE ENGLISH POINTS
gen p_eng = 0
replace p_eng = 12 if speakeng == 3     // English-only speakers get highest points
replace p_eng = 10 if speakeng == 4     // Speaks "very well" gets 2nd highest points
replace p_eng = 6 if speakeng == 5      // Speaks "well" gets 3rd highest points

** GENERATE INCOME POINTS
gen p_inc = 0
replace p_inc = 5 if incratio >= 150 & incratio < 200
replace p_inc = 8 if incratio >= 200 & incratio < 300
replace p_inc = 13 if incratio >= 300 & incratio != .

** AGGREGATE AND CHART
gen p_total = p_age + p_edu + p_eng + p_inc
gen success = p_total >= 30 & p_total != .

tabulate success if sample == 1 [iw=perwt]
histogram p_total if sample == 1 [fw=perwt], width(5) fraction
