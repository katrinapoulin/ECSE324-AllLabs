.equ PS_2, 0xFF200100	//address of the ps2 register
.global _start

_start:

//initialization of the function: clearing the buffers
init:
	BL VGA_clear_charbuff_ASM
	BL VGA_clear_pixelbuff_ASM
	MOV R3, #0		//set x=0
	MOV R4, #0		//set y=0
	B main

//R3 = X
//R4 = Y
main:
	LDR R0, =char					//R0 holds the adress at which we want to copy the keyboard data byte
	BL read_PS2_data_ASM			//call read_data with R0 as input
	CMP R0, #1						//check if data was valid
	BNE main						//if not valid read again
	CMP R3, #80						//if valid check if the row is filled
	ADDGE R4, R4, #1				//if yes change rows
	MOVGE R3, #0
	CMP R4, #60						//check if the screen is filled
	BEQ init						//if so restart the program
	MOV R0, R3						//move the coordinates and char inputs to the right registers
	MOV R1, R4	
	LDRB R2, char
	BL VGA_write_byte_ASM			//write the byte to the screen 
	ADD R3, R3, #3					//increment coordinates
	B main

	//reads data from keyboard and chechs if valid

read_PS2_data_ASM:
	PUSH {R3-R12, LR}
	LDR R2, =PS_2			//R2 holds the ps2 data address
	LDR R3, [R2]			//R3 holds the value at this adress (word)
	AND R4, R3, #0x8000		//we get bit 15 (RVALID)
	CMP R4, #0				//if VALID is 0, we return 0 and exit
	MOVEQ R0, #0		
	BEQ done

	//data is valid
	AND R4, R3, #0xFF		//if data is valid get the first byte
	MOV R2, R0				//store the byte in the char address
	STRB R4, [R2]
	MOV R0, #1				//return 1
	B done

//writes an input byte (R2) at the given coordinates (R0, R1)
VGA_write_byte_ASM:
	PUSH {R3-R12, LR}
	//chech if input is valid
	CMP R1, #60
	BGE done
	CMP R0, #80
	BGE done
	CMP R1, #0
	BLT done
	CMP R0, #0
	BLT done

	LDR R3, =ascii_chars		//load the ascii characters (from 0 to F) at the ascii_chars address (see bottom of the file)
	MOV R4, R2					//store the byte 
	LSR R2, R4, #4				//we get the first byte (4 most sig. bits)
	LDRB R2, [R3, R2]			//we get the character we need to write at address (ascii chars + valueof half-byte)
	BL	VGA_write_char_ASM		//write the obtained character on the screen
	ADD R0, R0, #1				//increment x
	AND R2, R4, #15				//we get the first 4 bits of the input byte
	LDRB R2, [R3, R2]			//get character to write
	BL VGA_write_char_ASM		//write character
	MOV R2, R4					//restore R2 (callee save)
	B done

//writes an input char at the given coordinates
VGA_write_char_ASM:
	PUSH {R3-R12, LR}
	//check if input is valid
	CMP R1, #60
	BGE done
	CMP R0, #80
	BGE done
	CMP R1, #0
	BLT done
	CMP R0, #0
	BLT done
	
	LSL R3, R1, #7		//shift y by 7 bytes to get correct address format
	ADD R3, R3, R0		//add the x coordinate
	ADD R4, R3, #0xC9000000		//add x+y to teh base address of the buffer
	STRB R2, [R4]		//write the char value at the address
	B done		//exit

VGA_clear_charbuff_ASM:
	PUSH {R3-R12, LR}
	MOV R3, #0		//AND set to 0 initially
	MOV R4, #0		//x and y are initialized at 0
	MOV R5, #0
	MOV R9, #0		//#0 is black (clear)
	B loop_cc
loop_cc:
	BL compare_yc			//set row/column full flags
	BL compare_xc
	AND R3, R10, R11		//check if both flags are active
	CMP R3, #1
	BEQ done				//if so clear is done: exit
	CMP R4, #60				//else if only y is done, change column
	MOVEQ R4, #0
	ADDEQ R5, R5, #1
	BEQ loop_cc				//we start the loop again if y was done
	BL clear_c				//clear the current char
	ADD R4, R4, #1			//increment y
	B loop_cc
clear_c:
	PUSH {R3-R12, LR}
	LSL R6, R4, #7			//shift y to get correct address format
	ADD R6, R6, R5			//add x to the shifted y
	ADD R8, R6, #0xC9000000		//add everything to the base address
	STRB R9, [R8]			//store 0 at address
	B done					//exit subroutine

compare_xc:
	PUSH {LR}
	CMP R5, #80
	MOVGE R10, #1
	POP {LR}
	BX LR
compare_yc:
	PUSH {LR}
	CMP R5, #60
	MOVGE R11, #1
	POP {LR}
	BX LR

VGA_clear_pixelbuff_ASM:
	PUSH {R3-R12, LR}
	MOV R4, #0
	MOV R5, #0
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R3, #0
	B loop_cp
loop_cp:
	BL compare_yp			//set row/column full flags
	BL compare_xp
	AND R3, R10, R11		//check if both flags are active
	CMP R3, #1
	BEQ done				//if so clear is done: exit
	CMP R4, #240			//else if only y is done, change column
	MOVEQ R4, #0
	ADDEQ R5, R5, #1
	BEQ loop_cp				//we start the loop again if y was done
	BL clear_p				//clear the current pixel
	ADD R4, R4, #1			//increment y
	B loop_cp
clear_p:
	PUSH {R3-R12, LR}
	LSL R6, R4, #10			//shift y to get correct address format
	LSL R7, R5, #1			//shift x
	ADD R6, R6, R7			//add x to the shifted y
	ADD R8, R6, #0xC8000000		//add everything to the base address
	STRH R9, [R8]			//store 0 at address
	B done					//exit
compare_xp:
	PUSH {LR}
	CMP R5, R12
	MOVGE R10, #1
	POP {LR}
	BX LR
compare_yp:
	PUSH {LR}
	CMP R4, #240
	MOVGE R11, #1
	POP {LR}
	BX LR

done:
	POP {R3-R12, LR}
	BX LR

ascii_chars:
	.ascii "0123456789ABCDEF"

//space saved to store keyboard data
char:
	.space 4
	.end