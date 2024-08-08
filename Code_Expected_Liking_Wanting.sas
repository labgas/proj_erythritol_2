/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_reward_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 01.06.23 15:12 */

%web_drop_table(PR_Reward);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_reward_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PR_Reward;
	GETNAMES=YES;
	SHEET="Expected_Liking_Wanting";
RUN;

PROC CONTENTS DATA=PR_Reward; RUN;


%web_open_table(PR_Reward);

/* check distribution of liking */
proc univariate data=PR_Reward;
var liking;
histogram liking / normal;
run;

/*---------------------------*/
/* model for expected liking */
/*---------------------------*/

/* only time point 0 for expected... not the changes from 0 min to 1 min after one sip */
proc mixed data=PR_Reward;
class subject condition time;
where time = 0;
model liking = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@un r rcorr;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition
	'effect on expected liking in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on expected liking in response to erythritol compared to sucrose' 1 0 -1/ adjdfe=row adjust=bon stepdown;
run;

/* correct model of expected liking */
proc mixed data=PR_Reward; 
class subject condition time;
where time = 0;
model liking = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjdfe=row adjust=tukey;
run;

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

/* check distribution of wanting */
proc univariate data=PR_Reward;
var wanting;
histogram wanting / normal;
run;

/*----------------------------*/
/* model for explicit wanting */
/*----------------------------*/

/* only time point 0 for expected... not the changes from 0min to 1 min after one sip */
proc mixed data=PR_Reward;
class subject condition time;
where time = 0;
model wanting = condition | time / ddfm=kr2 influence solution residual;
repeated condition time/ subject=subject type=un@un r rcorr;
lsmeans condition / diff=all adjdfe=row adjust=tukey;
lsmeans time / diff=all;
lsmeans condition*time / slice=time slice=condition adjdfe=row;
lsmestimate condition*time
	'effect on expected wanting in response to erythritol compared to sucralose' 1 -1 0, 
	'effect on expected wanting in response to erythritol compared to sucrose' 1 0 -1/ adjdfe=row adjust=bon stepdown;
run;

/* correct model for expected wanting */
proc mixed data=PR_Reward; 
class subject condition time;
where time = 0;
model wanting = condition / solution; 
repeated condition / subject = subject type=un r rcorr; 
lsmeans condition / diff = all adjdfe=row adjust=tukey;
run;
