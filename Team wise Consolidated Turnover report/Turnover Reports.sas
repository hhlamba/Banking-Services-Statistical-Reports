
/* Author: Harmeet Lamba */



/* Import Files: Set the following Macro variables for each file: 				*/
/* 1. &path 		: Path of the Folder where your file is located 			*/
/* 2. &extn		: Extension of the file (example .xls .csv .tab) 				*/
/* 3. &FileName	: Name of the file you want to import 							*/
/* 4. &OutFileName	: Name of the file you want it to take in the SAS system 	*/


/* SAS Concepts and Steps used 			*/
/* 1. Macro Varaibles 					*/
/* 2. Merge Datasets using DATA step 	*/
/* 3. Union datasets using DATA step	*/
/* 4. Format and Informat 				*/
/* 5. Data Manipulation 				*/
/* 6. SAS Functions  					*/
/* 7. Arrays  							*/
/* . DATA Step 							*/
/* . PROC  								*/
/* 			a) IMPORT 					*/
/* 			b) PRINT 					*/
/* 			c) SORT 					*/
/* 			d) TRANSPOSE 				*/
/* 			e) SQL 						*/
/* 			f) REPORT 					*/
/* 			g) FORMAT 					*/
										



%LET path = /folders/myfolders/Projects/Banking Project Securites/Consolidation team wise turnover report;


/* import Day */
%LET extn = xls;
%LET FileName = DAY;
%LET OutName = DAY;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import EQB */
%LET extn = xls;
%LET FileName = EQB;
%LET OutName = EQB;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import mtd */
%LET extn = xls;
%LET FileName = MTD;
%LET OutName = MTD;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import NRDB */
%LET extn = xls;
%LET FileName = NRDB;
%LET OutName = NRDB;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;


/* import NRT */
%LET extn = xls;
%LET FileName = NRT;
%LET OutName = NRT;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import PREDAY */
%LET extn = xls;
%LET FileName = PREDAY;
%LET OutName = PREDAY;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import TI2 */
%LET extn = xls;
%LET FileName = TI2;
%LET OutName = TI2;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import TI4 */
%LET extn = xls;
%LET FileName = TI4;
%LET OutName = TI4;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import TI_1 */
%LET extn = xls;
%LET FileName = TI_1;
%LET OutName = TI_1;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import YTD */
%LET extn = xls;
%LET FileName = YTD;
%LET OutName = YTD;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import TVSA2 */
%LET extn = xls;
%LET FileName = TVSA2;
%LET OutName = TVSA2;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import TVSA_1 */
%LET extn = xls;
%LET FileName = TVSA_1;
%LET OutName = TVSA_1;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;





/* Getting the datasets ready to merge: */
/* 		i) First Sort DAY, PREDAY, MTD and YTD */
/* 		ii) Now Merge DAY - PREDAY - MTD - YTD */





/* 		i) First Sort DAY, PREDAY, MTD and YTD */
proc sort data = day out= days;
by NAME;
Run;


proc sort data = preday out= predays;
by NAME;
Run;


proc sort data = mtd out= mtds;
by NAME;
Run;


proc sort data = ytd out= ytds;
by NAME;
Run;





/* 		ii) Now Merge DAY - PREDAY - MTD - YTD */


DATA new;
MERGE day(in=a) predays(in=b);
by NAME;
if a and b;
Run;

DATA new;
MERGE new(in=a) mtds(in=b);
by NAME;
if a and b;
Run;


DATA new;
MERGE new(in=a) ytds(in=b);
by NAME;
if a and b;
Run;



/* Calculating "Changes from Previous Day" = DAY - PREDAY */
/* Drop PREDAY */


DATA new(DROP=PREDAY);
retain NAME DAY CHANGE MTD YTD;
set new;
CHANGE = DAY - PREDAY;
Run;



/* Pre-processing NRI records from 3 files NRT NRDB and EQB */

/* First merging EQB and NRDB */

DATA NRI_BRKG(drop=DR_BR EQ_BR);
merge EQB(in=a) NRDB(in=b);
if a and b;
BRKG = EQ_BR + DR_BR;
Run;

/* Now merging NRI_BRKG and NRT */

DATA NRI_FINAL;
MERGE NRI_BRKG(in=a) NRT(in=b);
if a and b;
Run;



/* Pre-processing ATS records using TI4 dataset */


/* Creating a dummy dataset using DATA steps and Cards*/

DATA ats_dummy;
infile cards dlm=",";
LENGTH Team $12.;
FORMAT Team $12.;
INFORMAT Team $12.;
input Team $ BRKG $ TRADER $;
cards;
ATS, , 
;
Run;


/* Merging TI4 and ats_dummy and assigning 0s to all columns using ARRAYs*/

DATA ats_dummy;
Merge ats_dummy(in=a rename=(BRKG=temp_BRKG TRADER=temp_trader)) 
TI4(in=b drop=EQ_BR DR_BR rename=(EQ_TO4=temp_EQ_TO4 FO_TO3=temp_FO_TO3 TOT=temp_tot));
if a and b;
LENGTH BRKG 8 TRADER 8 TOT 8 EQ_TO4 8 FO_TO3 8 TOT 8;
BRKG = put(temp_brkg,8.);
TRADER = put(temp_trader,8.);
TOT = put(temp_tot, 8.);
EQ_TO4 = put(temp_EQ_TO4, 8.);
FO_TO3 = put(temp_FO_TO3, 8.);
;
DROP temp_brkg temp_trader temp_eq_to4 temp_fo_to3 temp_tot;
Run;

DATA ats_final;
set ats_dummy;
Array a(5) BRKG EQ_TO4 FO_TO3 TRADER TOT;
Array b(5) _temporary_ (0 0 0 0 0);
Do i=1 to 5;
if a(i) = . THEN a(i)=b(i);
end;
DROP I;
Run;


/* Union NRI_FINAL with ATS_FINAL */
DATA NRI_ATS;
retain TEAM BRKG EQ_TO4 FO_TO3 TOT TRADER;
set ATS_FINAL NRI_FINAL;
Run;

PROC Transpose data = tvsa_1 out=subtotals;
var  EQ_TO4 FO_TO3 TOT TRADER;
id TEAM;
Run;

DATA subtotals(drop=_LABEL_ ATG CENTER DBC DBC_NRI EAG EAG_NRI RETAIL_NRI RETAIL_RI rename=(Retail_new = Retail EAG_new = EAG));
retain NAME SUB_BROKER EAG_new	ATS_ONLINE	STORE	RETAIL_new	ATS_OFFLINE	NRI;
set subtotals(rename=(_NAME_ = NAME));
Retail_new = Retail_NRI + REtail_RI;
EAG_new = sum(EAG, EAG_NRI);
STORE = CENTER;
ATS_ONLINE = ATG;
SUB_BROKER = Sum(DBC, DBC_NRI);
Run;


/* Create a dummy Record for BRKG row */

DATA subtotals_BRKG;
infile cards dlm=",";
length NAME $8. SUB_BROKER 8 EAG 8	ATS_ONLINE 8	STORE 8	RETAIL 8;
input NAME $ SUB_BROKER EAG	ATS_ONLINE	STORE	RETAIL;
cards;
BRKG,1.2,3.2, 4.2, 2.4, 12.7
;
Run;

/* Union the results together */

DATA subtotals;
LENGTH Name $12;
Set subtotals subtotals_BRKG;
Run;


/* Merge all Datasets together */

PROC TRANSPOSE data=nri_ats out=nri_ats(drop=_LABEL_ rename=(_NAME_ = NAME));
var BRKG EQ_TO4 FO_TO3 TOT TRADER;
id Team;
Run;

/* Pre-processsing datasets for Merge. */

/* 1. Sort the datasets */

PROC SORT data=new out=new;
by Name;
Run;

PROC SORT data=NRI_ATS out=NRI_ATS;
by Name;
Run;

PROC SORT data=subtotals out=subtotals;
by Name;
Run;


/* 2. Merge datasets */

DATA Final;
merge Subtotals(in=a) NRI_ATS(in=b);
by Name;
if a and b;
Run;


DATA Final;
merge Final(in=a) new(in=b);
by Name;
if a and b;
Run;

DATA order;
infile cards dlm=",";
LENGTH Name $12. order 8 Particulars $30.;
input Order Name $ Particulars $;
cards;
4,BRKG,Total Revenue(in mn)
1,EQ_TO4,Equity Turnover(in mn)
2,FO_TO3,Derivative Turnover(in mn)
3,TOT,Total Turnover(in mn)
5,TRADER,Total Traders(Nos.)
;
Run;


DATA Final;
MERGE Order(in=a) Final(in=b);
if a and b;
Run;


PROC sort data = Final out = Final(drop=Order);
by Order;
Run;

/* Delete the files you don't use */
proc sql;
  drop table WORK.DAY;
  drop table WORK.PREDAY;
  drop table WORK.MTD;
  drop table WORK.YTD;
  drop table WORK.DAYS;
  drop table WORK.PREDAYS;
  drop table WORK.MTDS;
  drop table WORK.YTDS;
  drop table WORK.NRDB;
  drop table WORK.EQB;
  drop table WORK.NRT;
  drop table WORK.NRI_BRKG;
  drop table WORK.ats_dummy;
  drop table WORK.TI4;
  drop table WORK.NRI_FINAL;
  drop table WORK.ATS_final;
  drop table WORK.subtotals_brkg;
  drop table WORK.Subtotals;
  drop table WORK.NRI_ATS;
  drop table WORK.NEw;
  drop table WORK.TVSA_1;
  drop table WORK.TI_1;
  drop table WORK.TI2;
  drop table WORK.TVSA2;
  drop table Work.order;
quit;
/* Delete the files you don't use */

/*  */
/* PROC REPORT data = Final split="*"; */
/* COLUMNS Particulars SUB_BROKER EAG	ATS_ONLINE	STORE	RETAIL ATS NRI DAY CHANGE MTD YTD; */
/* DEFINE Name / computed "Name"; */
/* DEFINE a / "PARTICULARS";  */
/* DEFINE SUB_BROKER  / "SUB-*BROKER" ; */
/* DEFINE EAG  / "EAG" ; */
/* DEFINE	ATS_ONLINE  / "ATS*ONLINE" ; */
/* DEFINE	STORE / "STORE" ; */
/* DEFINE	RETAIL / "RETAIL" ; */
/* DEFINE ATS / "ATS*OFFLINE" ; */
/* DEFINE NRI / "NRI" ; */
/* DEFINE DAY / "TOTAL" ; */
/* DEFINE CHANGE / "CHANGES*FROM*PREVIOUS*DAY" ; */
/* DEFINE MTD / "JUL*TOTAL" ; */
/* DEFINE YTD / "FY 10-11*TOTAL" ; */
/*  */
/* compute a; */
/* a  = _row1_ + _row2_; */
/* endcomp; */
/* Run; */

