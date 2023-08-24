libname shared '/shared';

proc datasets lib=shared;
run;

proc contents data=shared.insurance_years;
run;

proc freq data=shared.insurance_years;
table continent country;
run;

proc means data=shared.insurance_years;
output out=work.ins_means;
run;

proc sort data=shared.insurance_years (keep=age income) out=work.ins_sorted;
by age;
run;

proc summary data=work.ins_sorted;
by age;
var income;
output out=work.ins_summary;
run;

proc transpose data=work.ins_summary out=work.ins_summary_transposed prefix=Income_;
by age;
var income;
id _stat_;
run;

proc sql;
create table work.joined as select a.policyno, a.income, b.* from shared.insurance_years a left join work.ins_summary_transposed b on a.age=b.age;
quit;

data work.features;
set work.joined;
income_mean_diff = income - income_mean;
income_min_diff = income - income_min;
income_max_diff = income - income_max;
run;

