// CODE TO INTERFACE WITH THE DSP BOARD
module dsp(
		GPIO_0_TEMP,					//	GPIO Connection 0
		GPIO_1_TEMP,					//	GPIO Connection 1
        adc_b, 							// 	Output Data from ADC B
        dac_b,							// 	Input Data towards DAC B
        CLK_DAC,						//	DAC Sampling clock
        CLK_ADC);						//	ADC Sampling clock	

////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0_TEMP;					//	GPIO Connection 0
inout	[35:0]	GPIO_1_TEMP;					//	GPIO Connection 1

////////////////////////  ADC DAC I/O   ////////////////////////////
output  [13:0]adc_b;
input  [13:0]dac_b;

////////////////////	SAMPLING FREQUENCIES ///////////////////////
input CLK_DAC, CLK_ADC;


///////////////////		GPIO MAPPING		////////////////////////
assign  adc_b = {GPIO_0_TEMP[15],GPIO_0_TEMP[13],GPIO_0_TEMP[14],GPIO_0_TEMP[12],GPIO_0_TEMP[11],GPIO_0_TEMP[9],GPIO_0_TEMP[10],GPIO_0_TEMP[8],
                 GPIO_0_TEMP[7],GPIO_0_TEMP[5],GPIO_0_TEMP[6],GPIO_0_TEMP[4],GPIO_0_TEMP[3],GPIO_0_TEMP[1]};

assign  {GPIO_1_TEMP[19],GPIO_1_TEMP[21],GPIO_1_TEMP[22],GPIO_1_TEMP[24],GPIO_1_TEMP[23],GPIO_1_TEMP[25],GPIO_1_TEMP[27],GPIO_1_TEMP[29],
         GPIO_1_TEMP[26],GPIO_1_TEMP[28],GPIO_1_TEMP[31],GPIO_1_TEMP[33],GPIO_1_TEMP[30],GPIO_1_TEMP[32]} = dac_b; //B

assign  GPIO_1_TEMP[34] = CLK_DAC; 		//Input write signal for PORT B
assign  GPIO_1_TEMP[17] = CLK_DAC; 		//Input write signal for PORT A

assign  GPIO_1_TEMP[35] = 1; 			//Mode Select. 1 = dual port, 0 = interleaved.

assign  GPIO_0_TEMP[32] = 1; 			//POWER ON

assign  GPIO_0_TEMP[33] = 0; 			//Enable B
assign  GPIO_0_TEMP[35] = 1; 			//Don't Enable A

assign  GPIO_1_TEMP[18] = CLK_DAC; 		//PLL Clock to DAC_B
assign  GPIO_1_TEMP[16] = CLK_DAC; 		//PLL Clock to DAC_A

assign  GPIO_0_TEMP[18] = CLK_ADC; 		//PLL Clock to ADC_B
assign  GPIO_0_TEMP[16] = CLK_ADC; 		//PLL Clock to ADC_A
	
endmodule 
