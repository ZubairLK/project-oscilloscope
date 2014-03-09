/*
Trigger module. This module takes auto/external triggers
Depending on user selection the trigger is passed to oscilloscope.
The ADC MSB based trigger is downsampled. Every 32nd posedge
of the MSB is passed to the oscilloscope block.
The posedge of the MSB is cleaned by detecting the previous
and next samples as well to clean the glitches.
Authors : Zubair Lutfullah and M. Bakir
*/

module trigger(
	input clk_25,
	input clk_62_5,
	input rst_n,
	input trigger,				//Auto trigger
	input trigger_ext,		//External Trigger
	input trigger_sel,		//Channel Ext/Auto trigger sel
	output trigger_out		//Channel  trigger
	);
	
//Trigger temporary registers
reg [4:0] trigger_counter; //Counter for downsampling trigger
reg trigger_flag;				//Flag for auto trigger 
reg trigger_flag_ext;		//Flag for ext trigger 
reg trigger_ext_prev;		//Temp reg to store previous trigger ext

reg [3:0]trigger_temp;		//Temp reg used to 

always @ (posedge clk_62_5)
begin
	if(!rst_n)
	begin
	trigger_temp <= 4'b0000;
	trigger_counter <= 0;
	end	
	else
	begin
		trigger_temp[0] <= trigger_temp;
		trigger_temp[1] <= trigger_temp[0];
		trigger_temp[2] <= trigger_temp[1];
		trigger_temp[3] <= trigger_temp[2];
		
		//detect a proper rising trend. Not a glitch.		
		if(trigger_temp[0] == 1 && trigger_temp[1] == 1 && trigger_temp[2] == 0 && trigger_temp[3])
			trigger_counter <= trigger_counter + 1;			
	end
end

always @ (posedge clk_25)
begin
	if(!rst_n)
	begin
		trigger_flag <=0;
	end
	else
	begin
		
		//Auto downsampled trigger flag
		if(trigger_counter == 0)
			trigger_flag <= 1;
		else
			trigger_flag <= 0;
		
		//If posedge of external trigger detected
		//Raise ext flag
		if(trigger_ext ^ trigger_ext_prev)
			trigger_flag_ext <= 1;
		else
		begin				
			trigger_flag_ext <= 0;
			trigger_ext_prev <= trigger_ext;
		end
		
	end
end

//Assign trigger output depending on user selected trigger option.
assign trigger_out = (trigger_sel) ? (trigger_flag_ext) : (trigger_flag);

endmodule 