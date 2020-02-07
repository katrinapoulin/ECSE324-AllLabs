			.text
			.global _start

//_start:
			LDR R4, =RESULT		//R4 points to RESULT
			LDR R2, [R4, #4]	//R2 holds # of elements in list
			ADD R3, R4, #8		//R3 = R4 + 8
			LDR R0, [R3]		//R0 holds the first number in the list

LOOP:			SUBS R2, R2, #1		//decrement loop counter
			BEQ DONE		//end loop if counter reaches 0
			ADD R3, R3, #4		//R3 points to the next number in the list
			LDR R1, [R3]		//R1 holds next number in the list
			CMP R0, R1		//check if greater than current max
			BGE LOOP		//if R0 >= R1, branch back to loop
			MOV R0, R1		//if R1 >= R0, update R0
			B LOOP			//branch back to loop

DONE:			STR R0, [R4]		//store result to memory location of result

END:			B END			//infinite loop

RESULT:			.word 0			//memory assigned for result location
N:			.word 7			//# of entries in list
NUMBERS:		.word 4, 5, 3, 6	/list data
			.word 1, 8, 2/
