			.text
			.global _start

//_start:			
			LDR R4, =AVG		//R4 points to AVG
			LDR R2, [R4, #4]	//R2 holds # of elements in list
			ADD R3, R4, #8		//R3 = R4 + 8 (current number pointer)
			LDR R0, [R3]		//R0 holds the first number in the list

			MOV R7, R2			//R7 holds number of elements

LOOP:		SUBS R7, R7, #1		//decrement R2
			BEQ DONE
			ADD R3, R3, #4		//R3 points to the next number in the list
			LDR R1, [R3]
			ADD R0, R0, R1
			B LOOP
DONE:	
			MOV R8, R0			//R8 is a counter for the division
			MOV R6, R2

		//we will logical shift right the number of elements until we get to 0.
		//every time we shift right, we arithmetic shift right the average.
		//this will divide the average by the number of elements.
DIVIDE:		LSR R6, R6, #1		
			CMP R6, #0
			BEQ THEN
			ASR R8, R8, #1
			B DIVIDE
		
			
			// At this point, we have a list of elements with its average stored in R8
			// Now we have to center the list, so we will subtract the average from every element in the list.

THEN:		STR R8, [R4]		//store average in its memory location
			ADD R6, R2, #1		//R5 holds the number of elements in the list +1 to get the last element
			ADD R3, R4, #8		//we replace the pointer for our loop
		
			// when R5 is 8 (number of elements) it doesnt get to 18 (last element)
			// ordering p

CENTER:		SUBS R6, R6, #1		//decrement loop
			BEQ END
			LDR R1, [R3]		//point to the next number
			SUB R1, R1, R8		//subtract the average
			STR R1, [R3]		//store new value in memory location of old value
			ADD R3, R3, #4		//point to the next number in the list
			B CENTER
			

END:		B END				//infinite loop			

AVG:		.word 0
N:			.word 8
NUMBERS:	.word 2, 4, 6, 8 
			.word 12, 14, 16, 18
