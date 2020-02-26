		.text
		.equ HEX_3_0_BASE, 0xFF200020
		.equ HEX_5_4_BASE, 0xFF200030
		.global HEX_clear_ASM
		.global HEX_flood_ASM
		.global HEX_write_ASM

HEX_clear_ASM:
		PUSH {R1-R6, LR}
		LDR R1, =HEX_3_0_BASE
		LDR R2, =HEX_5_4_BASE
		MOV R3, #0
		
clear_loop:	
		CMP R3, #6
		BEQ clear_this

		AND R4, R0, #1
		CMP R4, #1
		BEQ clear_this
		
		ASR R0, R0, #1
		ADD R3, R3, #1
		B clear_loop

clear_this: 
		CMP R3, #3
		SUBGT R3, R3, #4
		MOVGT R1, R2
		LDR R6, [R1]
		MOV R5, #0xFFFFFF00
		B clear_loop2

clear_loop2:
		CMP R3, #0
		BEQ clear_done
		LSL R5, R5, #8
		ADD R5, R5, #0xFF
		SUB R3, R3, #1
		B clear_loop2

clear_done:
		AND R6, R6, R5
		STR R6, [R1]
		POP {R1-R6, LR}
		BX LR


HEX_flood_ASM:
		PUSH {R1-R6, LR}
		LDR R1, =HEX_3_0_BASE
		LDR R2, =HEX_5_4_BASE
		MOV R3, #0

flood_loop:
		CMP R3, #6
		BEQ flood_this
		
		AND R4, R0, #1 
		CMP R4, #1
		BEQ flood_this
		ASR R0, R0, #1
		ADD R3, R3, #1
		B flood_loop
	
flood_this:
		CMP R3, #3
		SUBGT R3, R3, #4
		MOVGT R1, R2
		LDR R6, [R1]
		MOV R5, #0x000000FF
		B flood_loop2

flood_loop2:
		CMP R3, #0
		BEQ flood_done
		LSL R5, R5, #8
		SUB R3, R3, #1
		B flood_loop2

flood_done:
		ORR R6, R6, R5
		STR R6, [R1]
		POP {R1, R2, R3, R4, R5, R6, LR}
		BX LR

HEX_write_ASM:
		MOV R10, R0 		//save R0 value 
		MOV R9, R1 			//save R1 value
		PUSH {R1, R2, R3, R4, R5, R6, LR}
		BL HEX_clear_ASM
		POP {R1, R2, R3, R4, R5, R6, LR}
		MOV R0, R10	 		//restore R0 value
		
		PUSH {R1, R2, R3, R4, R5, R6, LR}
		LDR R1, =HEX_3_0_BASE
		LDR R2, =HEX_5_4_BASE
		MOV R3, #0
		B write_0

write_0: 
		CMP R9, #48
		BNE write_1
		MOV R5, #0x3F
		MOV R8, R5
		B write_loop

write_1:
		CMP R9, #49
		BNE write_2
		MOV R5, #0x06
		MOV R8, R5
		B write_loop
		

write_2:
		CMP R9, #50
		BNE write_3
		MOV R5, #0x5B
		MOV R8, R5
		B write_loop
		
write_3:
		CMP R9, #51
		BNE write_4
		MOV R5, #0x6D
		MOV R8, R5
		B write_loop
	
write_4:
		CMP R9, #52
		BNE write_5
		MOV R5, #0x66
		MOV R8, R5
		b write_loop

write_5:
		CMP R9, #53
		BNE write_6
		MOV R5, #0x6D
		MOV R8, R5
		b write_loop

write_6:
		CMP R9, #54
		BNE write_7
		MOV R5, #0x7D
		MOV R8, R5
		B write_loop

write_7:
		CMP R9, #55
		BNE write_8
		MOV R5, #0x07
		MOV R8, R5
		B write_loop
		
write_8:
		CMP R9, #56
		BNE write_9
		MOV R5, #0x7F
		MOV R8, R5
		B write_loop
	
write_9:
		CMP R9, #57
		BNE write_A
		MOV R5, #0x6F
		MOV R8, R5
		B write_loop
	
write_A:
		CMP R9, #58
		BNE write_B
		MOV R5, #0x77
		MOV R8, R5
		B write_loop

write_B:
		CMP R9, #59
		BNE write_C
		MOV R5, #0x7C
		MOV R8, R5
		B write_loop

write_C:
		CMP R9, #60
		BNE write_D
		MOV R5, #0x39
		MOV R8, R5
		B write_loop
	
write_D:
		CMP R9, #61
		BNE write_E
		MOV R5, #0x5E
		MOV R8, R5
		B write_loop
		
write_E:
		CMP R9, #62
		BNE write_F
		MOV R5, #0x79
		MOV R8, R5
		B write_loop

write_F:
		CMP R9, #63
		BNE write_no
		MOV R5, #0x71
		MOV R8, R5
		B write_loop

write_no: 
		MOV R5, #0
		MOV R8, R5
		B write_loop

write_loop:
		CMP R3, #6
		BEQ write_this
		
		AND R4, R0, #1
		CMP R4, #1
		BEQ write_this
		
		ASR R0, R0, #1
		ADD R3, R3, #1
		B write_loop

write_this:
		CMP R3, #3
		SUBGT R3, R3, #4
		MOVGT R1, R2
		LDR R6, [R1]
		MOV R5, R8
		B write_loop2

write_loop2:
		CMP R3, #0
		BEQ write_done
		LSL R5, R5, #8
		SUB R3, R3, #1
		B write_loop2

write_done:
		ORR R6, R6, R5
		STR R6, [R1]
		POP {R1-R8, LR}
		BX LR
	

.end
