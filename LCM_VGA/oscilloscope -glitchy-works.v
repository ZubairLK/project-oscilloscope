module oscilloscope(input clk_25,
						  input clk_62_5,
						  input rst_n,
						  //input [7:0]in_x,
						  input [7:0]in_y,
						  input trigger,
						  input [2:0]downsample_sel,
						  output reg [7:0]out_x,
						  output reg [7:0]out_y,
						  output reg write_en,
						  output reg [11:0]RGB);

// Quartus II Verilog Template used for RAM
// Simple Dual Port RAM with separate read/write addresses and
// separate read/write clocks

parameter CLEAN = 2'b00;
parameter FILL = 2'b01;
parameter DISPLAY = 2'b10;
parameter END = 2'b11;

reg [7:0]read_addr;
reg [7:0]write_addr;
reg buffer_full; 	//flag if buffer has been filled by ADC.
reg display_clean; //flag if vga screen has been cleared.

// Declare the RAM variable	
reg [7:0] ram_y[159:0];
	
reg [2:0]downsample_counter;	
reg [4:0] trigger_counter;
reg trigger_bit;
	
reg [1:0]state;
	
always @ (posedge clk_62_5)
	begin		
	if(!rst_n)
		begin
		write_addr <= 0;
		buffer_full <= 0;		
		downsample_counter <=0;
		end //end if rst
	else
	begin
	
		case(state)
		
		CLEAN :	begin
					
					end	//end clean case
		
		FILL : 	begin							
					
					if(write_addr == 8'b10011111)
						begin
							buffer_full <= 1;
							//state <= DISPLAY;
						end//end if writeadd == 8'b111111	
					else
						begin
							if(downsample_counter == 0)
								begin
									ram_y[write_addr] <= in_y;
									write_addr <= write_addr + 1;									
								end																					
						end//end else 
					
					end	//end fill case

		DISPLAY:	begin
		
		
					end	//END display case
					
		
		END:		begin
					
						write_addr <= 0;
						buffer_full <= 0;
						downsample_counter <= 0;
					end
				
		default: begin				
						write_addr <= 0;
						buffer_full <= 0;
					end //end default case
					
		endcase //endcase state		
		
		if(downsample_counter == downsample_sel)
			downsample_counter <= 0;
		else
			downsample_counter <= downsample_counter + 1; //keep downsample_counter running all the time..
		//this improves timing.
		
	end//end begin of else of if(rst_n)
end //end always @ posedge clk
	

	
always @ (posedge clk_25)
	begin
	if(!rst_n)
	begin
		read_addr <=0;
		display_clean <=0;
	end//end if rst
	
	else
	begin
		case (state)
		
		CLEAN : 	begin
													
							if(read_addr == 8'b10011111)
							  begin
								display_clean <= 1;					   
								state <= FILL;
							  end	//end (if(read_addr == 8'b111111))		
							 else
								begin
									out_y <= ram_y[read_addr];
									out_x <= read_addr;
									read_addr <= read_addr + 1;										
									write_en <= 1;
									RGB <= 12'b000000000000;								
								end
								
					end	//end CLEAN case
					
		FILL : 	begin
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
							
							if(read_addr == 8'b10011110)
							  begin										
								state <= END;
							  end	//end (if(read_addr == 8'b111111))	
							 else
							 begin
										out_y <= ram_y[read_addr];
  									   out_x <= read_addr;
										write_en <= 1;
										RGB <= 12'b111111111111;
									   read_addr <= read_addr + 1;
							  end
							
					 end	//end DISPLAY case
					 
		END: 		begin					
							read_addr <= 0;
							write_en <= 0;
							out_y <= 0;
							out_x <= 0;
							/*
							if(trigger)
								begin
									if(trigger_counter == 0)
											state <= CLEAN;
									else
											state <= END;
								end
							else
									state <= END;
							*/
							
							if(trigger_bit == 1)
											state <= CLEAN;
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
	
	
end

always @ (posedge trigger)
begin

//if(trigger_counter == 2000000)
	//		trigger_counter <= 0;
		//else
			

		if(state == END && trigger_counter == 0)
			trigger_bit <= 1;
		else
			trigger_bit <= 0;
			
		
		trigger_counter <= trigger_counter + 1;
			

end

	
endmodule



	/*
			if (trigger)	//if trigger high		
				begin
					if(display_clean)	//if display cleaned by 25MHz clk
						begin
							if(write_addr != 8'b11111111)	//until write_addr reaches limit. keep writing from input
								begin
									ram_y[write_addr] <= in_y;
									buffer_full <=0;
									write_addr <= write_addr + 1;
								end
							else									//Flag buffer is full when write_addr is 1111111111111
								begin
									buffer_full <= 1;				
								end			
						end
					else
						begin
							//if display is not cleaned. wait.
							write_addr<=0;					
						end
				end
			else		//when trigger is low. ram is being displayed on oscilloscope
				begin
					write_addr <= 0;					
				end
	end //end else rst_n
	*/




/*
	
			if(trigger)	//if trigger is high. clean display. then clk_65 will acquire data.
				begin
					//clear display here
					if(!display_clean)
						begin
							out_y <= ram_y[read_addr];
							out_x <= read_addr;
							read_addr <= read_addr + 1;										
							write_en <= 1;
							RGB <= 12'b000000000000;
							
							if(read_addr == 8'b11111111)
							  begin
								display_clean <= 1;					   
								read_addr <= 0;
							  end	//end (if(read_addr == 8'b111111))				
						end //end if(!display_clean)
						
					else
						begin	
						write_en <= 0;
						read_addr <= 0;
						end //end else
					
				end //end if (trigger)
			
			
			else
				begin
					//display ram here when trigger is low. and buffer is full. trigger must be high for enough duration..
					if(buffer_full)
						begin
							if(read_addr != 8'b11111111)
							begin
								out_y <= ram_y[read_addr];
								out_x <= read_addr;
								display_clean <= 0;
								write_en <= 1;
								RGB <= 12'b111111111111;
							  read_addr <= read_addr + 1;
							end
						end 
					else
						begin
						display_clean <= 1;	//display clean flag. trigger must be low for enough duration..			
						write_en <= 0;
						read_addr <= 0;
						end
					
				end//end else if trigger
	end //end else rst
end
						  
endmodule  
*/