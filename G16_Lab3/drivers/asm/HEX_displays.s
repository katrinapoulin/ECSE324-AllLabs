.text
	.equ HEX_3_to_0, 0xFF200020
	.equ HEX_5_to_4, 0xFF200030
	.global HEX_clear_ASM
	.global HEX_write_ASM
	.global HEX_flood_ASM

HEX_flood_ASM:
		LDR R1, =HEX_3_to_0
		LDR R2, =HEX_5_to_4	
		MOV R3, #0

HEX_0_f:
		TST	R0, #0x00000001
		BNE flood_hex_0
		BEQ HEX_1_f
flood_hex_0:
		ADD R3, R3, #127 //0x0000007F
		STR R3, [R1]

HEX_1_f:
		TST	R0, #0x00000002
		BNE flood_hex_1
		BEQ HEX_2_f
flood_hex_1:
		ADD R3, R3, #32512 //0x00007F00
		STR R3, [R1]

HEX_2_f:
		TST	R0, #0x00000004
		BNE flood_hex_2
		BEQ HEX_3_f
flood_hex_2:
		ADD R3, R3, #8323072 //0x007F0000
		STR R3, [R1]

HEX_3_f:
		TST	R0, #0x00000008
		BNE flood_hex_3
		BEQ HEX_4_f
flood_hex_3:
		ADD R3, R3, #2130706432 //0x7F000000
		STR R3, [R1]

HEX_4_f:
		TST	R0, #0x00000010
		BNE flood_hex_4
		BEQ HEX_5_f
flood_hex_4:
		MOV R3, #0
		ADD R3, R3, #127 //0x0000007F
		STR R3, [R2]

HEX_5_f:
		TST	R0, #0x00000020
		BNE flood_hex_5
		BEQ EXIT1
flood_hex_5:
		ADD R3, R3, #32512 //0x00007F00
		STR R3, [R2]

EXIT1:
		BX LR

//============================================================
HEX_write_ASM:
		LDR R2, =HEX_3_to_0
		LDR R3, =HEX_5_to_4

		CMP R1, #0
		MOVEQ R4, #0x0000003f 
		CMP R1, #1
		MOVEQ R4, #0x00000006
		CMP R1, #2
		MOVEQ R4, #0x0000005B
		CMP R1, #3
		MOVEQ R4, #0x0000004F
		CMP R1, #4
		MOVEQ R4, #0x00000066
		CMP R1, #5
		MOVEQ R4, #0x0000006D
		CMP R1, #6
		MOVEQ R4, #0x0000007D
		CMP R1, #7
		MOVEQ R4, #0x00000007
		CMP R1, #8
		MOVEQ R4, #0x0000007F
		CMP R1, #9
		MOVEQ R4, #0x00000067
		CMP R1, #10
		MOVEQ R4, #0x00000077
		CMP R1, #11
		MOVEQ R4, #0x0000007C
		CMP R1, #12
		MOVEQ R4, #0x00000039
		CMP R1, #13
		MOVEQ R4, #0x0000005E
		CMP R1, #14
		MOVEQ R4, #0x00000079
		CMP R1, #15
		MOVEQ R4, #0x00000071
	
HEX_0_w:
		TST	R0, #0x00000001
		BNE write_hex_1
		BEQ HEX_1_w
write_hex_0:
		LDR R5, [R2]
		AND R5, R5, #0xffffff00
		ADD R4, R5, R4
		STR R4, [R2]
		B EXIT2

HEX_1_w:
		TST	R0, #0x00000002
		BNE write_hex_1
		BEQ HEX_2_w
write_hex_1:
		LDR R5, [R2]
		AND R5, R5, #0xffff00ff
		LSL R4, R4, #8
		ADD R4, R5, R4
		STR R4, [R2]
		B EXIT2

HEX_2_w:
		TST	R0, #0x00000004
		BNE write_hex_2
		BEQ HEX_3_w
write_hex_2:
		LDR R5, [R2]
		AND R5, R5, #0xff00ffff
		LSL R4, R4, #16
		ADD R4, R5, R4
		STR R4, [R2]
		B EXIT2

HEX_3_w:
		TST	R0, #0x00000008
		BNE write_hex_3
		BEQ HEX_4_w
write_hex_3:
		LDR R5, [R2]
		AND R5, R5, #0x00ffffff
		LSL R4, R4, #24
		ADD R4, R5, R4
		STR R4, [R2]
		B EXIT2

HEX_4_w:
		TST	R0, #0x00000010
		BNE write_hex_4
		BEQ HEX_5_w
write_hex_4:
		LDR R5, [R3]
		AND R5, R5, #0xffffff00
		ADD R4, R5, R4
		STR R4, [R3]
		B EXIT2

HEX_5_w:
		TST	R0, #0x00000020
		BNE write_hex_5
		BEQ EXIT2
write_hex_5:
		LDR R5, [R3]
		AND R5, R5, #0xffff00ff
		LSL R4, R4, #8
		ADD R4, R5, R4
		STR R4, [R3]
		B EXIT2

EXIT2:	BX LR

//============================================================
HEX_clear_ASM:
		LDR R1, =HEX_3_to_0
		LDR R2, =HEX_5_to_4	
HEX_0_c:
		TST	R0, #0x00000001
		BNE clear_hex_0
		BEQ HEX_1_c
clear_hex_0:
		LDR R7, [R1]
		AND R9, R7, #0xffffff00
		STR R9, [R1]

HEX_1_c:
		TST	R0, #0x00000002
		BNE clear_hex_1
		BEQ HEX_2_c
clear_hex_1:
		LDR R7, [R1]
		AND R9, R7, #0xffff00ff
		STR R9, [R1]

HEX_2_c:
		TST	R0, #0x00000004
		BNE clear_hex_2
		BEQ HEX_3_c
clear_hex_2:
		LDR R7, [R1]
		AND R9, R7, #0xff00ffff
		STR R9, [R1]

HEX_3_c:
		TST	R0, #0x00000008
		BNE clear_hex_3
		BEQ HEX_4_c
clear_hex_3:
		LDR R7, [R1]
		AND R9, R7, #0x00ffffff
		STR R9, [R1]

HEX_4_c:
		TST	R0, #0x00000010
		BNE clear_hex_4
		BEQ HEX_5_c
clear_hex_4:
		LDR R7, [R2]
		AND R9, R7, #0xffffff00
		STR R9, [R2]

HEX_5_c:
		TST	R0, #0x00000020
		BNE clear_hex_5
		BEQ EXIT3
clear_hex_5:
		LDR R7, [R2]
		AND R9, R7, #0xffff00ff
		STR R9, [R2]

EXIT3:
		BX LR		

	.end
