/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 13:48 */

%web_drop_table(VAS_PT);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=VAS_PT;
	GETNAMES=YES;
	SHEET="PT_VAS";
RUN;

PROC CONTENTS DATA=VAS_PT; RUN;


%web_open_table(VAS_PT);

/*------------------------------*/
/* check distribution hunger 	*/
/*------------------------------*/

proc univariate data=VAS_PT;
var hunger; 
histogram hunger / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS_PT;
set VAS_PT;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS_PT maxiter=0 nozeroconstant;
   	model BoxCox(hunger/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 1.25
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum| (from proc univariate comand) */

data VAS_PT;
set VAS_PT;
bc_hunger = ((hunger)**1.25 -1)/1.25;
run;
/* formula when lambda is not 0: bc_variable = ((variable + parameter)**lambda -1)/lambda */
/* formula when lambda is 0: bc_variable = log(variable) */

/* check normality of box-cox transformed variable */
proc univariate data=VAS_PT;
var bc_hunger;
histogram bc_hunger / normal (mu=est sigma=est);
run;

/*--------------*/
/* model hunger */
/*--------------*/

/* without dosage */
proc mixed data=VAS_PT;
class subject condition time_cond;
model bc_hunger = condition | time_cond / ddfm=kr2 influence solution residual;
repeated condition time_cond/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on hunger in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on hunger in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage*/

proc sort data=VAS_PT;
by condition;
run;

proc standard data=VAS_PT mean=0 std=1 out=VAS_PT_z_dosage;
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

proc mixed data=VAS_PT_z_dosage;
class subject condition time_cond;
where condition NE 'sucrose';
model bc_hunger = condition | time_cond | dosage / ddfm=kr2 influence solution residual;
repeated condition time_cond / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time_cond / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on hunger in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/

/*------------------------------*/
/* check distribution thirst 	*/
/*------------------------------*/

proc univariate data=VAS_PT;
var thirst; 
histogram thirst / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS_PT;
set VAS_PT;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS_PT maxiter=0 nozeroconstant;
   	model BoxCox(thirst/parameter=1) = identity(z);
run;
/* check lambda in output, in this case 1
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS_PT;
set VAS_PT;
bc_thirst = ((thirst+1)**1 -1)/1;
run;

/* check normality of box-cox transformed variable */
proc univariate data=VAS_PT;
var bc_thirst;
histogram bc_thirst / normal (mu=est sigma=est);
run;

/*--------------*/
/* model thirst */
/*--------------*/

/* without dosage */
proc mixed data=VAS_PT;
class subject condition time_cond;
model bc_thirst = condition | time_cond / ddfm=kr2 influence solution residual;
repeated condition time_cond/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on thirst in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on thirst in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage*/

proc sort data=VAS_PT;
by condition;
run;

proc standard data=VAS_PT mean=0 std=1 out=VAS_PT_z_dosage;
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

proc mixed data=VAS_PT_z_dosage;
class subject condition time_cond;
where condition NE 'sucrose';
model bc_thirst = condition | time_cond | dosage / ddfm=kr2 influence solution residual;
repeated condition time_cond / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time_cond / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on thirst in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/

/*------------------------------*/
/* check distribution satiety 	*/
/*------------------------------*/

proc univariate data=VAS_PT;
where time >= -1;
var satiety; 
histogram satiety / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS_PT;
set VAS_PT;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS_PT maxiter=0 nozeroconstant;
   	model BoxCox(satiety/parameter=1) = identity(z);
run;
/* check lambda in output, in this case 0.5
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS_PT;
set VAS_PT;
bc_satiety = ((thirst+1)**0.5 -1)/0.5;
run;

/* check normality of box-cox transformed variable */
proc univariate data=VAS_PT;
where time >= -1;
var bc_satiety;
histogram bc_satiety / normal (mu=est sigma=est);
run;

/*---------------*/
/* model satiety */
/*---------------*/

/* without dosage */
proc mixed data=VAS_PT;
where time >= -1;
class subject condition time_cond;
model bc_satiety = condition | time_cond / ddfm=kr2 influence solution residual;
repeated condition time_cond/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on satiety in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on satiety in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage*/

proc sort data=VAS_PT;
by condition;
run;

proc standard data=VAS_PT mean=0 std=1 out=VAS_PT_z_dosage;
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

proc mixed data=VAS_PT_z_dosage;
class subject condition time_cond;
where condition NE 'sucrose';
model bc_satiety = condition | time_cond | dosage / ddfm=kr2 influence solution residual;
repeated condition time_cond / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time_cond / diff=all;
lsmeans condition*time_cond / slice=time_cond slice=condition adjdfe=row;
lsmestimate condition
	'effect on satiety in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;
