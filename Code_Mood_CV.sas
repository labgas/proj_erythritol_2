/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 12:26 */

%web_drop_table(PR_Mood);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_Mood;
	GETNAMES=YES;
	SHEET="CV_Mood";
RUN;

PROC CONTENTS DATA=PR_Mood; RUN;


%web_open_table(PR_Mood);

/*-------------------------*/
/* check distribution mood */
/*-------------------------*/
proc univariate data=PR_Mood;
var mood; 
where time >= -1;
histogram mood / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data PR_Mood;
set PR_Mood;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_Mood maxiter=0 nozeroconstant;
   	model BoxCox(mood/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 1.25
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data PR_Mood;
set PR_Mood;
bc_mood = ((mood)**1.25 -1)/1.25;
run;
/* parameter = 0, therefore (mood "+ 0")

/* check normality of box-cox transformed variable */
proc univariate data=PR_Mood;
var bc_mood;
histogram bc_mood / normal (mu=est sigma=est);
run;
/* transformation was not useful, model with mood and not bc_mood */

/*-------------*/
/* model mood  */
/*-------------*/

proc mixed data=PR_Mood;
where time >= -1;
class subject condition time;
model mood = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmestimate condition
	'effect on mood in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on mood in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;
