//Fibonacci computation

// c code
//Fib(n):
//	if (n >= 2) {
//		return Fib(n-1) + Fib(n-2);
//	} else if (n < 2) {
//		return 1;
//	}

//ARM assembly

				.text
				.global _start

_start:
				LDR R3, =RESULT
				MOV R0, #9			//n, we will calculate Fib(n)
				MOV R1, #0
				BL FIB				//call subroutine
				STR R1, [R3]
				MOV R0, R1
				B END

FIB:			PUSH {LR}			//save link register

				CMP R0, #2			//check if we have a basecase
				BLLT BASECASE

				SUB R0, R0, #1		//get n-1
				SUB R2, R0, #1		//get n-2
				PUSH {R2}			//push the value of n-2 onto the stack to retrieve later
				BL FIB				//call fib(n-1)

				POP {R2}			//pop value of n-2 previously pushed
				PUSH {R0} 			//push the computed value of fib(n-1)
				MOV R0, R2 			//set R1 to be n-2, to compute fib(n-2)
				BL FIB 				//call fib(n-2)

				POP {R2}			//here R3 holds fib(n-1) which is popped from the stack and R1 currently holds fib(n-2)

				POP {LR}
				BX LR

BASECASE: 		ADD R1, R1, #1
				POP {LR}
				BX LR


END: 			B END

RESULT: 		.word 0
