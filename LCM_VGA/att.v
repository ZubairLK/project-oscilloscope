/*attenuation module. 
attenuates input dac by 2,4,8,16 based on input*/

module attenuation(input [13:0]DAC_in,
						 input [3:0]Sel_att,
						 input clk,
						 output reg  [13:0]DAC_out);

//reg signed [31:0]coeff[0:7] = { -26464309,   130090094,   296297296,   464101396,   534075850,   464101396, 296297296,   130090094,   -26464309 };						 
parameter signed coeff_0 = 	-26464309;
parameter signed coeff_1 = 	130090094;
parameter signed coeff_2 = 	296297296;
parameter signed coeff_3 = 	464101396;
parameter signed coeff_4 = 	534075850;
parameter signed coeff_5 = 	464101396;
parameter signed coeff_6 = 	296297296;
parameter signed coeff_7 = 	130090094;
parameter signed coeff_8 = 	-26464309;
						 
parameter coeff_w = 	439555591;
parameter coeff_x = 	455236068;
parameter coeff_y = 	455236068;
parameter coeff_z = 	439555591;
						 
						 
reg signed  [31:0]tap_delay[0:10];
reg  [13:0]DAC_mov;

wire  [26:0]acc;
wire signed  [31:0]signed_wave;
wire signed  [61:0]filter;
wire unsigned  [31:0]dac_unsigned;

always @ (posedge clk)
begin

	case (Sel_att)
	
	4'b0000: DAC_out <= DAC_in >> 1; //Simple divide by 2
	4'b0010: DAC_out <= DAC_in >> 2; //Simple divide by 4
	4'b0100: DAC_out <= DAC_in >> 3; //Simple divide by 8
	4'b1000: DAC_out <= DAC_in >> 4; //Simple divide by 16
	4'b1111: DAC_out <= DAC_mov; // Moving average
	4'b0011: DAC_out <= filter[61:61-13];//dac_unsigned[31:31-13]; //Filter
	4'b0111: DAC_out <= signed_wave + 4096;
	default: DAC_out <= DAC_in;	
	endcase
	
end					

always @ (posedge clk)
begin
	tap_delay[0]  <= signed_wave;
	tap_delay[1]  <= tap_delay[0];
	tap_delay[2]  <= tap_delay[1];	
	tap_delay[3]  <= tap_delay[2];
	tap_delay[4]  <= tap_delay[3];
	tap_delay[5]  <= tap_delay[4];
	tap_delay[6]  <= tap_delay[5];
	tap_delay[7]  <= tap_delay[6];
	tap_delay[8]  <= tap_delay[7];
	tap_delay[9]  <= tap_delay[8];
	tap_delay[10] <= tap_delay[9];
	
	DAC_mov = acc[13:0];
end

assign acc = (tap_delay[0]+tap_delay[1]+tap_delay[2]+tap_delay[3]) >> 2;
assign signed_wave = DAC_in - 4096;
//assign filter = tap_delay[0]*coeff_0 + tap_delay[1]*coeff_1 + tap_delay[2]*coeff_2 + tap_delay[3]*coeff_3 + tap_delay[4]*coeff_4 + tap_delay[5]*coeff_5 +tap_delay[6]*coeff_6 + tap_delay[7]*coeff_7 + tap_delay[8]*coeff_8;
assign filter = tap_delay[0]*coeff_w + tap_delay[1]*coeff_x + tap_delay[2]*coeff_y + tap_delay[3]*coeff_z;
assign dac_unsigned = filter[61:61-32] + 4096;

endmodule
