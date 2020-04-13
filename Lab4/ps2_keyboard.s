//ps2 data 0xFF200100
//RVALID bit 15

.equ PS_2, 0xFF200100
.global _start

_start:

init:
	BL VGA_clear_charbuff_ASM
	BL VGA_clear_pixelbuff_ASM
	MOV R3, #0
	MOV R4, #0
	B main

//R3 = X
//R4 = Y
main:
	LDR R0, =char
	BL read_PS2_data_ASM
	CMP R0, #1
	BNE main
	CMP R3, #80
	ADDGE R4, R4, #1
	MOVGE R3, #0
	CMP R4, #60
	BEQ init
	MOV R0, R3
	MOV R1, R4	
	LDRB R2, char
	BL VGA_write_byte_ASM
	ADD R3, R3, #3
	B main

read_PS2_data_ASM:
	PUSH {R3-R12, LR}
	LDR R2, =PS_2
	LDR R3, [R2]
	AND R4, R3, #0x8000
	CMP R4, #0
	MOVEQ R0, #0		
	BEQ done

	//data is valid
	AND R4, R3, #0xFF
	MOV R2, R0
	STRB R4, [R2]
	MOV R0, #1
	B done


VGA_write_byte_ASM:
	PUSH {R3-R12, LR}
	LDR R3, =ascii_chars	
	MOV R4, R2				
	LSR R2, R4, #4			
	LDRB R2, [R3, R2]		
	BL	VGA_write_char_ASM	
	ADD R0, R0, #1			
	AND R2, R4, #15			
	LDRB R2, [R3, R2]		
	BL VGA_write_char_ASM	
	MOV R2, R4
	B done

VGA_write_char_ASM:
	PUSH {R3-R12, LR}
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
	POP {R3-R12, LR}
	BX LR

ascii_chars:
	.ascii "0123456789ABCDEF"
char:
	.space 4

VGA_clear_charbuff_ASM:
	PUSH {R3-R12, LR}
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
	PUSH {R3-R12, LR}
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

VGA_clear_pixelbuff_ASM:
	PUSH {R3-R12, LR}
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
	PUSH {R3-R12, LR}
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

	.end