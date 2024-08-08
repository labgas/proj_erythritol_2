/* Generierter Code (IMPORT) */
/* Quelldatei: SAS_results_PolyReward.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PolyReward */
/* Code generiert am: 09.11.22 10:03 */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PolyReward/SAS_PolyReward.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

/* mean of BMI */
proc means data=WORK.IMPORT mean;
	var BMI_kg_m2;
run;
/* mean = 22.3240000 */


/* sd of BMI */
proc means data=WORK.IMPORT std;
	var BMI_kg_m2;
run;
/* sd = 1.7936481 */

/* mean of age */
proc means data=WORK.IMPORT mean;
	var age_yrs;
run;
/* mean = 25.8000000 */

/* sd of age */
proc means data=WORK.IMPORT std;
	var age_yrs;
run;
/* sd = 7.5370272 */