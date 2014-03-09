module triangle(input clk,
					 input rst_n,
					 output  [13:0]X,
					 output  [13:0]Y);


reg [13:0] counter_x;
reg [13:0] counter_y;
reg toggle;

always @ (posedge clk)
begin

	if(!rst_n)
	begin
		counter_x <= 0;
		counter_y <= 0;
		toggle <= 1;
	end
	else
	begin	
	
		if(counter_x == 13'b1111111111111)			
				toggle <= !toggle; 

			counter_x <= counter_x + 1;

			if(toggle)
				counter_y <= counter_y + 1;
			else
				counter_y <= counter_y - 1;
			
		
	end
	

end					 

assign X = counter_x;
assign Y = counter_y;	
	
endmodule 