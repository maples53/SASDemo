

options cashost="sasserver.demo.sas.com" casport=5570;
cas;
cas myCasSession4;

/*Assign all caslibs and then list them*/
caslib _ALL_ assign;

/*CAS liname statements for accessing CAS tables*/
libname mycas cas caslib=casuser;

/*List available files in a caslib*/
*proc casutil;
 	*list files incaslib="public";
*run;

/*Read CAS table into memory*/
proc casutil;
	load casdata="CREDIT_DISCOVERY_FOR_DS.sashdat"
 	INCASLIB="public"
 	/*OUTCASLIB="public"*/
 	casout="credit_example"
	REPLACE;
run;

proc partition data=mycas.credit_example samppct=50 seed=10 nthreads=1;
   output out=mycas.writeoff_1_1Q;
run;

proc partition data=mycas.credit_example samppct=50 seed=11 nthreads=1;
   output out=mycas.writeoff_2_2Q;
run;

proc partition data=mycas.credit_example samppct=50 seed=12 nthreads=1;
   output out=mycas.writeoff_3_3Q;
run;

proc partition data=mycas.credit_example samppct=50 seed=13 nthreads=1;
   output out=mycas.writeoff_4_4Q;
run;

data mycas.writeoff_2_2Q;
	set mycas.writeoff_2_2Q;
	if _N_ <= 200 then do;
		select(writeoff);
		when('YES') writeoff='NO';
 		when('NO') writeoff='YES';
		end;
	end;
run;

data mycas.writeoff_3_3Q;
	set mycas.writeoff_3_3Q;
	if _N_ <= 500 then do;
		select(writeoff);
		when('YES') writeoff='NO';
 		when('NO') writeoff='YES';
		end;
	end;
run;

data mycas.writeoff_4_4Q;
	set mycas.writeoff_4_4Q;
	if _N_ <= 700 then do;
		select(writeoff);
		when('YES') writeoff='NO';
 		when('NO') writeoff='YES';
		end;
	end;
run;

/*proc casutil incaslib="casuser" outcaslib="public";
	save casdata="writeoff_1_1Q" replace;
	save casdata="writeoff_2_2Q" replace;
	save casdata="writeoff_3_3Q" replace;
	save casdata="writeoff_4_4Q" replace;
quit;*/
/*terminate cas session*/
cas myCasSession4 terminate;