//subroutine caller convention
//this is a c program that uses method which we will then implement in ARM
//ce truc c'etait juste pour me rappeler comment les subroutines fonctionnent

	void main {
		int a;
		int b;
		int x = a+b;
		int z = times2(x);
		int y = z+1;
	}

	int times2(int x) {
		return shiftByOne(x);
	}

	int shiftByOne(int x){
		return x << 1;
	}

//then follows the corresponding ARM program using subroutines

				.text
				.global _start

_start: 
				LDR R1, =A			//R1 = a
				LDR R2, =B			//R2 = b
				ADD R0, R1, R2		//x = a+b
				BL times2			//z = times2(x)
				ADD R0, r0, #1		//y = z+1

times2:			PUSH {LR}			//store link register onto the stack
				BL shiftByOne		//branch to further subroutine
				POP {LR}			//pop LR to branch back
				BLR					//go back to main

shiftByOne		LSL R0, #1			
				BLR					//branch back to upper subroutine
