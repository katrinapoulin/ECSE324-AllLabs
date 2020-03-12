#include <stdio.h>


// Part 1
/*
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/LEDs.h"

int main() {
	HEX_flood_ASM(HEX4|HEX5);					// flood both HEX4 and HEX5, they are not used
	HEX_clear_ASM(HEX0|HEX1|HEX2|HEX3);			// clear the remaining displays

	while(1){
	
		int bit_sliders_value = read_slider_switches_ASM();		// read the binary value displayed by the slider switches
		write_LEDs_ASM(bit_sliders_value);						// display on the LED whether the corresponding slider is a 0 or a 1
		
		
		// if bit_sliders_value is more than 512, that means that the 9th bit is 1
		// hence we need to clear the displays
		
		
		if(bit_sliders_value >= 512) {
			HEX_clear_ASM(HEX0|HEX1|HEX2|HEX3);	
		} else {
			int display_value = slider & 0x0000000F;			// Set the sliders to 0 except the first 4 (values until 15, 0xF)
			HEX_t hex;											
			if (read_PB_data_ASM() == 0x00000001) {				// read push button data
				hex = HEX0;										// associate the corresponding HEX display
			} else if (read_PB_data_ASM() == 0x00000002) {
				hex = HEX1;
			} else if (read_PB_data_ASM() == 0x00000004) {
				hex = HEX2;
			} else if (read_PB_data_ASM() == 0x00000008) {
				hex = HEX3;
			}

			HEX_write_ASM(hex, display_value);				// write on the HEX display
		}
	}
	return 0;
}
*/


//Part 2

// stopwatch using polling timer
/*
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/pushbuttons.h"

int main(){
	
	
	int count_0 = 0; 
	int count_1 = 0;			// miliseconds
	int count_2 = 0; 
	int count_3 = 0;			// seconds
	int count_4 = 0; 
	int count_5 = 0;			// minutes
	
	// struct for the main timer 
	HPS_TIM_config_t timer;
	timer.tim = TIM0;
	timer.timeout = 10000;		// for centiseconds	
								
	timer.LD_en = 0;			// disable timer at the beginning
	timer.enable = 0;
	HPS_TIM_config_ASM(&timer);	// pass by reference

	// struct for the polling timer
	HPS_TIM_config_t poll;
	poll.tim = TIM1;
	poll.timeout = 5000; // faster than the timer
	// polling timer must be enabled at the beginning to detect when a button is pressed
	poll.LD_en = 1;
	poll.INT_en = 1;
	poll.enable = 1;
	HPS_TIM_config_ASM(&poll);

	while(1) {

		if (HPS_TIM_read_INT_ASM(poll.tim)) { 
			HPS_TIM_clear_INT_ASM(poll.tim)			
			int button = read_PB_edgecap_ASM();			// check for buttonpress
			if (button) {

				if(PB_edgecap_is_pressed_ASM(PB0)) {	// first button was pressed, start the timer, enable = 1
					timer.LD_en = 1;
					timer.INT_en = 1;
					timer.enable = 1;
					HPS_TIM_config_ASM(&timer);
				}
				 
				if(PB_edgecap_is_pressed_ASM(PB1)){		// second button was pressed, stop the timer, enable = 0
					timer.LD_en = 0;
					timer.INT_en = 0;
					timer.enable = 0;
					HPS_TIM_config_ASM(&timer);
				}
				
				if(PB_edgecap_is_pressed_ASM(PB2)){		// third button was pressed, stop the timer by setting enable to 0
					timer.LD_en = 0;
					timer.INT_en = 0;
					timer.enable = 0;
					HPS_TIM_config_ASM(&timer);

					if(HPS_TIM_read_INT_ASM(timer.tim) == 0) {		// reset the display by writting 0 in every HEX
						HEX_write_ASM(HEX5,0);
						HEX_write_ASM(HEX4,0);
						HEX_write_ASM(HEX3,0);
						HEX_write_ASM(HEX2,0);
						HEX_write_ASM(HEX1,0);
						HEX_write_ASM(HEX0,0);				
					}

					//Reset counters
					count_0 = 0;
 					count_1 = 0;
					count_2 = 0;
					count_3 = 0;
					count_4 = 0;
					count_5 = 0;
				}
				
				// reset edgecapture to press a button again
				PB_clear_edgecp_ASM(15);
			}
		}
		
	
		if (HPS_TIM_read_INT_ASM(timer.tim)) {

			HPS_TIM_clear_INT_ASM(timer.tim);
				if(++count_0 == 10) {					// reached 10 miliseconds
					count_0 = 0;

					if(++count_1==10){					// reached 10 centiseconds
						count_1 = 0;

						if(++count_2==10){				// reached 1 second
							count_2 = 0;

							if(++count_3==6){			// reached 10 seconds
								count_3 = 0;

								if(++count_4==10){		// reached 1 min (60 seconds)
									count_4 = 0;
									
									if(++count_5==6){	// reached 10 min

										count_5 = 0;
									}
								}
							}
						}
					}
				}
				
				//Update the display
				HEX_write_ASM(HEX5,count_5);
				HEX_write_ASM(HEX4,count_4);
				HEX_write_ASM(HEX3,count_3);
				HEX_write_ASM(HEX2,count_2);
				HEX_write_ASM(HEX1,count_1);
				HEX_write_ASM(HEX0,count_0);
			}
	}
	return 0;
}

*/


//Part 3

// counter to 15
/*
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/HPS_TIM.h"

int main(){

	int_setup(1, (int []) {199});

	int count = 0;
	HPS_TIM_config_t hps_tim;

	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim);

	while(1) {
	
		if (hps_tim0_flag) {
			hps_tim0_flag = 0;
			if (++count == 15){
				count = 0;
			}
			HEX_write_ASM(HEX0, count);
		}
	}

	return 0;

}
*/

// stop watch using interrupts
/*
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/pushbuttons.h"

int main(){
	// set up which devices will send interrupts
	int_setup(2, (int[]) {73, 199}); // pushbutton interruptID is 73

	int count_0 = 0; 
	int count_1 = 0;			// miliseconds
	int count_2 = 0; 
	int count_3 = 0;			// seconds
	int count_4 = 0; 
	int count_5 = 0;			// minutes
	
	// struct for timer 
	HPS_TIM_config_t timer;
	timer.tim = TIM0;
	timer.timeout = 10000; // for centiseconds	
	// disable interrupt 
	timer.INT_en = 0;
	HPS_TIM_config_ASM(&timer);

	// enable interrupts of every push button
	enable_PB_INT_ASM(PB0|PB2|PB1);

	//PB_flag -> flag that sets the ISRs for the pushbuttons
	PB_flag = 123456789;

	while(1){
		if(PB_flag >= 0) {
			// the first button was pressed: start timer, enable = 1
			if(PB_flag == 0){
				timer.LD_en = 1;
				timer.INT_en = 1;
				timer.enable = 1;
				HPS_TIM_config_ASM(&timer);
				PB_flag = 123456789;
			}

			// second button was pressed, we pause the timer
			//but we do not reset the display. So enable is set to 0
			if(PB_flag == 1){
				timer.LD_en = 0;
				timer.INT_en = 0;
				timer.enable = 0;
				HPS_TIM_config_ASM(&timer);
				PB_flag = 123456789;
			}
			
			// third button was pressed -> stop timer
			// set every HEX of the display to 0
			if(PB_flag == 2){
				timer.LD_en = 0;
				timer.INT_en = 0;
				timer.enable = 0;
				HPS_TIM_config_ASM(&timer);
				PB_flag = 123456789;
				if (HPS_TIM_read_INT_ASM(timer.tim) == 0){
					HEX_write_ASM(HEX5,0);
					HEX_write_ASM(HEX4,0);
					HEX_write_ASM(HEX3,0);
					HEX_write_ASM(HEX2,0);
					HEX_write_ASM(HEX1,0);
					HEX_write_ASM(HEX0,0);				
				}
				// reset counters
				count_0 = 0;
				count_1 = 0;
				count_2 = 0;
				count_3 = 0;
				count_4 = 0;
				count_5 = 0;
			}
		}

		if(hps_tim0_flag){
			hps_tim0_flag = 0;
			//1s of centiseconds display
			if(++count0 == 10){
				count0 = 0;
				//10s of centiseconds display
				if(++count1==10){
					count1=0;
					//1s of seconds display
					if(++count2==10){
						count2=0;
						//10s of seconds display
						if(++count3==6){
							//Goes to 60 instead of 100
							count3=0;
							//1s of minutes display
							if(++count4==10){
								count4 = 0;
								//10s of minutes display
								if(++count5==6){
									//Goes to 60 instead of 100
									count5=0;
								}
							}
						}
					}
				}
			}
				
			//Update the display
			HEX_write_ASM(HEX5,count5);
			HEX_write_ASM(HEX4,count4);
			HEX_write_ASM(HEX3,count3);
			HEX_write_ASM(HEX2,count2);
			HEX_write_ASM(HEX1,count1);
			HEX_write_ASM(HEX0,count0);				
		}
	}
	return 0;
}

*/