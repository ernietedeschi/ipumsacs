gen sample = age >= 18 & citizen >= 0 & citizen <= 2

bysort statefip: egen mhi = wpctile(hhincome), p(50) weights(hhwt)

recode degfield (11 13 21 24 25 36 37 38 50 51 57 58 59 61 = 1 "STEM")(else = 2 "Non STEM"), gen(stem)

replace incwage = . if incwage >= 999998
gen incratio = incwage*100/mhi

gen p_age = 0
replace p_age = 6 if age >= 18 & age < 22
replace p_age = 8 if age >= 22 & age < 26
replace p_age = 10 if age >= 26 & age < 31
replace p_age = 8 if age >= 31 & age < 36
replace p_age = 6 if age >= 36 & age < 41
replace p_age = 4 if age >= 41 & age < 46
replace p_age = 2 if age >= 46 & age < 51

gen p_edu = 0
replace p_edu = 1 if educd >= 62 & educd <= 64
replace p_edu = 6 if educd == 101   // ASSUME EVERY BA IS US
replace p_edu = 8 if educd == 114 & stem == 1  // ASSUME EVERY MS IS US
replace p_edu = 13 if (educd == 115 & (degfield == 62 | degfield == 32)) | (educd == 116 & stem == 1)

gen p_eng = 0
replace p_eng = 12 if speakeng == 3
replace p_eng = 10 if speakeng == 4
replace p_eng = 6 if speakeng == 5

gen p_inc = 0
replace p_inc = 5 if incratio >= 150 & incratio < 200
replace p_inc = 8 if incratio >= 200 & incratio < 300
replace p_inc = 13 if incratio >= 300 & incratio != .

gen p_total = p_age + p_edu + p_eng + p_inc
gen success = p_total >= 30 & p_total != .

tabulate success if sample == 1 [iw=perwt]
histogram p_total if citizen == 1 [fw=perwt], width(5)
