// 1.1 the stack 

// PUSH {R0}

// STR R0, [SP, #-4]!

// POP {R0 - R2}

// LDR R0, [SP], #4
// LDR R1, [SP], #4
// LDR R2, [SP], #4

				.text
				.global _start

//_start:		

				MOV R0, #0
				MOV R1, #1
				MOV R2, #2

				//PUSH OPERATION
				STR R2, [SP, #-4]!
				STR R1, [SP, #-4]!
				STR R0, [SP, #-4]!

				//POP OPERATION
				LDR R3, [SP], #4
				LDR R4, [SP], #4
				LDR R5, [SP], #4


END:			B END



