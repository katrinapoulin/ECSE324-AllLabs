		.text
		.equ PUSH_BUTTON_DATA, 0xFF200050
		.equ PUSH_BUTTON_MASK, 0xFF200058
		.equ PUSH_BUTTON_EDGE, 0xFF20005C
		.global read_PB_data_ASM
		.global read_data_is_pressed_ASM
		.global read_PB_edgecap_ASM
		.global PB_edgecap_is_pressed_ASM
		.global PB_clear_edgecap_ASM
		.global enable_PB_INT_ASM
		.global disable_PB_INT_ASM

read_PB_data_ASM:
		LDR R1, =PUSH_BUTTON_DATA
		LDR R0, [R1]
		BX LR

PB_data_is_pressed_ASM:
		LDR R1, =PUSH_BUTTON_DATA
		LDR R2, [R1]
		AND R2, R2, R0
		CMP R2, R0
		MOVEQ R0, #1
		MOVNE R0, #0
		BX LR
	
read_PB_edgecap_ASM:
		LDR R1, =PUSH_BUTTON_EDGE
		LDR R0, [R1]
		AND R0, R0, #0xF
		BX LR

PB_clear_edgecap_ASM:
		LDR R1, =PUSH_BUTTON_EDGE
		MOV R2, R0
		STR R2, [R1]
		BX LR

enable_PB_INT_ASM:
		LDR R1, =PUSH_BUTTON_MASK
		AND R2, R0, #0xF
		STR R2, [R1]
		BX LR

disable_PB_INT_ASM:
		LDR R1, =PUSH_BUTTON_MASK
		LDR R2, [R1]
		BIC R2, R2, R0
		STR R2, [R1]
		BX LR

.end