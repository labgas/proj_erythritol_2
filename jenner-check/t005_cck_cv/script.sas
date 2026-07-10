/* Adapted from Code_CCK_CV.sas (labgas/proj_erythritol_2).
   The original PROC IMPORT reads the "CV_hormones" sheet of
   SAS_hormones_PolyReward.xlsx from a SAS Studio path; here the
   subject/condition/time/dosage/delta_CCK values are supplied inline so the
   distribution check, Box-Cox transform, and the condition-by-time repeated
   measures mixed model below run unmodified. */

data PR_hormone;
  input subject condition $ time dosage delta_CCK;
  datalines;
1 sucralose -1 0.0373 0
1 sucralose 15 0.0373 0.8
1 sucralose 30 0.0373 0.4
1 sucralose 44 0.0373 0.4
1 sucralose 60 0.0373 0.3
1 sucralose 75 0.0373 0.5
1 sucralose 89 0.0373 0.6
1 sucralose 105 0.0373 0.1
1 sucralose 120 0.0373 0.3
1 sucralose 134 0.0373 0.2
1 erythritol -1 51.4 0
1 erythritol 15 51.4 0.6
1 erythritol 30 51.4 0.3
1 erythritol 44 51.4 0.4
1 erythritol 60 51.4 0.1
1 erythritol 75 51.4 0.6
1 erythritol 89 51.4 0
1 erythritol 105 51.4 0.5
1 erythritol 120 51.4 0.5
1 erythritol 134 51.4 0.1
1 sucrose -1 30 0
1 sucrose 15 30 0.4
1 sucrose 30 30 0.4
1 sucrose 44 30 0.3
1 sucrose 60 30 0.2
1 sucrose 75 30 0.3
1 sucrose 89 30 0.3
1 sucrose 105 30 0.4
1 sucrose 120 30 0.7
1 sucrose 134 30 0.3
2 sucrose -1 30 0
2 sucrose 15 30 0.2
2 sucrose 30 30 0
2 sucrose 44 30 0.4
2 sucrose 60 30 0.5
2 sucrose 75 30 0.2
2 sucrose 89 30 0.4
2 sucrose 105 30 0.6
2 sucrose 120 30 0.3
2 sucrose 134 30 0
2 erythritol -1 32.4 0
2 erythritol 15 32.4 -0.1
2 erythritol 30 32.4 -0.3
2 erythritol 44 32.4 -0.3
2 erythritol 60 32.4 -0.1
2 erythritol 75 32.4 -0.4
2 erythritol 89 32.4 -0.1
2 erythritol 105 32.4 0
2 erythritol 120 32.4 -0.3
2 erythritol 134 32.4 -0.2
2 sucralose -1 0.1368 0
2 sucralose 15 0.1368 0.2
2 sucralose 30 0.1368 -0.2
2 sucralose 44 0.1368 0.1
2 sucralose 60 0.1368 -0.2
2 sucralose 75 0.1368 -0.1
2 sucralose 89 0.1368 -0.3
2 sucralose 105 0.1368 0.1
2 sucralose 120 0.1368 -0.3
2 sucralose 134 0.1368 -0.1
3 erythritol -1 47.8 0
3 erythritol 15 47.8 1.9
3 erythritol 30 47.8 -0.2
3 erythritol 44 47.8 -0.6
3 erythritol 60 47.8 2.2
3 erythritol 75 47.8 -0.3
3 erythritol 89 47.8 -0.1
3 erythritol 105 47.8 2
3 erythritol 120 47.8 0.3
3 erythritol 134 47.8 -0.1
3 sucrose -1 30 0
3 sucrose 15 30 1.5
3 sucrose 30 30 -0.1
3 sucrose 44 30 0.1
3 sucrose 60 30 0.4
3 sucrose 75 30 0.2
3 sucrose 89 30 0.3
3 sucrose 105 30 0.1
3 sucrose 120 30 0.1
3 sucrose 134 30 0
3 sucralose -1 0.0803 0
3 sucralose 15 0.0803 0.4
3 sucralose 30 0.0803 0.1
3 sucralose 44 0.0803 -0.1
3 sucralose 60 0.0803 0.3
3 sucralose 75 0.0803 0.1
3 sucralose 89 0.0803 0.3
3 sucralose 105 0.0803 0.5
3 sucralose 120 0.0803 0.2
3 sucralose 134 0.0803 0.4
;
run;

PROC CONTENTS DATA=PR_hormone; RUN;

/*------------------------------*/
/* check distribution delta_CCK */
/*------------------------------*/
proc univariate data=PR_hormone;
var delta_CCK; 
where time >= -1;
histogram delta_CCK / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data PR_hormone;
set PR_hormone;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_hormone maxiter=0 nozeroconstant;
   	model BoxCox(delta_CCK/parameter=1) = identity(z);
run;

data PR_hormone;
set PR_hormone;
bc_delta_CCK = ((delta_CCK+1)**-0.25 -1)/-0.25;
run;

/* check normality of box-cox transformed variable */
proc univariate data=PR_hormone;
var bc_delta_CCK;
histogram bc_delta_CCK / normal (mu=est sigma=est);
run;

/*-----------------------*/
/* mixed model delta_CCK */
/*-----------------------*/
proc mixed data=PR_hormone;
where time >= -1;
class subject condition time;
model bc_delta_CCK = condition | time / ddfm=kr2 solution residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
run;
