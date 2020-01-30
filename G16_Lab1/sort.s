			.text
			.global _start

_start:			
			LDR R4, =N			//R4 points to # of elements in the list
			LDR R5, [R4]		//R5 holds the number of elements in the list

			MOV R1, #0			// R1 = boolean for sorted

BUBBLE:		CMP R1, #1
			BEQ TRUE			//stop the loop if sorted == true
			MOV R1, #1
			MOV R3, R5			// number of elements in the list
			LDR R2, [R4, #4]	//R2 points to the first element
			LDR R7, [R2, #4]			
			LDR R0, [R2]		//R0 holds the first number in the list
			B SWITCH
			
SWITCH:		SUBS R3, R3, #1		//decrement # of elements in the list
			BEQ BUBBLE			 
			LDR R6, [R7]		//load next number in the list
			CMP	R0, R6			//compare the current number with the next number
			STRGT R7, [R0]		//if greater than, we switch the two numbers
			STRGT R2, [R6]
			MOVGT R1, #0		//update boolean to false
			MOV R2, R7			//move pointer to the next number in the list 
			ADD R7, R7, #4
			LDR R0, [R2]		//update the value of R0
			B SWITCH		

TRUE:		B TRUE				//infinite loop

N: 			.word 5
ARRAY: 		.word 5, 7, 3, 8, 2
