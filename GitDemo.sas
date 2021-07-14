data cars2;
	set sashelp.cars;
run;

/*This prints 10 observations*/
proc print data=cars2(obs=10);
run;