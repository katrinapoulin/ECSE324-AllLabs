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
				LDR R1, =N
				LDR R1, [R1]
				SUB R2, R1, #1

FIB:			CMP R1, #2
				MOVLT R3, #1
				BXLT LR

				MOV R1, R2
				SUB R2, R2, #1

				PUSH {LR}
				BL FIB
				POP {LR}
				ADD R0, R0, R3
				BX LR

END:			B END

N: 				.word 5
