			.text
			.equ PB_BASE, 0xFF200050
			.equ PB_EDGECAPTURE, 0xFF20005C
			.equ PB_INT_MASK, 0xFF200058
			.global read_PB_data_ASM, read_PB_edgecap_ASM, PB_edgecap_is_pressed_ASM, PB_clear_edgecp_ASM, enable_PB_INT_ASM, disable_PB_INT_ASM, PB_data_is_pressed_ASM

read_PB_data_ASM:
			LDR R1, =PB_BASE			
			LDR R0, [R1]	
			BX LR

read_PB_edgecap_ASM:
			LDR R2, =PB_EDGECAPTURE  
			LDR R0, [R2]
			BX LR

PB_edgecap_is_pressed_ASM:
			LDR R3, =PB_EDGECAPTURE
			LDR R3, [R3]

			TST R0, R3
			BEQ mov0
			MOV R0, #1
			B DONE
mov0_ec:	MOV R0, #0

DONE:		BX LR

PB_data_is_pressed_ASM:
			LDR R1, =PB_BASE		
			LDR R4, [R1]			
		
			TST R4, R0	
			BEQ mov0
			MOV R0, #1			 
			B DONE
mov0_data:	MOV R0, #0	

DONE:		BX LR

PB_clear_edgecp_ASM:
			LDR R5, =PB_EDGECAPTURE
			STR R0, [R5]
			BX LR

enable_PB_INT_ASM:
			LDR R4, =PB_INT_MASK	
			STR R0, [R4]
			BX LR

disable_PB_INT_ASM:
			LDR R1, =PB_INT_MASK
			STR R0, [R1]		
			BX LR


	.end
