FILENAME REFFILE '/folders/myfolders/Energy Use Number 10 Downing St 2017.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.downing10;
	GETNAMES=YES;
RUN;

proc print data=WORK.downing10;
run;

proc sort data=WORK.downing10 out=WORK.downing10sorted;
	BY Date Time_of_day;
run;

data WORK.downing10sorted;
set WORK.downing10sorted;
	fdow=intnx('week',Date,0,'B');
	format fdow DDMMYY8.;
run;

ods graphics / reset width=16in height=8in imagemap;

proc sgplot data=WORK.downing10sorted;
	title height=16pt "Weekly Average of Energy Use at Downing Street 10 in 2017";
	heatmap x=fdow y=Time_of_day / name='HeatMap' discretex discretey colormodel=(CX5760e7 
		CX51a1a5 CXb8c76f CXe93c07) colorresponse=Electricity_Used__kwH_;
	gradlegend 'HeatMap';
	xaxis label='First Day of The Week';
	Footnote h=6pt 'Source: Carbon Culture' ;
run;

ods graphics / reset;
title;