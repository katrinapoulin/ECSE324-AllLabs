	.text
	.equ   HPS_TIM0_BASE, 0xFFC08000 //Timer1-Clock frequency 100MHz
	.equ   HPS_TIM1_BASE, 0xFFC09000 //Timer2-Clock frequency 100MHz
	.equ   HPS_TIM2_BASE, 0xFFD00000 //Timer3-Clock frequency 25MHz
	.equ   HPS_TIM3_BASE, 0xFFD01000 //Timer4-Clock frequency 25MHz
	
	.global HPS_TIM_config_ASM
	.global HPS_TIM_clear_INT_ASM
	.global HPS_TIM_read_INT_ASM

HPS_TIM_read_INT_ASM:
	PUSH {LR}
	PUSH {R4}
	MOV R1, #0
	MOV R2, #1
	MOV R4, #0
	B READ_INT_loop

READ_INT_loop:
	TST R0, R2, LSL R1
	BEQ READ_INT_continue
	BL READ_INT

READ_INT_continue:
	ADD R1, R1, #1
	CMP R1, #4
	BEQ READ_INT_done
	LSL R4, R4, #1
	B READ_INT_loop
	
READ_INT_done:
	MOV R0, R4
	POP {R4}
	POP {LR}
	BX LR

READ_INT:
	LDR R3, =HPS_TIM_BASE
	LDR R3, [R3, R1, LSL #2]
	LDR R3, [R3, #0x10]
	AND R3, R3, #0x1
	EOR R4, R4, R3
	BX LR
	
HPS_TIM_clear_INT_ASM:
	PUSH {LR}
	MOV R1, #0
	MOV R2, #1
	B CLEAR_INT_loop

CLEAR_INT_loop:
	TST R0, R2, LSL R1
	BEQ CLEAR_INT_continue
	BL CLEAR_INT

CLEAR_INT_continue:
	ADD R1, R1, #1
	CMP R1, #4
	BLT CLEAR_INT_loop
	B CLEAR_INT_done

CLEAR_INT_done:
	POP {LR}
	BX LR

CLEAR_INT:
	LDR R3, =HPS_TIM_BASE
	LDR R3, [R3, R1, LSL #2]
	LDR R3, [R3, #0xC]
	BX LR


HPS_TIM_config_ASM:
	PUSH {R1-R7, LR}
	MOV R1, #0
	MOV R2, #1
	LDR R7, [R0]
	B CONFIG_loop

CONFIG_loop:
	TST R7, R2, LSL R1
	BEQ CONFIG_cont
	BL CONFIG_config

CONFIG_cont:
	ADD R1, R1, #1
	CMP R1, #4
	BLT CONFIG_loop

CONFIG_done:
	POP {R1-R7, LR}
	BX LR


CONFIG_config:
	PUSH {LR}
	
	LDR R3, =HPS_TIM_BASE
	LDR R4, [R3, R1, LSL #2]
	
	BL CONFIG_dis
	BL SET_LOAD_value
	BL SET_LOAD_bit
	BL SET_INT_bit
	BL SET_EN_bit
	
	POP {LR}
	BX LR 

CONFIG_dis:
	LDR R5, [R4, #0x8]
	AND R5, R5, #0xFFFFFFFE
	STR R5, [R4, #0x8]
	BX LR
	
SET_LOAD_value:
	LDR R5, [R0, #0x4]
	MOV R6, #25
	MUL R5, R5, R6
	CMP R1, #2
	LSLLT R5, R5, #2
	STR R5, [R4]
	BX LR
	
SET_LOAD_bit:
	LDR R5, [R4, #0x8]
	LDR R6, [R0, #0x8]
	AND R5, R5, #0xFFFFFFFD
	ORR R5, R5, R6, LSL #1
	STR R5, [R4, #0x8]
	BX LR
	
SET_INT_bit:
	LDR R5, [R4, #0x8]
	LDR R6, [R0, #0xC]
	EOR R6, R6, #0x00000001
	AND R5, R5, #0xFFFFFFFB
	ORR R5, R5, R6, LSL #2
	STR R5, [R4, #0x8]
	BX LR
	
SET_EN_bit:
	LDR R5, [R4, #0x8]
	LDR R6, [R0, #0x10]
	AND R5, R5, #0xFFFFFFFE
	ORR R5, R5, R6
	STR R5, [R4, #0x8]
	BX LR



	
HPS_TIM_BASE:
	.word 0xFFC08000, 0xFFC09000, 0xFFD00000, 0xFFD01000

	.end
