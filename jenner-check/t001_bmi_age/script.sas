/* Adapted from Code_BMI_age.sas (labgas/proj_erythritol_2).
   The original PROC IMPORT reads SAS_PolyReward.xlsx from a SAS Studio path;
   here the same subject-level BMI/age values are supplied inline so the
   descriptive PROC MEANS below runs unmodified. */

data WORK.IMPORT;
  input BMI_kg_m2 age_yrs;
  datalines;
23.69 31
24.8 40
21.56 23
24.03 23
23.7 36
20.7 23
24.2 18
19 21
20.9 23
22.3 18
19.8 23
22.6 32
23.8 44
24.3 22
20 20
23.3 19
23.4 35
19.399999999999999 22
21.5 22
23.5 21
;
run;

PROC CONTENTS DATA=WORK.IMPORT; RUN;

/* mean of BMI */
proc means data=WORK.IMPORT mean;
	var BMI_kg_m2;
run;

/* sd of BMI */
proc means data=WORK.IMPORT std;
	var BMI_kg_m2;
run;

/* mean of age */
proc means data=WORK.IMPORT mean;
	var age_yrs;
run;

/* sd of age */
proc means data=WORK.IMPORT std;
	var age_yrs;
run;
