 
.global _start
_start:

//MAIN
main:
	LDR R0, =0xFF200050
	LDR R12, =0x140
	LDR R1, [R0]
	CMP R1, #0
	BEQ main
	CMP R1, #1
	BLEQ test_byte
	CMP R1, #2
	BLEQ test_char
	CMP R1, #4
	BLEQ test_pixel
	CMP R1, #8
	BLEQ clear_buffs
	B main

clear_buffs:
	PUSH {R0-R12, LR}
	BL VGA_clear_charbuff_ASM
	BL VGA_clear_pixelbuff_ASM
	B done

test_byte:
	PUSH {R0-R12, LR}
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	B loop_test_byte
loop_test_byte:
	CMP R1, #60
	BGE done
	CMP R0, #80
	ADDGE R1, R1, #1
	MOVGE R0, #0
	BGE loop_test_byte
	BL VGA_write_byte_ASM
	ADD R2, R2, #1
	ADD R0, R0, #3
	B loop_test_byte

/*WRITE CHAR BYTE
	//R0:x position			R7:
	//R1:y position 		R8:
	//R2:char				R9:
	//R3:char 1				R10:
	//R4:char 2				R11:
	//R5:shifted y			R12: 
	//R6:address to print from
	*/
VGA_write_byte_ASM:
	PUSH {R0-R12, LR}
	//check x and y
	CMP R1, #59
	BGE done
	CMP R0, #79
	BGE done
	CMP R1, #0
	BLE done
	CMP R0, #0
	BLE done

	LDR R7, =ascii_chars
	
	//first char
	MOV R3, R2
	LSR R2, R3, #4
	LDRB R2, [R7, R2]
	BL VGA_write_char_ASM

	//second char
	ADD R0, R0, #1 //increment x
	AND R2, R3, #15
	LDRB R2, [R7, R2]
	BL VGA_write_char_ASM
	B done

test_char:
	PUSH {R0-R12, LR}
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	B loop_test_char
loop_test_char:
	CMP R1, #60
	BEQ done
	CMP R0, #80
	ADDEQ R1, R1, #1
	MOVEQ R0, #0
	BEQ loop_test_char
	BL VGA_write_char_ASM
	ADD R2, R2, #1
	ADD R0, R0, #1
	B loop_test_char

test_pixel:
	PUSH {R0-R12, LR}
	MOV R0, #0	//x=0
	MOV R1, #0	//y=0
	MOV R2, #0	//c=0
	MOV R12, #320
	B loop_test_pixel
loop_test_pixel:
	CMP R1, #239
	BGT done
	CMP R0, R12
	ADDGT R1, R1, #1
	MOVGT R0, #0
	BGT loop_test_pixel
	BL VGA_draw_point_ASM
	ADD R0, R0, #1
	ADD R2, R2, #1
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
	PUSH {R0-R12, LR}
	CMP R1, #0xEF
	BGT done
	CMP R0, R12
	BGT done
	CMP R1, #0
	BLT done
	CMP R0, #0
	BLT done
	
	LSL R3, R1, #10
	LSL R4, R0, #1
	ADD R3, R3, R4
	ADD R3, R3, #0xC8000000
	STRH R2, [R3]
	B done


/*CLEAR PIXEL BUFFER
	//R0:					R7:shifted x
	//R1:					R8: current address to clear
	//R2:					R9: 0(black)
	//R3:					R10: y=240 flag
	//R4:current y			R11: x=320 flag
	//R5:current x			R12: x & y flag
	//R6:shifted y / value to add
	*/
VGA_clear_pixelbuff_ASM:
	PUSH {R0-R12, LR}
	MOV R4, #0
	MOV R5, #0
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	B loop_cp
loop_cp:
	BL compare_yp
	BL compare_xp
	AND R12, R10, R11
	CMP R12, #1
	BEQ done
	CMP R4, #240
	MOVEQ R4, #0
	ADDEQ R5, R5, #1
	BEQ loop_cp
	BL clear_p
	ADD R4, R4, #1
	B loop_cp
clear_p:
	PUSH {R0-R12, LR}
	LSL R6, R4, #10
	LSL R7, R5, #1
	ADD R6, R6, R7
	ADD R8, R6, #0xC8000000
	STRH R9, [R8]
	B done
compare_xp:
	PUSH {LR}
	CMP R5, #320
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
	PUSH {R0-R12, LR}
	MOV R4, #0
	MOV R5, #0
	MOV R9, #0
	B loop_cc
loop_cc:
	BL compare_yc
	BL compare_xc
	AND R12, R10, R11
	CMP R12, #1
	BEQ done
	CMP R4, #60
	MOVEQ R4, #0
	ADDEQ R5, R5, #1
	BEQ loop_cc
	BL clear_c
	ADD R4, R4, #1
	B loop_cc
clear_c:
	PUSH {R0-R12, LR}
	LSL R6, R4, #7
	LSL R7, R5, #0
	ADD R6, R6, R7
	ADD R8, R6, #0xC9000000
	STRB R9, [R8]
	B done	

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
	PUSH {R0-R12, LR}
	CMP R1, #60
	BGE done
	CMP R0, #80
	BGE done
	CMP R1, #0
	BLT done
	CMP R0, #0
	BLT done
	
	LSL R3, R1, #7
	ADD R3, R3, R0
	ADD R4, R3, #0xC9000000
	STRB R2, [R4]
	B done

done:
	POP {R0-R12, LR}
	BX LR

ascii_chars:
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46
		
	
	.end