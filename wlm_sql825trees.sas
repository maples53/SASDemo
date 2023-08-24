/* 5M rows takes ~ 25 minutes */
/* 1M rows takes ~ 5 minutes */
/* Currently set for 1M rows */

libname shared '/shared';

%let sql825="/shared/sql825trees.txt";  /* Location and name of sql825 code */
filename sql825 &sql825;

%include sql825;
run;