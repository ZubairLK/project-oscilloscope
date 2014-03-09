module	LCD_TEST (	//	Host Side
					iCLK,iRST_N,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS,
					A_Sel_Y,
					A_Sel_X,
					B_Sel_Y,
					B_Sel_X);
//	Host Side
input			iCLK,iRST_N;

input [2:0]A_Sel_X;
input [2:0]A_Sel_Y;
input [2:0]B_Sel_X;
input [2:0]B_Sel_Y;

//	LCD Side
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
wire		mLCD_Done;
reg refresh;
reg [2:0]A_Sel_X_temp;
reg [2:0]A_Sel_Y_temp;
reg [2:0]B_Sel_X_temp;
reg [2:0]B_Sel_Y_temp;

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
		else
			begin
				if(refresh == 1)
					LUT_INDEX<= 0;				
			end
			
			
			A_Sel_Y_temp <= A_Sel_Y;
			A_Sel_X_temp <= A_Sel_X;
			B_Sel_Y_temp <= B_Sel_Y;
			B_Sel_X_temp <= B_Sel_X;
			
			if(A_Sel_X_temp != A_Sel_X || A_Sel_Y_temp != A_Sel_Y || B_Sel_X_temp != B_Sel_X || B_Sel_Y_temp != B_Sel_Y)
				refresh <= 1;
			else
				refresh <= 0;
									
			
	end
end

always @ (*)
begin		
	
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h141;//A	//	0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 
													// A : 0 . 0 0 0  0  V   0  .  0  0   u S
	LCD_LINE1+1:	LUT_DATA	<=	9'h13A;//:
	LCD_LINE1+2:	case (A_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h130;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h131;// depends on input
						3'b111:	LUT_DATA	<=	9'h132;// depends on input
						endcase
	LCD_LINE1+3:	LUT_DATA	<=	9'h12E;//.
	LCD_LINE1+4:	case (A_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h132;// depends on input
						3'b001:	LUT_DATA	<=	9'h131;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h130;// depends on input
						3'b100:	LUT_DATA	<=	9'h132;// depends on input
						3'b101:	LUT_DATA	<=	9'h135;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase
	LCD_LINE1+5:	case (A_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h135;// depends on input
						3'b001:	LUT_DATA	<=	9'h132;// depends on input
						3'b010:	LUT_DATA	<=	9'h136;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h135;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase
	LCD_LINE1+6:	case (A_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h135;// depends on input
						3'b010:	LUT_DATA	<=	9'h132;// depends on input
						3'b011:	LUT_DATA	<=	9'h131;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase
	LCD_LINE1+7:	case (A_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h135;// depends on input
						3'b011:	LUT_DATA	<=	9'h132;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase
	LCD_LINE1+8:	LUT_DATA	<=	9'h156;// V
	LCD_LINE1+9:	LUT_DATA	<=	9'h120;// blank space
	LCD_LINE1+10:	case (A_Sel_X)
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h131;// depends on input
						3'b011:	LUT_DATA	<=	9'h131;// depends on input
						3'b100:	LUT_DATA	<=	9'h131;// depends on input
						3'b101:	LUT_DATA	<=	9'h132;// depends on input
						3'b110:	LUT_DATA	<=	9'h132;// depends on input
						3'b111:	LUT_DATA	<=	9'h132;// depends on input
						endcase
	LCD_LINE1+11:	LUT_DATA	<=	9'h12E;// .
	LCD_LINE1+12:	case (A_Sel_X)
						3'b000:	LUT_DATA	<=	9'h133;// depends on input
						3'b001:	LUT_DATA	<=	9'h136;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h136;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h133;// depends on input
						3'b111:	LUT_DATA	<=	9'h136;// depends on input
						endcase
	LCD_LINE1+13:	case (A_Sel_X)
						3'b000:	LUT_DATA	<=	9'h133;// depends on input
						3'b001:	LUT_DATA	<=	9'h136;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h136;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h133;// depends on input
						3'b111:	LUT_DATA	<=	9'h136;// depends on input
						endcase
	LCD_LINE1+14:	LUT_DATA	<=	9'h175;// u
	LCD_LINE1+15:	LUT_DATA	<=	9'h173;// s
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0:	LUT_DATA	<=	9'h142;//B	//	0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 41;	//	Altera DE2 Board
	                                    			// A : 0 . 0 0 0  0  V   0  .  0  0   u S
	LCD_LINE2+1:	LUT_DATA	<=	9'h13A;//:
	LCD_LINE2+2:	case (B_Sel_Y)
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h130;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h131;// depends on input
						3'b111:	LUT_DATA	<=	9'h132;// depends on input
						endcase                     
	LCD_LINE2+3:	LUT_DATA	<=	9'h12E;//.65;   
	LCD_LINE2+4:	case (B_Sel_Y)                  
						3'b000:	LUT_DATA	<=	9'h132;// depends on input
						3'b001:	LUT_DATA	<=	9'h131;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h130;// depends on input
						3'b100:	LUT_DATA	<=	9'h132;// depends on input
						3'b101:	LUT_DATA	<=	9'h135;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase                     
	LCD_LINE2+5:	case (B_Sel_Y)                  
						3'b000:	LUT_DATA	<=	9'h135;// depends on input
						3'b001:	LUT_DATA	<=	9'h132;// depends on input
						3'b010:	LUT_DATA	<=	9'h136;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h135;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase                     
	LCD_LINE2+6:	case (B_Sel_Y)                  
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h135;// depends on input
						3'b010:	LUT_DATA	<=	9'h132;// depends on input
						3'b011:	LUT_DATA	<=	9'h131;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase                     
	LCD_LINE2+7:	case (B_Sel_Y)                  
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h135;// depends on input
						3'b011:	LUT_DATA	<=	9'h132;// depends on input
						3'b100:	LUT_DATA	<=	9'h130;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h130;// depends on input
						3'b111:	LUT_DATA	<=	9'h130;// depends on input
						endcase                     
	LCD_LINE2+8:	LUT_DATA	<=	9'h156;// V     
	LCD_LINE2+9:	LUT_DATA	<=	9'h120;// blank space32;
	LCD_LINE2+10:	case (B_Sel_X)                  
						3'b000:	LUT_DATA	<=	9'h130;// depends on input
						3'b001:	LUT_DATA	<=	9'h130;// depends on input
						3'b010:	LUT_DATA	<=	9'h131;// depends on input
						3'b011:	LUT_DATA	<=	9'h131;// depends on input
						3'b100:	LUT_DATA	<=	9'h131;// depends on input
						3'b101:	LUT_DATA	<=	9'h132;// depends on input
						3'b110:	LUT_DATA	<=	9'h132;// depends on input
						3'b111:	LUT_DATA	<=	9'h132;// depends on input
						endcase                     
	LCD_LINE2+11:	LUT_DATA	<=	9'h12E;// .     
	LCD_LINE2+12:	case (B_Sel_X)                  
						3'b000:	LUT_DATA	<=	9'h133;// depends on input
						3'b001:	LUT_DATA	<=	9'h136;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h136;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h133;// depends on input
						3'b111:	LUT_DATA	<=	9'h136;// depends on input
						endcase                     
	LCD_LINE2+13:	case (B_Sel_X)                  
						3'b000:	LUT_DATA	<=	9'h133;// depends on input
						3'b001:	LUT_DATA	<=	9'h136;// depends on input
						3'b010:	LUT_DATA	<=	9'h130;// depends on input
						3'b011:	LUT_DATA	<=	9'h133;// depends on input
						3'b100:	LUT_DATA	<=	9'h136;// depends on input
						3'b101:	LUT_DATA	<=	9'h130;// depends on input
						3'b110:	LUT_DATA	<=	9'h133;// depends on input
						3'b111:	LUT_DATA	<=	9'h136;// depends on input
						endcase
	LCD_LINE2+14:	LUT_DATA	<=	9'h175;// u
	LCD_LINE2+15:	LUT_DATA	<=	9'h173;// s
	default:		LUT_DATA	<=	9'h000;
	endcase
end


LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule