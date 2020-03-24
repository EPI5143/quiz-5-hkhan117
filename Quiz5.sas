From the class data:
Determine the proportion of admissions which recorded a 
diagnosis of diabetes for admissions between January 1st 2003 
and December 31st, 2004.  Generate a frequency table of frequency 
of diabetes diagnoses, with the denominator being the total number
of admissions between January 1st 2003 and December 31st, 2004 .
This exercise requires sorting, flat-filing, and linking (merging) 
tables.
Hints:  
1.	 From the NhrAbstracts dataset, you will have to create a 
new dataset which contains only unique admissions (hraEncWID) 
with admit dates (hraAdmDtm) between January 1st, 
2003 and December 31st, 2004: this is your spine dataset.;

libname classdat '/folders/myfolders/database/class_data';

libname ex '/folders/myfolders/database/EPI5143 work folder/data';

data ex.nhrabstracts;
set classdat.nhrabstracts;
if year(datepart(hraAdmDtm)) in (2003:2004); 
run;

proc sort data=ex.nhrabstracts out=ex.unique nodupkey;
by hraEncWID;
run;

2.	 From the NhrDiagnosis table you will need to determine 
if one or more diagnosis codes (hdgcd)  for diabetes (ICD9 
starting with ‘250’ or ICD10 starting with ‘E11’ or ‘E10’) was present 
for each encounter  in the diagnosis table and create an indicator 
variable called DM (=0 for no diabetes codes, =1 for one or more diabetes codes).; 

data ex.nhrdiagnosis;
set classdat.nhrdiagnosis;
if hdgcd in:('250' 'E11' 'E10')
then DM=1;
else DM=0;  
run; 
Proc sort data=ex.nhrdiagnosis out=ex.q2;
by hdghraencwid;
run;

3.	You will need to flatten your diabetes diagnoses dataset with respect 
to encounter ID (hdgHraEncWID).;

Proc means data=ex.q2 noprint;
class hdghraencwid;
types hdghraencwid;
var DM;
Output out=ex.count max(DM)=DM n(DM)=count sum(DM)=dm_count;
run;

Proc sort data=ex.count out=ex.q3 nodupkey;
by hdghraencwid;
run;

4.	You will need to link the spine dataset you generated from NhrAbstracts 
and the flattened diabetes diagnoses dataset you generated based on the 
NhrDiagnosis table using the encounter id’s from each database (renaming as required).;

data ex.final;
merge ex.unique:(in=a) ex.q3:(in=b rename=(hdghraencwid=hraEncWID));
by hraEncWID;
if a;
if DM=. then DM=0;
if count=. then count=0;
if dm_count=. then dm_count=0;
run;

5.	Your final dataset should have the same # of observations (and include all encounter IDs) 
found in your the spine dataset and have an indicator variable, DM which is 1 if any diabetes 
code was present, and 0 otherwise.;

proc freq data=ex.final;
tables DM count dm_count;
run;








