//R0: (ADDRESS) # of elements in the list
//R1: (VALUE) # of elements in the list
//R2: (ADDRESS) pointer to current element in list
//R3: (VALUE) element of the list pointer
//R4: (VALUE) next element in the list
//R5: (VALUE) boolean sorted, 1=true, 0=false
//R6: (VALUE) i for loop (to increment)
//R7: (VALUE) array length minus 2 (R1-2), to decrement
//R8: (VALUE) j for loop (to increment)
//R9: (ADDRESS) pointer to next element in list
//R10: (VALUE) lenght of array - 2
			
			.text
			.global _start

_start:
			LDR R0, =N			//R0 points to the number of elements in the list
			LDR R1, [R0]		//value of N is stored in R1
			MOV R5, #0			//sorted=false
			MOV R6, #0			
			SUB R10, R1, #2		//array length - 2

WHILE:		MOV R8, #0			//j=0
			ADD R2, R0, #4		//R2 points to first element in list
			ADD R9, R2, #4		//R9 points to next element in list
			SUB R7, R10, R6		//array.length - 2 - i
			CMP R5, #1			//while loop
			BEQ SORTED
			MOVNE R5, #1		//sorted = true
			BNE NOTSORTED
			B WHILE

NOTSORTED:	CMP R8, R7
			BGT DONE
			BLE COMPARE

COMPARE:	LDR R3, [R2]		//current element in list
			LDR R4, [R9]		//next element in the list
			CMP R3, R4
			STRGT R3, [R9]
			STRGT R4, [R2]
			MOVGT R5, #0
			ADD R8, R8, #1		//increment j
			MOV R2, R9			//change pointers
			ADD R9, R9, #4
			B NOTSORTED
			
DONE:		ADD R6, R6, #1		//increment i
			B WHILE

SORTED:		B SORTED

N: 			.word 7
ARRAY: 		.word 5, 7, 3, 8, 2, 10, 1
