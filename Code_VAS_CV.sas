/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 12:08 */

%web_drop_table(PR_VAS);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_VAS;
	GETNAMES=YES;
	SHEET="CV_VAS";
RUN;

PROC CONTENTS DATA=PR_VAS; RUN;


%web_open_table(PR_VAS);

/*----------------------------------*/
/* check distribution delta_hunger 	*/
/*----------------------------------*/

proc univariate data=PR_VAS;
var delta_hunger; 
where time >= -1;
histogram delta_hunger / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
/*kolmogorov p<0.01 but looks ok --> no transformation*/ 

/*--------------*/
/* model hunger */
/*--------------*/

/* without dosag */
proc mixed data=PR_VAS;
where time >= -1;
class subject condition time;
model delta_hunger = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmestimate condition
	'effect on hunger in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on hunger in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage */
proc sort data=PR_VAS;
by condition;
run;

proc standard data=PR_VAS mean=0 std=1 out=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;

proc mixed data=PR_VAS_z_dosage;
class subject condition time;
where condition NE 'sucrose'and time >= -1;
model delta_hunger = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on hunger in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/

/*----------------------------------*/
/* check distribution delta_thirst 	*/
/*----------------------------------*/

proc univariate data=PR_VAS;
var delta_thirst; 
where time >= -1;
histogram delta_thirst/ normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
/*kolmogorov p<0.01 but looks ok --> no transformation*/ 

/*--------------*/
/* model thirst */
/*--------------*/

/* without dosage */
proc mixed data=PR_VAS;
where time >= -1;
class subject condition time;
model delta_thirst = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmestimate condition
	'effect on thirst in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on thirst in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage */
proc sort data=PR_VAS;
by condition;
run;

proc standard data=PR_VAS mean=0 std=1 out=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;

proc mixed data=PR_VAS_z_dosage;
class subject condition time;
where condition NE 'sucrose'and time >= -1;
model delta_thirst = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on thirst in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;

/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/

/*--------------------------------------*/
/* check distribution delta_satiety 	*/
/*--------------------------------------*/

proc univariate data=PR_VAS;
var delta_satiety; 
where time >= -1;
histogram delta_satiety / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
/*kolmogorov p<0.01 but looks ok --> no transformation*/ 

/*---------------*/
/* model satiety */
/*---------------*/

/* without dosage */
proc mixed data=PR_VAS;
where time >= -1;
class subject condition time;
model delta_satiety = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmeans condition;
lsmestimate condition
	'effect on satiety in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on satiety in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage */
proc sort data=PR_VAS;
by condition;
run;

proc standard data=PR_VAS mean=0 std=1 out=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_VAS_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;

proc mixed data=PR_VAS_z_dosage;
class subject condition time;
where condition NE 'sucrose'and time >= -1;
model delta_satiety = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on satiety in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;
