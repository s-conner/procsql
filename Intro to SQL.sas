* Introduction to Proc SQL 
Sarah Conner
April 26 2018 ;


* ---------------------------
NEURO EXAMPLES
--------------------------- ;

%let pathname=%str(\\ad.bu.edu\bumcfiles\BUSM\Neurology\DEPT);
*%let pathname=%str(Y:);
*libname framdata "X:\FRAMDATA\2 -  Datasets -  Core";
libname framdata "\\ad.bu.edu\bumcfiles\SPH\Projects\FRAMDATA\2 -  Datasets -  Core";
libname Npath "&pathname\FHS-Neuro-JAK\JS\JJHdata\NPATH\Npath2014\";
option nofmterr;

/* Query dictionary.columns to find all datasets in FRAMDATA with a variable like 'hormone'
NOTE: this can take some time to run!*/
proc sql; select * from dictionary.columns where libname='FRAMDATA' and upcase(name) like '%hormone%'; quit;


/* Find all of the N table variables from old Neuropath data (however, prefix N alone will grab too many variables)
There are other ways to accomplish this, but just an example of how to use SQL to create a macro variable (with variable names, values, etc.)
*/
data npath; set Npath.Npath_all_n174_20141209j; run;
proc contents data=npath OUT=tablevars; run; 
/*proc print data=tablevars; var name; where (name like 'N%_R' or name like 'N%_L') and name not like 'NP%'; run; */
proc sql; select name into: varstokeep separated by ' ' from tablevars where (name like 'N%_R' or name like 'N%_L') and name not like 'NP%'; quit;
data npath_subset; set npath; keep varstokeep: ;  run;
proc print data=npath_subset (obs=10); run;





* ---------------------------
Slides 5&6: Summary Example 
--------------------------- ;

* Query & print the number of players per NW team;
proc sql; 
select Team, count(*) as PlayerCount
from sashelp.baseball 
where Div='NW'
group by Team
order by PlayerCount desc
;
quit;

* Same as above, but saved to a dataset 'teams' and restricted to >12 player teams;
proc sql; 
create table teams as 
select Team, count(*) as PlayerCount
from sashelp.baseball 
where Div='NW'
group by Team
having count(*)>12   /*Note: In SAS, you can use 'count(*)' or 'PlayerCount', but not true for all SQL*/
;
quit;
proc print data=teams; run;


* ---------------------------
Slide 6: Summary Example 2
--------------------------- ;
* Summary variable WITHOUT the 'group' line;
proc sql;
create table heart2 as
select weight, avg(weight) as avgweight, std(weight) as stdweight, (weight-avg(weight))/std(weight) as Z 
from sashelp.heart
;
quit;
proc print data=heart2 (obs=5); run;



* ---------------------------
Slide 9: Example of LEFT JOIN
--------------------------- ;
* Create a smaller sample of the dataset;
proc surveyselect data=sashelp.zipcode method=srs seed=1 n=1000 out=zipcode noprint; run;
data us_data; set sashelp.us_data; run;

* Merge the datasets by state;
proc sql; 
create table zipcode2 as
select u.division, u.region, z.*
from zipcode z
left join us_data u on z.statename=u.statename
where z.statename='New York';
quit;
proc print data=zipcode2 (obs=10); run;

/* *Equivalent SAS code;
proc sort data=zipcode; by statename; run;
proc sort data=us_data; by statename; run;
data zipcode2b; 
retain division region;
merge zipcode(in=a) us_data(keep=statename division region);
by statename;
if statename='New York' and a;
run;
proc print data=zipcode2b (obs=10); run;
*/


* ---------------------------
Slide 14: Nested Queries
--------------------------- ;
* Get the zipcodes for cities corresponding baseball teams;
proc sql; 
select zip, city
from zipcode
where city in
	( select team 
	from sashelp.baseball )
;
quit;


* ---------------------------
Slide 16: DISTINCT
--------------------------- ;
proc sql; 
select distinct team 
from sashelp.baseball 
;

select count(distinct team)
from sashelp.baseball 
;
quit;


* ---------------------------
Slide 17: MACRO VARIABLES
--------------------------- ;

* Just to see the variables and dictionary.columns table;
proc sql; 
select *
from dictionary.columns 
where libname='WORK' and memname='US_DATA' 
; quit;

* Insert the '2010' variables into a macro variable;
proc sql; 
select distinct name
into: vars2010 separated by ' ' 
from dictionary.columns 
where libname='WORK' and memname='US_DATA' and name like '%2010%'
; quit;

data us_data_2010;
set us_data (keep=statename &vars2010);
run;

proc print data=us_data_2010 (obs=10); run;

