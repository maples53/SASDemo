options cashost="sasserver.demo.sas.com" casport=5570;
cas;
cas myCasSession3;

/*Assign all caslibs and then list them*/
caslib _ALL_ assign;
*caslib _ALL_ list;

/*CAS liname statement for accessing CAS tables*/
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

/*List CAS tables in caslib*/
proc casutil;
	*list tables incaslib="public";
	list tables incaslib="casuser";
run;

*proc print data=mycas.credit_example(obs=10);
*run;

*------------------------------------------------------------*;
* Macro Variables for input, output data and files;
  %let dm_datalib = mycas;
  %let dm_lib     = work;
  %let mod_lib    = casuser;
  %let dm_dataset = credit_example;
  %let dm_folder  = %sysfunc(pathname(work));
*------------------------------------------------------------*;
*------------------------------------------------------------*;
  * Training for gradboost;
*------------------------------------------------------------*;
*------------------------------------------------------------*;
  * Initializing Variable Macros;
*------------------------------------------------------------*;
%macro dm_unary_input;
%mend dm_unary_input;
%global dm_num_unary_input;
%let dm_num_unary_input = 0;
%macro dm_interval_input;
   'age'n 'CREDIT_SCORE'n 'hhincome'n 'T_debt'n 'T_debtserv'n
%mend dm_interval_input;
%global dm_num_interval_input;
%let dm_num_interval_input = 5 ;
%macro dm_binary_input;
'atmuser'n 'CARD_TYPE'n 'ecomuser'n 'GENDER'n 'OFFER_TYPE'n 'okmail'n
   'PROD_TYPE'n
%mend dm_binary_input;
%global dm_num_binary_input;
%let dm_num_binary_input = 7 ;
%macro dm_nominal_input;
'acctcd'n 'AGE_RNG'n 'behave_scr'n 'City'n 'CREDIT_LIM'n 'CREDIT_RNG'n
'currbal'n 'delnum'n 'empstat'n 'LIFESTYLE'n 'occtype'n 'prodnum'n 'PROD_CD'n
'RESSTAT'n 'ROC1'n 'ROC12'n 'ROC3'n 'ROC6'n 'STATE'n 't_asset'n 'T_liab'n
   'YEAR'n
%mend dm_nominal_input;
%global dm_num_nominal_input;
%let dm_num_nominal_input = 22 ;
%macro dm_ordinal_input;
%mend dm_ordinal_input;
%global dm_num_ordinal_input;
%let dm_num_ordinal_input = 0;
%macro dm_class_input;
'acctcd'n 'AGE_RNG'n 'atmuser'n 'behave_scr'n 'CARD_TYPE'n 'City'n
'CREDIT_LIM'n 'CREDIT_RNG'n 'currbal'n 'delnum'n 'ecomuser'n 'empstat'n
'GENDER'n 'LIFESTYLE'n 'occtype'n 'OFFER_TYPE'n 'okmail'n 'prodnum'n 'PROD_CD'n
'PROD_TYPE'n 'RESSTAT'n 'ROC1'n 'ROC12'n 'ROC3'n 'ROC6'n 'STATE'n 't_asset'n
   'T_liab'n 'YEAR'n
%mend dm_class_input;
%global dm_num_class_input;
%let dm_num_class_input = 29 ;
%macro dm_segment;
%mend dm_segment;
%global dm_num_segment;
%let dm_num_segment = 0;
%macro dm_id;
   'account_id'n 'address'n 'SSN'n
%mend dm_id;
%global dm_num_id;
%let dm_num_id = 3 ;
%macro dm_text;
%mend dm_text;
%global dm_num_text;
%let dm_num_text = 0;
%macro dm_strat_vars;
   'writeoff'n
%mend dm_strat_vars;
%global dm_num_strat_vars;
%let dm_num_strat_vars = 1 ;
*------------------------------------------------------------*;
  * Component Code;
*------------------------------------------------------------*;
proc gradboost data=&dm_datalib..&dm_dataset.
     earlystop(tolerance=0 stagnation=5 minimum=NO metric=MCR)
     binmethod=QUANTILE
     maxbranch=2
     assignmissing=USEINSEARCH minuseinsearch=1
     ntrees=100 learningrate=0.1 samplingrate=0.5 lasso=0 ridge=1 maxdepth=4 numBin=50 minleafsize=5
     seed=12345
     printtarget
  ;
  partition rolevar='_PartInd_'n (TRAIN='1' VALIDATE='0');
  target 'writeoff'n / level=nominal;
  input %dm_interval_input / level=interval;
  input %dm_binary_input %dm_nominal_input %dm_ordinal_input %dm_unary_input  / level=nominal;
  ods output
     VariableImportance   = &dm_lib..varimportance
     Fitstatistics        = &dm_lib..outfit
     PredProbName = &dm_lib..PredProbName
     PredIntoName = &dm_lib..PredIntoName
  ;
  id 'account_id'n 'address'n 'SSN'n;
  savestate rstore=&mod_lib.._credit_example_2_ast;
run;

proc casutil;
	*list tables incaslib="public";
	list tables incaslib="casuser";
	list files incaslib="casuser";
run;

*proc casutil outcaslib="casuser";                         /* 2 */
   *promote casdata="credit_example_2_ast";
*quit;

proc casutil incaslib="casuser" outcaslib="public";
   save casdata="_CREDIT_EXAMPLE_2_AST" replace;
quit;

cas myCasSession3 terminate;
