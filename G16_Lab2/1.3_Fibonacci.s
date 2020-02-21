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
				LDR R4, =RESULT
				MOV R1, #9			//n, we will calculate Fib(n)
				MOV R0, #0
				BL FIB				//call subroutine
				STR R0, [R4]
				B END

<<<<<<< HEAD
FIB:			CMP R1, #2
				MOVLT R3, #1
				BXLT LR

				MOV R1, R2
				SUB R2, R2, #1
FIB:			PUSH {LR}			//save link register

				CMP R1, #2			//check if we have a basecase
				BLLT BASECASE

				SUB R1, R1, #1		//get n-1
				SUB R3, R1, #1		//get n-2
				PUSH {R3}			//push the value of n-2 onto the stack to retrieve later
				BL FIB				//call fib(n-1)

				POP {R3}			//pop value of n-2 previously pushed
				PUSH {R1} 			//push the computed value of fib(n-1)
				MOV R1, R3 			//set R1 to be n-2, to compute fib(n-2)
				BL FIB 				//call fib(n-2)

				POP {R3}			//here R3 holds fib(n-1) which is popped from the stack and R1 currently holds fib(n-2)

				POP {LR}
				BX LR

BASECASE: 		ADD R0, R0, R1
				POP {LR}
				ADD R0, R0, R3
				BX LR

END:			B END

N: 				.word 5
				BX LR


END: 			B END

RESULT: 		.word 0
