/* Adapted from Code_Expected_Liking_Wanting.sas (labgas/proj_erythritol_2).
   The original PROC IMPORT reads the "Expected_Liking_Wanting" sheet of
   SAS_reward_PolyReward.xlsx from a SAS Studio path; here the same
   subject/condition/liking/wanting values for the baseline timepoint
   (time=0, which is what these models analyse) are supplied inline so the
   distribution checks and the expected-liking / expected-wanting mixed
   models below run unmodified. */

data PR_Reward;
  input subject condition $ liking wanting;
  datalines;
1 erythritol 18 1.4
1 sucrose 3 2.7
1 sucralose 13 3.1
2 erythritol 44 9.1
2 sucrose 54 8.9
2 sucralose 46 7.3
3 sucrose 25 5.3
3 sucralose 27 4.9
3 erythritol 61 7.2
4 sucralose 29 2.2
4 erythritol 28 2.3
4 sucrose 32 2.8
5 sucrose 22 4.1
5 erythritol -4 4.7
5 sucralose 15 5.3
6 sucralose 2 2.4
6 erythritol -3 1.5
6 sucrose 29 4.3
7 sucralose 31 5.9
7 erythritol 20 5.2
7 sucrose -15 3.2
8 erythritol 22 2.4
8 sucrose -8 2.6
8 sucralose 31 4.4
9 sucralose 61 5.6
9 erythritol 22 5
9 sucrose 43 6.1
10 erythritol 71 7
10 sucrose -15 3.7
10 sucralose 57 6.7
11 sucrose 7 3.6
11 erythritol 35 6.3
11 sucralose 33 5.1
12 erythritol 7 2
12 sucrose 40 3
12 sucralose -11 0.6
13 erythritol 21 4.3
13 sucrose 10 2
13 sucralose -10 1
14 sucralose -4 3.5
14 erythritol 18 4.5
14 sucrose -6 3
15 sucrose 17 1.5
15 erythritol 59 6.3
15 sucralose -22 0.8
16 sucrose -20 0.4
16 erythritol 12 4.2
16 sucralose 13 4.7
;
run;

PROC CONTENTS DATA=PR_Reward; RUN;

/* check distribution of liking */
proc univariate data=PR_Reward;
var liking;
histogram liking / normal;
run;

/*---------------------------*/
/* model for expected liking */
/*---------------------------*/
proc mixed data=PR_Reward; 
class subject condition;
model liking = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjdfe=row adjust=tukey;
run;

/* check distribution of wanting */
proc univariate data=PR_Reward;
var wanting;
histogram wanting / normal;
run;

/*----------------------------*/
/* model for explicit wanting */
/*----------------------------*/
proc mixed data=PR_Reward; 
class subject condition;
model wanting = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjdfe=row adjust=tukey;
run;
