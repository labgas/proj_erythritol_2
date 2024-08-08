/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_reward_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 22.11.23 10:17 */

%web_drop_table(PR_reward);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_reward_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_reward;
	GETNAMES=YES;
	SHEET="Implicit_Wanting";
RUN;

PROC CONTENTS DATA=PR_reward; RUN;


%web_open_table(PR_reward);

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
/* check lambda in output, in this case -0.5
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data PR_reward;
set PR_reward;
bc_reaction_time = ((reaction_time)**-0.5 -1)/-0.5;
run;
/* formula when lambda is not 0: bc_variable = ((variable + parameter)**lambda -1)/lambda */
/* formula when lambda is 0: bc_variable = log(variable) */

/* check normality of box-cox transformed variable */
proc univariate data=PR_reward;
var bc_reaction_time;
histogram bc_reaction_time / normal (mu=est sigma=est);
run;

/*---------------------*/
/* model reaction time */
/*---------------------*/
proc mixed data=PR_reward; class subject choice;
model bc_reaction_time = choice / solution; 
repeated choice / subject = subject type=un r rcorr; 
lsmeans choice / diff = all adjust=tukey;
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

