#include <stdio.h>

#include "../inc/slider_switches.h"
#include "../inc/LEDs.h"
#include "../inc/HEX_displays.h"
#include "../inc/pushbuttons.h"


int main() {

	while (1) {
		write_LEDs_ASM(read_slider_switches_ASM());
		

		if(read_slider_switches_ASM() & 0x200) {
			HEX_clear_ASM(HEX0);
			HEX_clear_ASM(HEX1);
			HEX_clear_ASM(HEX3);
			HEX_clear_ASM(HEX4);
			HEX_clear_ASM(HEX5);
		} else {
			HEX_flood_ASM(HEX4);
			HEX_flood_ASM(HEX5);
			char hex_val = (0xF & read_slider_switches_ASM());
			int pb = (0xF & read_PB_data_ASM());
			hex_val = hex_val + 48;
			HEX_write_ASM(pb,hex_val);
		}
	}

	return 0;
}
