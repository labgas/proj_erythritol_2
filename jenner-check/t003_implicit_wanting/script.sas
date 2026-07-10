/* Adapted from Code_Implicit_Wanting.sas (labgas/proj_erythritol_2).
   The original PROC IMPORT reads the "Implicit_Wanting" sheet of
   SAS_reward_PolyReward.xlsx from a SAS Studio path; here the same
   subject/choice/reaction_time values are supplied inline. The Box-Cox
   transform, mixed model, and the chi-square choice analysis run unmodified. */

data PR_reward;
  input subject choice $ reaction_time;
  datalines;
1 sucralose 3781
2 sucrose 2033
3 erythritol 1863
4 sucralose 3075
5 sucralose 1977
6 sucrose 1260
7 sucrose 2550
8 erythritol 1561
9 sucralose 2219
10 sucralose 6809
11 erythritol 2132
12 sucrose 3182
13 erythritol 1940
14 erythritol 1774
15 sucrose 1694
16 erythritol 4032
17 sucralose 1546
19 sucrose 967
20 sucralose 2222
21 sucralose 1166
;
run;

PROC CONTENTS DATA=PR_reward; RUN;

/*----------------------------------*/
/* check distribution reaction time */
/*----------------------------------*/
proc univariate data=PR_reward;
var reaction_time;
histogram reaction_time / normal;
run;

/* box-cox transformation */
data PR_reward;
set PR_reward;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_reward maxiter=0 nozeroconstant;
   	model BoxCox(reaction_time/parameter=0) = identity(z);
run;
/* check lambda in output, in this case -0.5 */

data PR_reward;
set PR_reward;
bc_reaction_time = ((reaction_time)**-0.5 -1)/-0.5;
run;

/* check normality of box-cox transformed variable */
proc univariate data=PR_reward;
var bc_reaction_time;
histogram bc_reaction_time / normal (mu=est sigma=est);
run;

/*-----------------*/
/* analysis choice */
/*-----------------*/

data PR_reward_choice;
	input category $ count;
	datalines;
Erythritol 6
Sucrose 6
Sucralose 8
;
run;

/* erwartete Häufigkeiten (chi-square test) */
proc freq data=pr_reward_choice;
	tables category / nocum nopercent chisq expected;
	weight count;
run;
