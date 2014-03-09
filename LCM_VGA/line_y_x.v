module line(input clk,
				input	rst_n,
				output [7:0]X_loc,
				output [7:0]Y_loc,
				output WR_en,
				output [11:0]RGB);

assign RGB = 12'b000011110000;
assign WR_en = 1;

reg [7:0]counter_X;
reg [7:0]counter_Y;

			
always @ (posedge clk)				
begin
	if(!rst_n)
		begin
			counter_X <= 0;
			counter_Y <= 0;		
		end
	else
		begin
			if(counter_X == 120)
				counter_X <= 0;
			else
				counter_X <= counter_X + 1;
		
			if(counter_Y == 120)
				counter_Y <= 0;
			else
				counter_Y <= counter_Y + 1;				
		
		end

end

assign X_loc = counter_X;
assign Y_loc = counter_Y;

endmodule 