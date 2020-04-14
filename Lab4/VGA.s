 
.global _start
_start:

//MAIN
main:
	LDR R0, =0xFF200050		//base address of pushbuttons
	LDR R12, =0x140			//store 320 in R12
	LDR R1, [R0]			//get data from pushbuttons
	CMP R1, #0				//if no pushbutton is pressed loop again
	BEQ main
	CMP R1, #1				//if PB0 pressed do test_byte
	BLEQ test_byte
	CMP R1, #2				//if PB1 is pressed do test_char
	BLEQ test_char
	CMP R1, #4				//if PB2 is pressed do test_pixel
	BLEQ test_pixel
	CMP R1, #8				//if PB3 is pressed do clear_buffs
	BLEQ clear_buffs
	B main

clear_buffs:
	PUSH {R3-R12, LR}
	BL VGA_clear_charbuff_ASM
	BL VGA_clear_pixelbuff_ASM
	B done

test_byte:
	PUSH {R3-R12, LR}
	//initialize x, y, byte
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	B loop_test_byte
loop_test_byte:
	CMP R1, #60				//check if y is done (buffer is full)
	BGE done
	CMP R0, #80				//check if x is done (if so increment y)
	ADDGE R1, R1, #1		//change row
	MOVGE R0, #0
	BGE loop_test_byte		//restart with fresh row
	BL VGA_write_byte_ASM	//write byte
	CMP R2, #0xFF			//check if R2 reached FF, if so we reset it to 00
	MOVEQ R2, #0
	ADDNE R2, R2, #1		//if not reached, increment
	ADD R0, R0, #2			//increment x (by 2 because inside the write byte subroutine we already increment by 1)
	B loop_test_byte

/*WRITE CHAR BYTE
	//R0:x position					R7:
	//R1:y position 				R8:
	//R2:char						R9:
	//R3:ascii table chars			R10:
	//R4:stored char				R11:
	//R5:							R12: 
	//R6:
	*/
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

test_char:
	PUSH {R3-R12, LR}
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	B loop_test_char
loop_test_char:
	CMP R1, #60					//if rows are full we exit
	BEQ done
	CMP R0, #80					//if row is full we change rows
	ADDEQ R1, R1, #1
	MOVEQ R0, #0
	BEQ loop_test_char
	BL VGA_write_char_ASM		//write the char at the current coordinates
	ADD R2, R2, #1				//increment char value
	ADD R0, R0, #1				//increment X
	B loop_test_char

test_pixel:
	PUSH {R3-R12, LR}
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	MOV R12, #0x140
	B loop_test_pixel
loop_test_pixel:
	CMP R1, #239			//check if all rows are full
	BGT done				//if so exit
	CMP R0, R12				//check if row is full, if so change rows
	ADDGT R1, R1, #1
	MOVGT R0, #0
	BGT loop_test_pixel
	BL VGA_draw_point_ASM	//draw point at current location/color
	ADD R0, R0, #1			//increment x
	ADD R2, R2, #1			//increment color
	B loop_test_pixel
	
/*DRAW PIXEL POINT
	//R0:x						R7:
	//R1:y						R8:
	//R2:color					R9:
	//R3:shifted y / address	R10:
	//R4:shifted x				R11:
	//R5:						R12: 
	//R6:
	*/
VGA_draw_point_ASM:
	PUSH {R3-R12, LR}
	//check if input is valid
	CMP R1, #0xEF
	BGT done
	CMP R0, R12
	BGT done
	CMP R1, #0
	BLT done
	CMP R0, #0
	BLT done
	
	LSL R3, R1, #10		//shift y to get correct address format
	LSL R4, R0, #1		//shift x to get correct address format
	ADD R3, R3, R4		//x+y
	ADD R3, R3, #0xC8000000	//add base offset to computed address
	STRH R2, [R3]		//store halfword at address
	B done


/*CLEAR PIXEL BUFFER
	//R0:					R7:shifted x
	//R1:					R8: current address to clear
	//R2:					R9: 0(black)
	//R3:x & y flag			R10: y=240 flag
	//R4:current y			R11: x=320 flag
	//R5:current x			R12: 
	//R6:shifted y / value to add
	*/
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

/*CLEAR CHAR BUFFER
	//R0:					R7:shifted x
	//R1:					R8:current address to clear
	//R2:					R9: 0
	//R3:					R10: y=60 flag
	//R4:current y			R11: x=80 flag
	//R5:current x			R12: x & y flag
	//R6:shifted y / value to add
	*/
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

/*WRITE CHAR BUFFER
	//R0:X						R7:
	//R1:Y						R8: 
	//R2:char to write			R9:
	//R3:shifted y				R10:
	//R4:address to write to	R11:
	//R5:						R12:
	//R6:
	*/
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

done:
	POP {R3-R12, LR}
	BX LR

ascii_chars:
	.ascii "0123456789ABCDEF"		
	
	.end