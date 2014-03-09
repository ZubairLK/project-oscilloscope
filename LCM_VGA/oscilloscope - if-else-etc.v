module oscilloscope(input clk_25,
						  input clk_62_5,
						  input rst_n,
						  input [7:0]in_x,
						  input [7:0]in_y,
						  input trigger,
						  output reg [7:0]out_x,
						  output reg [7:0]out_y,
						  output reg write_en,
						  output reg [11:0]RGB);

// Quartus II Verilog Template used for RAM
// Simple Dual Port RAM with separate read/write addresses and
// separate read/write clocks


reg [7:0]read_addr;
reg [7:0]write_addr;
reg buffer_full; 	//flag if buffer has been filled by ADC.
reg display_clean; //flag if vga screen has been cleared.

// Declare the RAM variable	
reg [7:0] ram_y[119:0];
	
	
always @ (posedge clk_62_5)
	begin		
	if(!rst_n)
		begin
		write_addr <= 0;
		buffer_full <= 0;
		end //end if rst
	else
	begin
	
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
end
	
always @ (posedge clk_25)
	begin
	if(!rst_n)
	begin
		read_addr <=0;
		display_clean <=0;
	end//end if rst
	
	else
	begin
	
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