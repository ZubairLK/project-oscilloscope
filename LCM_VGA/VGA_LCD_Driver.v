module VGA_LCD_Driver
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_25,						//	25 MHz
		
		////////////////////	Reset Input	 	////////////////////	 
		RESET_N,						//	Reset_N
		
		////////////////////	Write Input	 	////////////////////	 
		X,								//	X Pixel
		Y,								//  Y Pixel
		WR,								//	Write Enable
		RGB,							//	Colour
		
		////////////////////	VGA		////////////////////////////
		//VGA_CLK,   						//	VGA Clock
		VGA_HSYNC,						//	VGA H_SYNC
		VGA_VSYNC,						//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  						//	VGA Blue[9:0]
		
		////////////////////////	LCD Output  	////////////////////////
		//LCD_CLK,						//  LCD Data Clock
		LCD_HSYNC,						//	LCD Horizontal Sync
		LCD_VSYNC,						//  LCD Vertical Sync
		LCD_DATA,						//	LCD Data[7:0]

		LCD_SCLK,						//	LCD I2C Clock
		LCD_SDAT,						//	LCD I2C Data
		LCD_SCEN,						//	LCD I2C Enable

		LCD_GRST,						//	LCD Global Reset
		LCD_SHDB						//	LCD Sleep Mode
	);

////////////////////////	Clock Input	 	////////////////////////
input			CLOCK_25;

////////////////////////	Reset Input	 	////////////////////////	 
input			RESET_N;				//	50 MHz

////////////////////	Write Input	 	////////////////////	 
input	[7:0]		X;							//	X Pixel
input	[7:0]		Y;							//  Y Pixel
input	[11:0]		RGB;						//	Colour
input				WR;							//	Write Enable

////////////////////////	VGA	Output		////////////////////////
//output wire			VGA_CLK;   				//	VGA Clock			
//assign				VGA_CLK = LCD_CLK;
output reg			VGA_HSYNC;				//	VGA H_SYNC
output reg			VGA_VSYNC;				//	VGA V_SYNC
output reg			VGA_BLANK;				//	VGA BLANK
output wire			VGA_SYNC;				//	VGA SYNC
assign				VGA_SYNC = 1'b1;
output reg	[9:0]	VGA_R;   				//	VGA Red[9:0]
output reg 	[9:0]	VGA_G;	 				//	VGA Green[9:0]
output reg	[9:0]	VGA_B;   				//	VGA Blue[9:0]

////////////////////////	LCD Output  	////////////////////////
//output wire			LCD_CLK;				//  LCD Data Clock
output reg			LCD_HSYNC;				//	LCD Horizontal Sync
output reg			LCD_VSYNC;				//  LCD Vertical Sync
output reg [7:0]	LCD_DATA;				//	LCD Data[7:0]

output reg			LCD_SCLK;				//	LCD I2C Clock
output reg			LCD_SDAT;				//	LCD I2C Data
output reg			LCD_SCEN;				//	LCD I2C Enable

output wire			LCD_GRST;				//	LCD Global Reset
assign 				LCD_GRST = RESET_N;
output wire			LCD_SHDB;				//	LCD Sleep Mode
assign 				LCD_SHDB = 1'b1;

// Define internal registers

reg		[10:0]	LCD_H_COUNT, LCD_V_COUNT;					// LCD State Machine Counters
(* syn_preserve = 1 *) reg 	[10:0] 	LCD_H_PIXEL, LCD_H_SUBPIXEL, LCD_V_PIXEL;	// LCD pixel counters

wire 	[11:0] 	LCD_PIXEL_DATA;				// Temporary 12 bit pixel data for LCD
reg		[16:0]	LCD_PIXEL_ADDRESS;			// Memory location of pixel

reg		[10:0]	VGA_H_COUNT, VGA_V_COUNT;					// VGA State Machine Counters
(* syn_preserve = 1 *) reg 	[10:0] 	VGA_H_PIXEL, VGA_H_SUBPIXEL, VGA_V_PIXEL;	// VGA pixel counters

wire 	[11:0] 	VGA_PIXEL_DATA;				// Temporary 12 bit pixel data for LCD
reg		[16:0]	VGA_PIXEL_ADDRESS;			// Memory location of pixel

reg		[14:0]	WRITE_PIXEL_ADDRESS;

reg		[7:0] 	Red, Green, Blue;		// Colour registers



reg temp_VSYNC, temp_HSYNC;
reg temp2_VSYNC, temp2_HSYNC;


//LCD Timing Parameters - RGBDummy Mode - 25 MHz Clock - QVGA 320 x 240
//	Horizontal Parameter	( Pixel )
parameter	LCD_H_SYNC_CYC		=	1;		// 1
parameter	LCD_H_SYNC_BACK		=	239;	// 239
parameter	LCD_H_SYNC_ACT		=	1280;	// 1280
parameter	LCD_H_SYNC_FRONT	=	81;		// 81
parameter	LCD_H_SYNC_TOTAL	=	1600;	// 1600

//	Vertical Parameter		( Line )
parameter	LCD_V_SYNC_CYC		=	1;		// 1
parameter	LCD_V_SYNC_BACK		=	20;		// 20
parameter	LCD_V_SYNC_ACT		=	240;	// 240
parameter	LCD_V_SYNC_FRONT	=	4;		// 4
parameter	LCD_V_SYNC_TOTAL	=	264;	// 264


//VGA Timing Parameters - Parallel Data - 25 MHz Clock - VGA 640x480
//	Horizontal Parameter	( Pixel )
parameter	VGA_H_SYNC_CYC		=	96;		// 1
parameter	VGA_H_SYNC_BACK		=	140;	// 239
parameter	VGA_H_SYNC_ACT		=	640;	// 1280
parameter	VGA_H_SYNC_FRONT	=	20;		// 40
parameter	VGA_H_SYNC_TOTAL	=	800;	// 1560

//	Vertical Parameter		( Line )
parameter	VGA_V_SYNC_CYC		=	1600;	// 1
parameter	VGA_V_SYNC_BACK		=	31;		// 21
parameter	VGA_V_SYNC_ACT		=	480;	// 240
parameter	VGA_V_SYNC_FRONT	=	17;		// 8
parameter	VGA_V_SYNC_TOTAL	=	528;	// 262


// Define state machine registers and parameters
parameter WAIT=3'b111;
parameter IDLE=3'b000;
parameter BACK=3'b001;
parameter DISP=3'b010;
parameter FRONT=3'b011;

reg [2:0] LCD_H_STATE, LCD_H_NEXT;
reg [2:0] LCD_V_STATE, LCD_V_NEXT;
reg [2:0] VGA_H_STATE, VGA_H_NEXT;
reg [2:0] VGA_V_STATE, VGA_V_NEXT;


// PLL 50 MHz to 25 MHz 0 deg and 25 MHz 180 deg
//VIDEO_PLL PLL (			.inclk0(CLOCK_50),
//						.c0(CLOCK_25),
//						.c1(LCD_CLK) );

// Screen buffer memory - current VGA frame
screen_buffer SB (		//Port A
						.clock_a(CLOCK_25),
						.address_a(WRITE_PIXEL_ADDRESS),
						.data_a(RGB),
						.wren_a(WR),
						.q_a(),
						
						//Port B
						.clock_b(CLOCK_25),
						.address_b(VGA_PIXEL_ADDRESS),
						.data_b(6'd0),			
						.wren_b(1'd0),
						.q_b(VGA_PIXEL_DATA) );


// Line buffer memory - current frame
line_buffer LB (		.clock(CLOCK_25),
						.wraddress(VGA_H_PIXEL[10:2]),
						.wren(1'b1),
						.data(VGA_PIXEL_DATA),
						.rdaddress(LCD_H_PIXEL[10:1]),
						.q(LCD_PIXEL_DATA)
						);
				
//Configures the serial registers within the LCD TFT module
I2S_LCD_Config 	u4	(	//	Host Side
						.iCLK(CLOCK_25),
						.iRST_N(RESET_N),
						//	I2C Side
						.I2S_SCLK(LCD_SCLK),
						.I2S_SDAT(LCD_SDAT),
						.I2S_SCEN(LCD_SCEN)	);



// Finite State Machine to control LCD output timing - Horizontal
always@(LCD_H_STATE or LCD_H_COUNT)
begin
	case(LCD_H_STATE)
		WAIT:	LCD_H_NEXT = IDLE;
		
		IDLE:	LCD_H_NEXT = BACK;
									
		BACK:	begin
				if (LCD_H_COUNT < LCD_H_SYNC_BACK)
					LCD_H_NEXT = BACK;
				else
					LCD_H_NEXT = DISP;
				end
					
		DISP:	begin
				if ( LCD_H_COUNT < (LCD_H_SYNC_ACT+LCD_H_SYNC_BACK) )
					LCD_H_NEXT = DISP;
				else
					LCD_H_NEXT = FRONT;
				end
		
		FRONT:	begin
				if ( LCD_H_COUNT < (LCD_H_SYNC_FRONT+LCD_H_SYNC_ACT+LCD_H_SYNC_BACK-1) )
					LCD_H_NEXT = FRONT;
				else
					LCD_H_NEXT = BACK;
				end
		default:	LCD_H_NEXT = IDLE;
	endcase
end

// Finite State Machine to control LCD output timing - Vertical
always@(LCD_V_STATE or LCD_V_COUNT)
begin
	case(LCD_V_STATE)
		WAIT:	LCD_V_NEXT = IDLE;
		
		IDLE:	LCD_V_NEXT = BACK;

		BACK:	begin
				if (LCD_V_COUNT < LCD_V_SYNC_BACK)
					LCD_V_NEXT = BACK;
				else
					LCD_V_NEXT = DISP;
				end
				
		DISP:	begin
				if (LCD_V_COUNT < (LCD_V_SYNC_ACT+LCD_V_SYNC_BACK) )
					LCD_V_NEXT = DISP;
				else
					LCD_V_NEXT = FRONT;
				end
		
		FRONT: begin
				if ( LCD_V_COUNT < (LCD_V_SYNC_FRONT+LCD_V_SYNC_ACT+LCD_V_SYNC_BACK-1) )
					LCD_V_NEXT = FRONT;
				else
					LCD_V_NEXT = BACK;
				end
					
		default:	LCD_V_NEXT = IDLE;
	endcase
end



// Finite State Machine to control VGA output timing - Horizontal
always@(VGA_H_STATE or VGA_H_COUNT)
begin
	case(VGA_H_STATE)
		WAIT:	VGA_H_NEXT = IDLE;
	
		IDLE:	VGA_H_NEXT = BACK;
									
		BACK:	begin
				if (VGA_H_COUNT < VGA_H_SYNC_BACK)
					VGA_H_NEXT = BACK;
				else
					VGA_H_NEXT = DISP;
				end
					
		DISP:	begin
				if ( VGA_H_COUNT <= (VGA_H_SYNC_ACT+VGA_H_SYNC_BACK+1) )
					VGA_H_NEXT = DISP;
				else
					VGA_H_NEXT = FRONT;
				end
		
		FRONT:	begin
				if ( VGA_H_COUNT < (VGA_H_SYNC_FRONT+VGA_H_SYNC_ACT+VGA_H_SYNC_BACK-1) )
					VGA_H_NEXT = FRONT;
				else
					VGA_H_NEXT = BACK;
				end
		default:	VGA_H_NEXT = IDLE;
	endcase
end

// Finite State Machine to control VGA output timing - Vertical
always@(VGA_V_STATE or VGA_V_COUNT)
begin
	case(VGA_V_STATE)
		WAIT:	VGA_V_NEXT = IDLE;
		
		IDLE:	VGA_V_NEXT = BACK;

		BACK:	begin
				if (VGA_V_COUNT < VGA_V_SYNC_BACK)
					VGA_V_NEXT = BACK;
				else
					VGA_V_NEXT = DISP;
				end
				
		DISP:	begin
				if (VGA_V_COUNT < (VGA_V_SYNC_ACT+VGA_V_SYNC_BACK) )
					VGA_V_NEXT = DISP;
				else
					VGA_V_NEXT = FRONT;
				end
		
		FRONT: begin
				if ( VGA_V_COUNT < (VGA_V_SYNC_FRONT+VGA_V_SYNC_ACT+VGA_V_SYNC_BACK-1) )
					VGA_V_NEXT = FRONT;
				else
					VGA_V_NEXT = BACK;
				end
					
		default:	VGA_V_NEXT = IDLE;
	endcase
end











//	LCD TFT Output, Ref. 25.175 MHz Clock
always@(posedge CLOCK_25 or negedge RESET_N)
begin

	if(!RESET_N)
	begin
	
		//Reset LCD State Machine
		LCD_H_STATE <= IDLE;
		//LCD_V_STATE <= IDLE;
		LCD_V_STATE <= DISP;
			
		//Reset LCD Horizontal counter and sync
		LCD_H_COUNT	<=	11'b11111111111;
		LCD_HSYNC	<=	1;
		
		//Reset LCD Vertical counter and sync
		//LCD_V_COUNT	<=	11'b11111111111;
		LCD_V_COUNT	<=  LCD_V_SYNC_BACK+1;
		LCD_VSYNC	<=	1;
		
		//Reset VGA State Machine
		VGA_H_STATE <= IDLE;
		//VGA_V_STATE <= WAIT;
		VGA_V_STATE <= DISP;
			
		//Reset VGA Horizontal counter and sync
		VGA_H_COUNT	<=	11'b11111111111;
		VGA_HSYNC	<=	1;
		
		//Reset VGA Vertical counter and sync
		//VGA_V_COUNT	<=	11'b11111111111;
		VGA_V_COUNT	<=  VGA_V_SYNC_BACK+1;
		VGA_VSYNC	<=	1;
		
	end
	else	// Not reset - system active
	begin
		
		WRITE_PIXEL_ADDRESS <= (Y*160) + X;
		
		// LCD ////////////////////////////////////////////////////////////////
		
		// Advance FSM to next state
		LCD_H_STATE <= LCD_H_NEXT;
		
		case(LCD_H_STATE)
			FRONT: begin
					if(LCD_H_NEXT==BACK)
						LCD_H_COUNT <= 11'd0;		//Reset counter at end of horizontal line
					else
						LCD_H_COUNT <= LCD_H_COUNT+11'd1;
					end
						
			default: LCD_H_COUNT <= LCD_H_COUNT+11'd1;
		endcase
		
		if (LCD_H_COUNT==LCD_H_SYNC_TOTAL-1)
		begin
			LCD_V_STATE <= LCD_V_NEXT;
			
			case(LCD_V_STATE)
				FRONT: begin
					if(LCD_V_NEXT==BACK)
						LCD_V_COUNT <= 11'd0;
					else if (LCD_V_NEXT!=BACK)
						LCD_V_COUNT <= LCD_V_COUNT+11'd1;
					end						
				default: begin
						LCD_V_COUNT <= LCD_V_COUNT+11'd1;
					end
			endcase
		end
		
		
		case(LCD_H_STATE)
			IDLE:	begin
						LCD_HSYNC	<=	1;
						LCD_H_SUBPIXEL <= 1;
					end
	
			BACK:	begin
						if (LCD_H_COUNT<LCD_H_SYNC_CYC)
							begin
							LCD_HSYNC	<=	0;
							LCD_H_SUBPIXEL <= 0;
							end
						else
							begin
							LCD_HSYNC	<=	1;
							LCD_H_SUBPIXEL <= 0;
							end
					end
						
			DISP:	begin
						LCD_HSYNC	<=	1;
						LCD_H_SUBPIXEL <= LCD_H_SUBPIXEL + 11'd1;
					end
			
			FRONT: begin
						LCD_HSYNC	<=	1;
						LCD_H_SUBPIXEL <= 0;
					end
						
			default: begin
						LCD_HSYNC	<=	1;
						LCD_H_SUBPIXEL <= 0;
					end
		endcase	
			
			
		case(LCD_V_STATE)
				
			BACK:	begin
						if (LCD_H_COUNT<LCD_V_SYNC_CYC & LCD_V_COUNT == 0)
							LCD_VSYNC	<=	0;
						else
							LCD_VSYNC	<=	1;
					end	
						
			default: begin
						LCD_VSYNC	<=	1;
					end
		endcase
		
		//Calculate current pixel position (Top left is 0,0)
		LCD_H_PIXEL <= LCD_H_SUBPIXEL[10:2]+11'd1;
		LCD_V_PIXEL <= LCD_V_COUNT[10:0]-LCD_V_SYNC_BACK-11'd1;
		
		//Calculate current position in RAM
		LCD_PIXEL_ADDRESS <= (LCD_V_PIXEL[10:1]*160) + LCD_H_PIXEL[10:1];

		//Generate Colour Data
		if(	LCD_V_STATE==DISP & LCD_H_STATE==DISP )	//Signal within Visible Display
		begin
						
//			if( LCD_V_PIXEL==10'd80)
//			begin
//				Red <= 8'hFF;
//				Green <= 8'h00;
//				Blue <= 8'h00;
//			end
//			else if( LCD_H_PIXEL==10'd80)
//			begin
//				Red <= 8'hFF;
//				Green <= 8'h00;
//				Blue <= 8'h00;
//			end
//			else if( LCD_H_PIXEL==10'd100)
//			begin
//				Red <= 8'h00;
//				Green <= 8'hFF;
//				Blue <= 8'h00;
//			end
//			else if( LCD_V_PIXEL==10'd100)
//			begin
//				Red <= 8'h00;
//				Green <= 8'hFF;
//				Blue <= 8'h00;
//			end
//			else
//			begin
//				Red <= 8'h00;
//				Green <= 8'h00;
//				Blue <= 8'h00;
//			end
			
			// LCD Data
			case(LCD_H_COUNT[1:0])
				0:	LCD_DATA <= {LCD_PIXEL_DATA[3:0],4'b1111}; //Red
				1:	LCD_DATA <= {LCD_PIXEL_DATA[7:4],4'b1111}; //Green
				2:	LCD_DATA <= {LCD_PIXEL_DATA[11:8],4'b1111}; //Blue
				3:	LCD_DATA <= 8'h00; //Dummy
//				0:	LCD_DATA <= Red; //Red
//				1:	LCD_DATA <= Green; //Green
//				2:	LCD_DATA <= Blue; //Blue
//				3:	LCD_DATA <= 8'h00; //Dummy
			endcase
		
		end
		else
		begin
			//LCD
			Red <= 8'h80;
			Green <= 8'h80;
			Green <= 8'h80;
			LCD_DATA <= 8'h80;
		end
	
	
		// VGA ////////////////////////////////////////////////////////////////
		
		// Advance FSM to next state
		VGA_H_STATE <= VGA_H_NEXT;
		
		case(VGA_H_STATE)
			FRONT: begin
					if(VGA_H_NEXT==BACK)
						VGA_H_COUNT <= 11'd0;		//Reset counter at end of horizontal line
					else
						VGA_H_COUNT <= VGA_H_COUNT+11'd1;
					end
						
			default: VGA_H_COUNT <= VGA_H_COUNT+11'd1;
		endcase
		
		if (VGA_H_COUNT==VGA_H_SYNC_TOTAL-1)
		begin
			VGA_V_STATE <= VGA_V_NEXT;
			
			case(VGA_V_STATE)
				WAIT:	begin end
				FRONT: begin
					if(VGA_V_NEXT==BACK)
						VGA_V_COUNT <= 11'd0;
					else if (VGA_V_NEXT!=BACK)
						VGA_V_COUNT <= VGA_V_COUNT+11'd1;
					end					
				default: begin
						VGA_V_COUNT <= VGA_V_COUNT+11'd1;
					end
			endcase
		end
		
		
		case(VGA_H_STATE)
			IDLE:	begin
						VGA_HSYNC	<=	1;
						VGA_H_PIXEL <= 1;
					end
	
			BACK:	begin
						if (VGA_H_COUNT<VGA_H_SYNC_CYC)
							begin
							VGA_HSYNC	<=	0;
							VGA_H_PIXEL <= 0;
							end
						else
							begin
							VGA_HSYNC	<=	1;
							VGA_H_PIXEL <= 0;
							end
					end
						
			DISP:	begin
						VGA_HSYNC	<=	1;
						VGA_H_PIXEL <= VGA_H_PIXEL + 11'd1;
					end
			
			FRONT: begin
						VGA_HSYNC	<=	1;
						VGA_H_PIXEL <= 0;
					end
						
			default: begin
						VGA_HSYNC	<=	1;
						VGA_H_PIXEL <= 0;
					end
		endcase	
			
			
		case(VGA_V_STATE)
				
			BACK:	begin
						if (VGA_H_COUNT<VGA_V_SYNC_CYC & VGA_V_COUNT == 0)
							VGA_VSYNC	<=	0;
						else
							VGA_VSYNC	<=	1;
					end	
						
			default: begin
						VGA_VSYNC	<=	1;
					end
		endcase
	
		//Calculate current pixel position (Top left is 0,0)
		//VGA_H_PIXEL <= VGA_H_SUBPIXEL[9:1]+11'd1;
		VGA_V_PIXEL <= VGA_V_COUNT[10:0] - VGA_V_SYNC_BACK - 11'd1;
		
		//Calculate current position in RAM
		VGA_PIXEL_ADDRESS <= ({2'b0,VGA_V_PIXEL[10:2]}*160) + {2'b0,VGA_H_PIXEL[10:2]};

		//Generate Colour Data
		if(	VGA_V_STATE==DISP & VGA_H_STATE==DISP )	//Signal within Visible Display
		//if(	VGA_V_COUNT>=VGA_V_SYNC_BACK & VGA_V_COUNT<=VGA_V_SYNC_BACK+VGA_V_SYNC_FRONT+VGA_V_SYNC_ACT+1 & VGA_H_COUNT>=VGA_H_SYNC_BACK & VGA_H_COUNT<=VGA_H_SYNC_BACK+VGA_H_SYNC_FRONT+VGA_H_SYNC_ACT+4 )	//Signal within Visible Display
		begin
						
			if( VGA_H_PIXEL==VGA_V_PIXEL )
			begin
				Red <= 8'hFF;
				Green <= 8'hFF;
				Blue <= 8'hFF;
			end
			else if( VGA_V_PIXEL==11'd0)
			begin
				Red <= 8'hFF;
				Green <= 8'h00;
				Blue <= 8'h00;
			end
			else if( VGA_H_PIXEL==11'd0)
			begin
				Red <= 8'hFF;
				Green <= 8'h00;
				Blue <= 8'h00;
			end
			else if( VGA_H_PIXEL==11'd638)
			begin
				Red <= 8'h00;
				Green <= 8'hFF;
				Blue <= 8'h00;
			end
			else if( VGA_V_PIXEL==11'd479)
			begin
				Red <= 8'h00;
				Green <= 8'hFF;
				Blue <= 8'h00;
			end
			else
			begin
				Red <= 8'h00;
				Green <= 8'h00;
				Blue <= 8'h00;
			end
			
			// VGA Data
			VGA_R <= {VGA_PIXEL_DATA[3:0],6'b111111};   //	VGA Red[9:0]
			VGA_G <= {VGA_PIXEL_DATA[7:4],6'b111111};	//	VGA Green[9:0]
			VGA_B <= {VGA_PIXEL_DATA[11:8],6'b111111};  //	VGA Blue[9:0]
			//VGA_R <= {Red[7:4],6'b111111};   //	VGA Red[9:0]
			//VGA_G <= {Green[7:4],6'b111111};	//	VGA Green[9:0]
			//VGA_B <= {Blue[7:4],6'b111111};  //	VGA Blue[9:0]
			VGA_BLANK <= 1'b1;
							
		end
		else
		begin
			//LCD
			VGA_R <= 10'd0;	//	VGA Red[9:0]
			VGA_G <= 10'd0;	//	VGA Green[9:0]
			VGA_B <= 10'd0;	//	VGA Blue[9:0]
			VGA_BLANK <= 1'b0;
		end
		
		
	end
end

endmodule

