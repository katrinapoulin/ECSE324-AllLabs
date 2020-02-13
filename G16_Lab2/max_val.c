#include "address_map_arm.h"

/* This program determines the maximum value of a list
using the MAX_2 subroutine in assembly.
*/

extern int MAX_2(int x, int y);

int main(){
	int a[5] = {1,20,3,4,5};
	int max_val=0;
	for (int i = 0; i < 5 ; i++){
		max_val = MAX_2(max_val,a[i]);
	}
	return max_val;

}
