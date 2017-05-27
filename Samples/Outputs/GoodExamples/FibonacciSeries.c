#include <stdio.h>
#include "fclib.h"


int main ()
{
	int i, n, t1=0, t2=1, nextTerm=0
	puts("Enter the number of terms: ");
n=atoi(gets());
puts("Fibonacci Series: ");
	for(i=1;i <= n;i=i + 1)
	{
	if(i == 1)
	{
	printf("%d", t1);
continue;

}
if(i == 2)
	{
	printf("%d", t1);
continue;

}
nextTerm=t1 + t2;
t1=t2;
t2=nextTerm;
printf("%d", nextTerm);

}
return 0;


}

/*Your program is lexicaly and syntactically correct!!*/