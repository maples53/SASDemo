data cars2;
	set sashelp.cars;
run;

proc print data=cars2(obs=10);
run;