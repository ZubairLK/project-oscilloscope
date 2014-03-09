/*
This module takes a 8 bit compressor input and outputs a signal to the VGA block
depending on the trigger from the trigger block.
Horizontal time base is adjusted by downsampling the input
based on user selected settings.
Authors: Zubair Lutfullah and M. Bakir
*/
module oscilloscope(
	//INPUTS
	input clk_25,				//25MHz clock	
	input clk_62_5,			//62.5 MHz clock	
	input rst_n,				//Reset Negative						  
	input [7:0]in_y,			//Channel 1	from compressor
	input [7:0]in_y2,			//Channel 2 from compressor
	input trigger,				//Channel 1 trigger
	input trigger_second,	//Channel 2 trigger

	input [2:0]downsample_sel,	//Channel 1 Time-base downsample sel
	input [2:0]downsample_sel_second, //Channel 2 Time-base downsample sel
	//OUTPUTS
	output reg [7:0]out_x,	//Horizontal pixel location output for VGA block
	output reg [7:0]out_y,  //Vertical pixel location output for VGA block
	output reg write_en,		//Write Enable for VGA block.
	output reg [11:0]RGB);	//Color of pixel

//State machine variables
parameter CLEAN = 2'b00;
parameter FILL = 2'b01;
parameter DISPLAY = 2'b10;
parameter END = 2'b11;
reg [1:0]state;

//Temporary Registers
reg [7:0]read_addr;	//Read Address for reading from RAM
reg [7:0]write_addr;	//Write Address for writing to RAM
reg buffer_full; 	//flag if buffer has been filled by ADC.
reg display_clean; //flag if vga screen has been cleared.

// Declare the RAM variable	
reg [7:0] ram_y[159:0];		//Channel 1 buffer
reg [7:0] ram_y2[159:0];	//Channel 2 buffer
reg second_channel;			//flag for which channel is being processed
	
//Horizontal time base downsample registers
reg [2:0]downsample_counter;	//Counter for downsampling channel 1
reg [2:0]downsample_counter_second;	 //Counter for downsampling channel 2



//Clock domain 62.5 MHz
always @ (posedge clk_62_5)
	begin		
	if(!rst_n)	//Clear registers on reset
		begin
		write_addr <= 0;
		buffer_full <= 0;		
		downsample_counter <=0;
		downsample_counter_second <=0;
		end //end if rst
	else
	begin

	case(state)	//State machine
		
		CLEAN :	begin
						//Nothing in this clock domain
					end	
		
		FILL : 	begin							
					//Fill buffer from ADC samples based on downsample counter.
					//If buffer full. Raise flag for other clock domain.
						if(write_addr == 8'b10011111)
						begin
							buffer_full <= 1;
							//state <= DISPLAY;
						end//end if writeadd == 8'b111111	
						else
						begin	
							if(second_channel)										
								begin
									if(downsample_counter_second == 0)
										begin
										
										if(in_y[7])
											ram_y[write_addr] <= 8'b10000000;
										else
											ram_y[write_addr] <= in_y;
											
										write_addr <= write_addr + 1;									
										end									
								end
							else
								begin
									if(downsample_counter == 0)
										begin
											
											if(in_y2[7])
												ram_y2[write_addr] <= 8'b10000000;
											else												
												ram_y2[write_addr] <= in_y2;
												
											write_addr <= write_addr + 1;
										end
								end
									
						end//end else 
					end	//end fill case

		DISPLAY:	begin
						//Nothing in this clock domain								
					end					
		
		END:		begin
						//Clear temporary registers for next cycle.
						write_addr <= 0;
						buffer_full <= 0;
						downsample_counter <= 0;
						downsample_counter_second <= 0;
					end
				
		default: begin				
						write_addr <= 0;
						buffer_full <= 0;
						downsample_counter <= 0;
						downsample_counter_second <= 0;
					end //end default case
					
		endcase //endcase state		
		
		//Downsample for horizontal time base adjustment
		if(downsample_counter == downsample_sel)
			downsample_counter <= 0;	//Reset counter based on user input
		else
			downsample_counter <= downsample_counter + 1;
			
		if(downsample_counter_second == downsample_sel_second)
			downsample_counter_second <= 0; //Reset counter based on user input
		else
			downsample_counter_second <= downsample_counter_second + 1;
			
	end//end begin of else of if(rst_n)
end //end always @ posedge clk 65MHz
	

//Second clock domain. 25MHz.	
always @ (posedge clk_25)
	begin
	if(!rst_n)
	begin
	//Clear registers on reset
		display_clean <=0;
		read_addr <= 0;
		write_en <= 0;
		read_addr <= 0;
		write_en <= 0;
		out_y <= 0;
		out_x <= 0;	
	
	end//end if rst_n
	
	else
	begin
		case (state)	//State machine
		
		CLEAN : 	begin
					//Read buffer again. Clear those pixels by
					//replacing with black for background
					//or white if grid location.
					//Once cleaned. Next state is FILL to refill buffer.
							if(read_addr == 8'b10011111)
							  begin
								display_clean <= 1;					   
								state <= FILL;
							  end	//end (if(read_addr == 8'b111111))		
							 else
								begin
									if(second_channel)
										begin
										out_y <= ram_y[read_addr];										
										end
									else
										begin
										out_y <= ram_y2[read_addr];																													
										end
									
									read_addr <= read_addr + 1;
									out_x <= read_addr;																		
									write_en <= 1;
									
									if(read_addr == 0 || read_addr == 20  || read_addr == 40  || read_addr == 60  || read_addr == 80  || read_addr == 100 || read_addr == 120
									 || read_addr == 140  || read_addr == 160 || out_y == 0 || out_y == 19 || out_y == 39 || out_y == 59 || out_y == 79
									 || out_y == 99 || out_y == 119)
									RGB <= 12'b111111111111;						
									else
									RGB <= 12'b000000000000;								
								end
								
					end	//end CLEAN case
					
		FILL : 	begin
					//Clear temporary registers.
					//Wait for buffer flag to go high
					//by the other clock domain.
							read_addr <= 0;
							write_en <= 0;
							read_addr <= 0;
							write_en <= 0;
							out_y <= 0;
							out_x <= 0;	
	
							if(buffer_full)
								state <= DISPLAY;
							else
								state <= FILL;
								
					end 	//end FILL case
					
		DISPLAY : begin													
						//Read buffer. Output to VGA block to display_clean
							if(read_addr == 8'b10011110)
							  begin										
								state <= END;
							  end	//end (if(read_addr == 8'b111111))	
							 else
							 begin
							 
								if(second_channel)
								begin
									out_y <= ram_y[read_addr];									
									RGB <= 12'b000000111111;
								 end
								 else
								 begin
									out_y <= ram_y2[read_addr];																		
									RGB <= 12'b111111000000;
								end	//end if second_channel
							 
								read_addr <= read_addr + 1;
								out_x <= read_addr;
								write_en <= 1;
								
									   
							  end	//end else
							
					 end	//end DISPLAY case
					 
		END: 		begin		
					//Clear temporary registers
					//Wait for trigger flag to go high 
					//signaling another loop for the state machine.
							read_addr <= 0;
							write_en <= 0;
							out_y <= 0;
							out_x <= 0;			
							
							if(trigger == 1)
							begin		
									state <= CLEAN;
									second_channel <= 1;
							end															
							else if(trigger_second == 1)
								begin
									state <= CLEAN;
									second_channel <= 0;
								end
							else
									state <= END;
																
							
					end	//end END case
					
		default: begin
						read_addr <= 0;
						write_en <= 0;
						out_y <= 0;
						out_x <= 0;							
					end
		endcase			
		
	end //end else of if rst  		
end	//end always @ posedge clk 65MHz


	
endmodule
