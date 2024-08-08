/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 14:01 */

%web_drop_table(PR_mood);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_mood;
	GETNAMES=YES;
	SHEET="PT_Mood";
RUN;

PROC CONTENTS DATA=PR_mood; RUN;


%web_open_table(PR_mood);

/*-------------------------*/
/* check distribution mood */
/*-------------------------*/
proc univariate data=PR_mood;
var mood; 
where time >= -1;
histogram mood / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data PR_mood;
set PR_mood;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_mood maxiter=0 nozeroconstant;
   	model BoxCox(mood/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 0.5
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data PR_mood;
set PR_mood;
bc_mood = ((mood)**0.5 -1)/0.5;
run;
/* formula when lambda is not 0: bc_variable = ((variable + parameter)**lambda -1)/lambda */
/* formula when lambda is 0: bc_variable = log(variable) */

/* check normality of box-cox transformed variable */
proc univariate data=PR_mood;
var bc_mood;
histogram bc_mood / normal (mu=est sigma=est);
run;


/*-------------------*/
/* model for bc_mood */
/*-------------------*/

proc mixed data=PR_mood; class subject condition;
model bc_mood = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjust=tukey;
run;


