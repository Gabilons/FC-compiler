#include <stdio.h>
#include "fclib.h"

int i, k

int cube (int i )
{
	return i * i * i;


}
void add (int n ,int k )
{
	int j
	j=n + cube(k);
printf("%d", j);


}

int main ()
{
	k=atoi(gets());
i=atoi(gets());
add(k, i);
return 0;


}


/*Your program is lexicaly and syntactically correct!!*/