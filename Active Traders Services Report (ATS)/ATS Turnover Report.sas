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
										



%LET path = /folders/myfolders/Projects/Banking Project Securites/Active traders service report;


/* import Day */
%LET extn = xls;
%LET FileName = ATG_1;
%LET OutName = ATG_1;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import Day */
%LET extn = xls;
%LET FileName = IDIR_1;
%LET OutName = IDIR_1;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import Day */
%LET extn = xls;
%LET FileName = ATG_2;
%LET OutName = ATG_2;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import Day */
%LET extn = xls;
%LET FileName = IDIR_2;
%LET OutName = IDIR_2;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

/* import Day */
%LET extn = xls;
%LET FileName = AGF1;
%LET OutName = AGF1;
%LET Dot = .;
PROC import datafile="&path/&FileName&Dot&extn"
DBMS = &extn
out = &OutName
REPLACE;
Run;

DATA AGF1;
set AGF1(rename=(  EQUITY_TURNOVER = temp_EQUITY_TURNOVER DERIVATIVE_TURNOVER=temp_DERIVATIVE_TURNOVER EQUITY_BROKERAGE=temp_EQUITY_BROKERAGE DERIVATIVE_BROKERAGE=temp_DERIVATIVE_BROKERAGE));
LENGTH ET 4.2 DT 4.2 EB 4.2 DB 4.2;
FORMAT ET 4.2 DT 4.2 EB 4.2 DB 4.2;
Array c(4)  temp_EQUITY_TURNOVER temp_DERIVATIVE_TURNOVER temp_EQUITY_BROKERAGE temp_DERIVATIVE_BROKERAGE;
Array a(4) ET DT EB DB;
Array b(4) _temporary_ (0 0 0 0);
do i=1 to 4;
if c(i) EQ "" THEN a(i)=b(i);
end;

DROp temp_EQUITY_TURNOVER temp_DERIVATIVE_TURNOVER temp_EQUITY_BROKERAGE temp_DERIVATIVE_BROKERAGE I;
Run;


/* Merge the datasets for the ATS Turnover Report */
DATA turnover;
Merge ATG_1(in=a) IDIR_1(in=b);
if a and b;
Run;


/* Merge the datasets for the ATS Gross Margin Report */
DATA grossmargin;
Merge ATG_2(in=a) IDIR_2(in=b);
if a and b;
Run;



ods html file="/folders/myfolders/Projects/Banking Project Securites/Active traders service report/Turnover Report.html";
PROC REPORT data=turnover split="*";
Column  ("Cash Turnover (Rs Crores)" E_CASH  I_CASH) a  ("Magin and Margin Plus Turnover (Rs Crores)" E_MARGIN I_MARGIN) b ("Derivatives Turnover (Rs Crores)" E_DER I_DER) c ("Total Turnover (Rs Crores)" E_TOTAL I_TOTAL) d;
DEFINE E_CASH / "ATS ONLINE" f=COMMA8.2;
DEFINE I_CASH / "ICICIdirect" f=COMMA8.2;
DEFINE a / "% of ICICIdirect turnover" f=PERCENT8.2;
DEFINE  E_MARGIN / "ATS ONLINE" f=COMMA8.2;
DEFINE I_MARGIN / "ICICIdirect" f=COMMA8.2;
DEFINE b / "% of ICICIdirect turnover" f=PERCENT8.2;
DEFINE E_DER / "ATS ONLINE" f=COMMA8.2;
DEFINE I_DER / "ICICIdirect" f=COMMA8.2;
DEFINE c / "% of ICICIdirect turnover" f=PERCENT8.2;
DEFINE E_TOTAL / "ATS ONLINE" f=COMMA8.2;
DEFINE I_TOTAL / "ICICIdirect" f=COMMA8.2;
DEFINE d / "% of ICICIdirect turnover" f=PERCENT8.2;

Compute a;
a = _c1_/_c2_;
endcomp;

Compute b;
b = _c4_/_c5_;
endcomp;

Compute c;
c = _c7_/_c8_;
endcomp;

Compute d;
d = _c10_/_c11_;
endcomp;
title italic "ATS ONLINE Report (Turnover)";
Run;
ods html close;




ods html file="/folders/myfolders/Projects/Banking Project Securites/Active traders service report/Gross Margin Report.html";
PROC REPORT data=grossmargin split="*";
Column  ("Equity Brokerage (Rs Lakhs)"  EAG_EQ_BRO IDIR_EQ_BRO) a  ("Derivative Brokerage (Rs Lakhs)"  EAG_DER_BRO IDIR_DER_BRO) b  ("Total (Rs Lakhs)"  SUM_EAG SUM_IDIR) c;
DEFINE EAG_EQ_BRO / "ATS ONLINE" f=COMMA8.2;
DEFINE IDIR_EQ_BRO / "ICICIdirect" f=COMMA8.2;
DEFINE a / "% of ICICIdirect turnover" f=PERCENT8.2;
DEFINE  EAG_DER_BRO / "ATS ONLINE" f=COMMA8.2;
DEFINE IDIR_DER_BRO / "ICICIdirect" f=COMMA8.2;
DEFINE b / "% of ICICIdirect turnover" f=PERCENT8.2;
DEFINE SUM_EAG / "ATS ONLINE" f=COMMA8.2;
DEFINE SUM_IDIR / "ICICIdirect" f=COMMA8.2;
DEFINE c / "% of ICICIdirect turnover" f=PERCENT8.2;

Compute a;
a = _c1_/_c2_;
endcomp;

Compute b;
b = _c4_/_c5_;
endcomp;

Compute c;
c = _c7_/_c8_;
endcomp;

title italic "ATS ONLINE Report (Gross Brokerage)";

Run;
ods html close;



ods html file="/folders/myfolders/Projects/Banking Project Securites/Active traders service report/ATS Offline Turnover and Margin Report.html";
PROC Report data=AGF1;
COLUMN  ET DT EB DB;
DEFINE ET / "Equity Turnover(Rs Millions)";
DEFINE DT / "Derivative Turnover(Rs Millions)";
DEFINE EB / "Equity Brokerage(Rs Lakhs)	";
DEFINE DB / "Derivative Brokerage(Rs Lakhs)";
title "ATS OFFLINE Turnover & Brokerage Report as on 16 July" ;
Run;
ods html close;


PROC SQL;
	drop table WORK.ATG_2;
	drop table WORK.IDIR_2;
	drop table WORK.ATG_1;
	drop table WORK.IDIR_1;
	drop table WORK.Turnover;
	drop table WORK.GrossMargin;
	drop table WORK.AGF1;
Run;




PROC SQL;
	
Run;





