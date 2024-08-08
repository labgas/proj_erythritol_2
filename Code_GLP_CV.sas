/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_hormones_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 21.11.23 10:57 */

%web_drop_table(PR_hormone);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_hormones_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_hormone;
	GETNAMES=YES;
	SHEET="CV_hormones";
RUN;

PROC CONTENTS DATA=PR_hormone; RUN;


%web_open_table(PR_hormone);

/*------------------------------*/
/* check distribution GLP_delta */
/*------------------------------*/
proc univariate data=PR_hormone;
var delta_GLP; 
where time >= -1;
histogram delta_GLP / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
/*kolmogorov p<0.01 but looks ok --> no transformation*/ 

/*-------------------------*/
/* mixed model delta_GLP-1 */
/*-------------------------*/

/* without dosage */
proc mixed data=PR_hormone;
where time >= -1;
class subject condition time;
model delta_GLP = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@ar(1) r rcorr;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition*time
	'effect on GLP in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on GLP in response to erythritol compared to sucrose' 1 0 -1 / adjdfe=row adjust=bon stepdown;
run;

/* with dosage */
proc sort data=PR_hormone;
by condition;
run;

proc standard data=PR_hormone mean=0 std=1 out=PR_hormone_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;
/* z-transforming dosage, to counteract the huge differences between erythritol and sucralose */

proc univariate data=PR_hormone_z_dosage;
where condition NE 'sucrose'and time >= -1;
by condition;
var dosage;
run;

proc mixed data=PR_hormone_z_dosage;
class subject condition time;
where condition NE 'sucrose'and time >= -1;
model delta_GLP = condition | time | dosage / ddfm=kr2 influence solution residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
estimate 'effect of dosage in erythritol' dosage 1 dosage*condition 1 0;
estimate 'effect of dosage in sucralose' dosage 1 dosage*condition 0 1;
estimate 'main effect of dosage' dosage 1;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on GLP in response to erythritol compared to sucralose' 1 -1 0 / adjdfe=row adjust=bon stepdown;
run;