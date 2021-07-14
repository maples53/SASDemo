%let sleep_time = 20;

data _null_;
x=sleep(&sleep_time.);
run;

proc print data=sashelp.cars(obs=5);
run;

