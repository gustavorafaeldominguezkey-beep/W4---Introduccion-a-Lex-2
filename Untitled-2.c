%{
 #include <stdio.h>

 int is_string = 0;
 
%}

%%
\"   {
  if (is_string=0){
  printf ("start of string");
  is_string = 1;
   }else{
   printf ("end of string");
  is_string = 0;

} 

  }

  printf("")

 
 
%}     



%%

