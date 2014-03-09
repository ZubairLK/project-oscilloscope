module compressor
(
	// Input Ports
	input clk,
	input rst_n,
	//input [13:0] in_x,
	input [13:0] in_y,
	input [2:0]sel_lines,
	input [1:0]offset_sel, 
	// Output Ports
	//output  [7:0]out_x,
	output  [7:0]out_y
);

//reg [13:0]temp_x;
reg [13:0]temp_y;
reg [13:0]temp_y2;
integer offset;

always @ (posedge clk)
begin
	if(!rst_n)
	begin
		temp_y <=0;
	end
	else
	begin
		case (sel_lines)
		4'b000: begin
			//		temp_x <= in_x >> 7;	offset subtraction is (2^14/2) = 8192 -> 8192 >> 7/6/5/4 + whatever to bring it to 60
					temp_y <= (in_y >> 7);
					temp_y2 <= temp_y - 4 + offset;
					end
		4'b001: begin
			//		temp_x <= in_x >> 6;
					temp_y <= (in_y >> 6);
					temp_y2 <= temp_y - 68 + offset;
					end
		4'b010: begin
			//		temp_x <= in_x >> 5;
					temp_y <= (in_y >> 5);
					temp_y2 <= temp_y - 196 + offset;
					end
		4'b011: begin
			//		temp_x <= in_x >> 4;
					temp_y <= (in_y >> 4);
					temp_y2 <= temp_y - 452 + offset;
					end
		4'b100: begin
			//		temp_x <= in_x >> 7;
					temp_y <= (in_y >> 7);
					temp_y2 <= temp_y - 4 + offset;
					end
		4'b101: begin
			//		temp_x <= in_x >> 8;
					temp_y <= (in_y >> 8);
					temp_y2 <= temp_y + 28 + offset;
					end
		4'b110: begin
			//		temp_x <= in_x >> 9;
					temp_y <= (in_y >> 9);
					temp_y2 <= temp_y + 44 + offset;
					end
		4'b111: begin
			//		temp_x <= in_x >> 10;
					temp_y <= (in_y >> 10);
					temp_y2 <= temp_y +52 + offset;
					end		
		default: begin
				//	temp_x <= in_x >> 7;
					temp_y <= in_y >> 7;
					end	
		endcase			
	end
end

always @ (*)
begin
	case(offset_sel)
	2'b00:	offset <= 0;
	2'b01:	offset <= 20;
	2'b10:	offset <= 40;
	2'b11:	offset <= -20;
	endcase
end

//assign out_x  = temp_x[7:0];
assign out_y  = temp_y2[7:0];

endmodule 