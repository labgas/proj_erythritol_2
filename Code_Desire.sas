/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_reward_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 22.11.23 10:07 */

%web_drop_table(PR_desire);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_reward_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_desire;
	GETNAMES=YES;
	SHEET="Desire";
RUN;

PROC CONTENTS DATA=PR_desire; RUN;


%web_open_table(PR_desire);

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
