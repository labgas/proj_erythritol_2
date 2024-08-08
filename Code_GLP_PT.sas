/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 13:27 */

%web_drop_table(PT_hormone);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PT_hormone;
	GETNAMES=YES;
	SHEET="PT_hormones";
RUN;

PROC CONTENTS DATA=PT_hormone; RUN;


%web_open_table(PT_hormone);

/*-------------------------*/
/* check distribution GLP1 */
/*-------------------------*/
proc univariate data=PT_hormone;
var GLP_pmol_L; 
histogram GLP_pmol_L/ normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data PT_hormone;
set PT_hormone;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=PT_hormone maxiter=0 nozeroconstant;
   	model BoxCox(GLP_pmol_L/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 0; if lamda = 0 --> bc_x=log(x)
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data PT_hormone;
set PT_hormone;
bc_GLP_pmol_L = log(GLP_pmol_L);
run;
/* formula when lambda is not 0: bc_variable = ((variable + parameter)**lambda -1)/lambda */
/* formula when lambda is 0: bc_variable = log(variable) */

/* check normality of box-cox transformed variable */
proc univariate data=PT_hormone;
var bc_GLP_pmol_L;
histogram bc_GLP_pmol_L / normal (mu=est sigma=est);
run;

/*--------------*/
/* model GLP PT */
/*--------------*/

/* without dosage */
proc mixed data=PT_hormone;
class subject condition time_cond;
model bc_GLP_pmol_L = condition | time_cond / ddfm=kr2 solution influence residual;
repeated condition time_cond/ subject=subject type=un@cs r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on GLP1 in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on GLP1 in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* effect of dosage */
proc sort data=PT_hormone;
by condition;
run;

proc standard data=PT_hormone mean=0 std=1 out=PT_hormone_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PT_hormone_z_dosage;
where condition NE 'sucrose';
by condition;
var dosage;
run;

proc mixed data=PT_hormone_z_dosage;
class subject condition time_cond;
where condition NE 'sucrose';
model bc_GLP_pmol_L = condition | time_cond | dosage / ddfm=kr2 influence solution residual;
repeated condition time_cond / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time_cond / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on GLP in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;
