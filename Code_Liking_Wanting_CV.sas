/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_reward_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 15:53 */

%web_drop_table(PR_Reward);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_reward_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_Reward;
	GETNAMES=YES;
	SHEET="CV_Liking_Wanting";
RUN;

PROC CONTENTS DATA=PR_Reward; RUN;


%web_open_table(PR_Reward);

/*----------------------------*/
/*check distribution of liking*/
/*----------------------------*/
proc univariate data=PR_Reward;
var liking;
histogram liking / normal;
run;

/* box-cox transformation */
data PR_Reward;
set PR_Reward;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_Reward maxiter=0 nozeroconstant;
   	model BoxCox(liking/parameter=71) = identity(z);
run;
/* check lambda in output, in this case 1.25
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data PR_Reward;
set PR_Reward;
bc_liking = ((liking+71)**1.25 -1)/1.25;
run;
/* formula when lambda is not 0: bc_variable = ((variable + parameter)**lambda -1)/lambda */
/* formula when lambda is 0: bc_variable = log(variable) */

/* check normality of box-cox transformed variable */
proc univariate data=PR_Reward;
var bc_liking;
histogram bc_liking / normal (mu=est sigma=est);
run;


/*--------------------*/
/* mixed model liking */
/*--------------------*/

/* without dosage */
proc mixed data=PR_Reward;
where time >= -1;
class subject condition time;
model bc_liking = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmeans time;
lsmestimate condition
	'effect on liking in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on liking in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown alpha=0.05;
run;

/* effect of the dosage */
proc sort data=PR_Reward;
by condition;
run;

proc standard data=PR_Reward mean=0 std=1 out=PR_Reward_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_Reward_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;

proc mixed data=PR_Reward_z_dosage;
class subject condition time;
where condition NE 'sucrose';
model bc_liking = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@un r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on liking in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/* to see effect of high vs low dosage */
proc sort data=PR_Reward_z_dosage;
by condition;
run;

proc mixed data=PR_Reward_z_dosage;
class subject condition time;
where condition NE 'sucrose';
by condition;
model bc_liking = time | dosage / ddfm=kr2 influence solution residual;
repeated time / subject=subject type=un r rcorr;
lsmeans time / at dosage = -1 diff=all;
lsmeans time / diff=all;
lsmeans time / at dosage = 1 diff=all;
run;
/*tests correlation condition*dosage*/

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/

/*----------------------------*/
/* check distribution wanting */
/*----------------------------*/
proc univariate data=PR_Reward;
var wanting;
histogram wanting / normal;
run;

/* box-cox transformation */
data PR_Reward;
set PR_Reward;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PR_Reward maxiter=0 nozeroconstant;
   	model BoxCox(wanting/parameter=3) = identity(z);
run;
/* check lambda in output, in this case 0.25
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */
/* was ist das min */

data PR_Reward;
set PR_Reward;
bc_wanting = ((wanting+3)**0.25 -1)/0.25;
run;

/* check normality of box-cox transformed variable */
proc univariate data=PR_Reward;
var bc_wanting;
histogram bc_wanting / normal (mu=est sigma=est);
run;

/*---------------------*/
/* mixed model wanting */
/*---------------------*/

/* without dosage */
proc mixed data=PR_Reward;
where time >= -1;
class subject condition time;
model bc_wanting = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmeans time;
lsmestimate condition
	'effect on wanting in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on wanting in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown alpha=0.05;
run;

/* effect of the dosage */
proc sort data=PR_Reward;
by condition;
run;

proc standard data=PR_Reward mean=0 std=1 out=PR_Reward_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_Reward_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;

proc mixed data=PR_Reward_z_dosage;
class subject condition time;
where condition NE 'sucrose';
model bc_wanting = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@un r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on wanting in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/* to see effect of high vs low dosage */
proc sort data=PR_Reward_z_dosage;
by condition;
run;

proc mixed data=PR_Reward_z_dosage;
class subject condition time;
where condition NE 'sucrose';
by condition;
model bc_wanting = time | dosage / ddfm=kr2 influence solution residual;
repeated time / subject=subject type=un r rcorr;
lsmeans time / at dosage = -1 diff=all;
lsmeans time / diff=all;
lsmeans time / at dosage = 1 diff=all;
run;
/*tests correlation condition*dosage*/

