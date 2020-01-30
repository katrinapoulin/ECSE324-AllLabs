			.text
			.global _start

//_start:
			LDR R1, =XMAX		//R1 points to XMAX
			LDR R2, =XMIN		//R2 points to XMIN
			LDR R0, =STDDEV		//
			LDR R6, [R0, #4]	//R6 holds # of elements in list
			ADD R3, R0, #8		//R3 = R1 + 8 
			LDR R7, [R3]		//R7 holds the first number in the list

			ADD R4, R6, #0		//move value of R6 to R4

LOOP1:		SUBS R4, R4, #1		//decrement loop counter
			BEQ ICI				//end loop if counter reaches 0
			ADD R3, R3, #4		//R3 points to the next number in the list
			LDR R5, [R3]		//R5 holds next number in the list
			CMP R7, R5			//check if greater than current max
			BGE LOOP1			//if R7 >= R5, branch back to loop
			MOV R7, R5			//if R5 >= R7, update R7
			B LOOP1				//branch back to loop

ICI:		STR R7, [R1]		//store result to memory location of result
			ADD R4, R6, #0
			ADD R3, R2, #8		//R3 = R2 + 8 (first number)
			LDR R8, [R3]

LOOP2:		SUBS R4, R4, #1		//decrement loop counter
			BEQ DONE			//end loop if counter reaches 0
			ADD R3, R3, #4
			LDR R5, [R3]
			CMP R8, R5
			BLE LOOP2
			MOV R8, R5
			B LOOP2

DONE:		STR R8, [R3]

			SUB R9, R7, R8		//update std dev to be xmax-xmin, now we have to divide by 4
			LSR R9, R9, #2		//LOGICAL RIGHT SHIFT BY 2 TO DIVIDE BY 4

			STR R9, [R0]

END:		B END

XMAX:		.word 0
XMIN:		.word 0
STDDEV:		.word 0
N:			.word 8
NUMBERS:	.word 4, 5, 3, 6, 10, 2, 7, 1

			
					
