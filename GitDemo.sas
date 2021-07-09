data cars2;
	set sashelp.cars;
run;

/*proc print to review the first 10 records*/
proc print data=cars2(obs=10);
run;

