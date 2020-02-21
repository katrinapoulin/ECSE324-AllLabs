					.text
					.global _start

//_start:			
				LDR R5, =RESULT
				LDR R3, =NUMBERS			//R3 points to the first number of the list
				LDR R4, [R3, #-4]			//holds the number of elements in the list
				LDR R0, [R3]				//holds the first number in the list 
				ADD R3, R3, #4
				LDR R1, [R3]				//holds the value of the second element of the list

LOOP:			SUBS R4, R4, #1				//decrement counter
				BEQ DONE
				BL COMPARE
				B LOOP

COMPARE:		CMP R0, R1
				MOVLT R0, R1
				ADD R3, R3, #4
				LDR R1, [R3]
				BX LR

DONE:			STR R0, [R5]

END: 			B END


RESULT:				.word 0					//memory assigned for result location
N:					.word 7					//# of entries in list
NUMBERS:			.word 4, 5, 3, 6		//list data
					.word 1, 8, 9
