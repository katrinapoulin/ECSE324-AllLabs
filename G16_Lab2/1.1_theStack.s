// 1.1 the stack 

// PUSH {R0}

// STR R0, [SP, #-4]!

// POP {R0 - R2}

// LDR R0, [SP], #4
// LDR R1, [SP], #4
// LDR R2, [SP], #4

				.text
				.global _start

_start:
				//PUSH OPERATION
				LDR R0, #0
				LDR R1, #1
				LDR R2, #2

				//POP OPERATION
				STR R0, [SP, #-4]!
				STR R1, [SP, #-4]!
				STR R2, [SP, #-4]!

				//TEST
				LDR R2, [SP, #4]!
				LDR R1, [SP, #4]!
				LDR R0, [SP, #4]!

END:			B END

// this is litteraly useless i don't get this part




