
.equ PS_2, 0xFF200100
.global _start

_start:
read PS2 data ASM:
	PUSH {R1-R12, LR}
	LDR R2, =PS_2
	LDR R3, [R2]
	AND R4, R3, #0x8000
	CMP R4, #0
	MOVEQ R0, #0		
	BEQ done_kb

	//data is valid
	AND R4, R3, 0xFF
	STRB R4, [R0]
	MOV R0, #1
	BX LR
	B done_kb

done_kb:
	POP {R1-R12, LR}

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

done:
	POP {R0-R12, LR}
	BX LR

ascii_chars:
	.ascii "0123456789ABCDEF"
		
	.end