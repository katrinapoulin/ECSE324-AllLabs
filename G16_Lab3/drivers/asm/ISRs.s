	.text
	
	.global A9_PRIV_TIM_ISR
	.global HPS_GPIO1_ISR
	.global HPS_TIM0_ISR
	.global HPS_TIM1_ISR
	.global HPS_TIM2_ISR
	.global HPS_TIM3_ISR
	.global FPGA_INTERVAL_TIM_ISR
	.global FPGA_PB_KEYS_ISR
	.global FPGA_Audio_ISR
	.global FPGA_PS2_ISR
	.global FPGA_JTAG_ISR
	.global FPGA_IrDA_ISR
	.global FPGA_JP1_ISR
	.global FPGA_JP2_ISR
	.global FPGA_PS2_DUAL_ISR
	
	.global hps_tim0_flag
	.global PB_flag

hps_tim0_flag:
	.word 0x0
PB_flag:
	.word 0x0
A9_PRIV_TIM_ISR:
	BX LR
	
HPS_GPIO1_ISR:
	BX LR
	
HPS_TIM0_ISR:
	PUSH {LR}
	
	MOV	R0, #1
	BL HPS_TIM_clear_INT_ASM
	
	LDR R0, =hps_tim0_flag
	MOV R1, #1
	STR R1, [R0]
	
	POP {LR}
	BX LR
	
HPS_TIM1_ISR:
	BX LR
	
HPS_TIM2_ISR:
	BX LR
	
HPS_TIM3_ISR:
	BX LR
	
FPGA_INTERVAL_TIM_ISR:
	BX LR
	
FPGA_PB_KEYS_ISR:
	PUSH {LR}

	LDR R0, =0XFF200050	
	LDR R1, [R0, #0xC]		

	LDR R0, =PB_flag	

PB0_pressed:
	MOV R3, #0x1
	AND R3, R3, R1
	CMP R3, #0
	BEQ PB1_pressed
	MOV R2, #0
	STR R2, [R0]
	B END_KEY_ISR

PB1_pressed:
	MOV R3, #0x2
	AND R3, R3, R1
	CMP R3, #0
	BEQ PB2_pressed
	MOV R2, #1
	STR R2, [R0]
	B END_KEY_ISR

PB2_pressed:
	MOV R3,#0x4
	AND R3, R1
	MOV R2, #2
	STR R2, [R0]

END_KEY_ISR:

	POP {LR}
	BX LR

FPGA_Audio_ISR:
	BX LR
	
FPGA_PS2_ISR:
	BX LR
	
FPGA_JTAG_ISR:
	BX LR
	
FPGA_IrDA_ISR:
	BX LR
	
FPGA_JP1_ISR:
	BX LR
	
FPGA_JP2_ISR:
	BX LR
	
FPGA_PS2_DUAL_ISR:
	BX LR
	
	.end