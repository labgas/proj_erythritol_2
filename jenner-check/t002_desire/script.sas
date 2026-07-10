/* Adapted from Code_Desire.sas (labgas/proj_erythritol_2).
   The original PROC IMPORT reads the "Desire" sheet of SAS_reward_PolyReward.xlsx
   from a SAS Studio path; here the same subject/condition/time/desire values are
   supplied inline so the distribution check, Box-Cox transform, and mixed model
   below run unmodified. */

data PR_desire;
  input subject condition $ time desire;
  datalines;
1 erythritol 0 6.5
1 sucrose 45 5.2
1 sucralose 90 2.3
2 erythritol 0 6.8
2 sucrose 45 8.1
2 sucralose 90 6.5
3 sucrose 0 3.4
3 sucralose 45 3.4
3 erythritol 90 5.1
4 sucralose 0 1.9
4 erythritol 45 3.1
4 sucrose 90 2
5 sucrose 0 5.9
5 erythritol 45 4.4
5 sucralose 90 5
6 sucralose 0 1.8
6 erythritol 45 2.8
6 sucrose 90 3.5
7 sucralose 0 4.1
7 erythritol 45 6.4
7 sucrose 90 7.2
8 erythritol 0 4.9
8 sucrose 45 2
8 sucralose 90 2.8
9 sucralose 0 7.3
9 erythritol 45 5.5
9 sucrose 90 4.8
10 erythritol 0 6.6
10 sucrose 45 5.2
10 sucralose 90 6.6
11 sucrose 0 3.4
11 erythritol 45 3.5
11 sucralose 90 7.8
12 erythritol 0 3
12 sucrose 45 7.4
12 sucralose 90 0.2
13 erythritol 0 6.4
13 sucrose 45 2.3
13 sucralose 90 1.6
14 sucralose 0 4.3
14 erythritol 45 5.5
14 sucrose 90 4.7
15 sucrose 0 0
15 erythritol 45 8.2
15 sucralose 90 2.1
16 sucrose 0 2.7
16 erythritol 45 3.1
16 sucralose 90 3.6
17 erythritol 0 2.5
17 sucralose 45 2.2
17 sucrose 90 2.6
19 sucrose 0 7.1
19 erythritol 45 3.7
19 sucralose 90 1.6
20 erythritol 0 5.7
20 sucralose 45 5.5
20 sucrose 90 0.5
21 sucralose 0 1.1
21 erythritol 45 0.3
21 sucrose 90 0
;
run;

PROC CONTENTS DATA=PR_desire; RUN;

/*---------------------------*/
/* check distribution desire */
/*---------------------------*/
proc univariate data=PR_desire;
var desire; 
where time >= -1;
histogram desire / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data PR_desire;
set PR_desire;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_desire maxiter=0 nozeroconstant;
   	model BoxCox(desire/parameter=1) = identity(z);
run;
/* check lambda in output, in this case 0.75
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data PR_desire;
set PR_desire;
bc_desire = ((desire+1)**0.75 -1)/0.75;
run;

/* check normality of box-cox transformed variable */
proc univariate data=PR_desire;
var bc_desire;
histogram bc_desire / normal (mu=est sigma=est);
run;

/*------------------------*/
/* mixed model for desire */
/*------------------------*/

proc mixed data=PR_desire; class subject condition;
model bc_desire = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjust=tukey;
run;
