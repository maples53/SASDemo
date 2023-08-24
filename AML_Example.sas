options msglevel=i;
options sastrace=",,,d" sastraceloc=saslog no$stsuffix;

/* AWS Snowflake Environment:  saspartner.snowflakecomputing.com */
libname snow2aws sasiosnf server="saspartner.snowflakecomputing.com" user="jakoch" 
                          password="{SAS004}66BBBE1AD37BEF2CB96375929869C77100FD0F4D7145F59F"
                          database="USERS_DB" schema="JAKOCH" warehouse="USERS_WH"
                          sqlgeneration=dbms;

proc datasets lib=snow2aws;
run;

/* Pass-Thru */

data work.snowexplicit;
set snow2aws.AML_PARTY_SUMMARY;
where PARTY_TYPE='Individual' and tag = 'Geo_Risk';
run;

/* Join Example */
proc sql;
  create table snowjoin as                    
     (select t1.policy_no, t1.age, t2.vehicle_no, t2.vehicle_age 
     from snow2aws.AUTO_POLICY as t1, snow2aws.AUTO_VEHICLE as t2 
     where (t1.policy_no = t2.policy_no and t1.vehicle_no = t2.vehicle_no));
quit;

proc freq data=snow2aws.AML_PARTY_SUMMARY;
tables CUSTOMER_TENURE INDUSTRY_DESC;
run;

/* Load AML Party Summary to Memory*/

cas mysession;
caslib _all_ assign;

proc sql;
  create table casuser.AML_PARTY_SUMMARY as
  select * from snow2aws.AML_PARTY_SUMMARY;
quit;

proc casutil sessref=mysession;
	promote casdata='AML_PARTY_SUMMARY' incaslib='casuser' casout='AML_PARTY_SUMMARY' 
		outcaslib='casuser';
run;

proc casutil sessref=mysession;
	save casdata='AML_PARTY_SUMMARY' incaslib='casuser' 
		casout='AML_PARTY_SUMMARY' outcaslib='casuser';
run;

cas mysession terminate;