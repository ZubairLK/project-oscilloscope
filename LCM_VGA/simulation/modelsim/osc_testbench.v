
`timescale 1ps / 1ps
module osc_testbench   ; 
 
  wire  [7:0]  out_y   ; 
  reg    trigger   ; 
  reg    clk_25   ; 
  wire   write_en   ; 
  reg    clk_62_5   ; 
  reg  [7:0]  in_x   ; 
  reg    rst_n   ; 
  wire  [11:0]  RGB   ; 
  wire  [7:0]  out_x   ; 
  reg  [7:0]  in_y   ; 
  oscilloscope  
   DUT  ( 
       .out_y (out_y ) ,
      .trigger (trigger ) ,
      .clk_25 (clk_25 ) ,
      .write_en (write_en ) ,
      .clk_62_5 (clk_62_5 ) ,
      .in_x (in_x ) ,
      .rst_n (rst_n ) ,
      .RGB (RGB ) ,
      .out_x (out_x ) ,
      .in_y (in_y ) ); 


//Clock 25MHz
initial
  begin
	   clk_25  = 1'b1;
	   
	  forever
    #40  clk_25 = ~clk_25;
    
end
//CLOCK 62.5MHz
initial
begin
    clk_62_5 = 1'b1;
    forever
    #16  clk_62_5 = ~clk_62_5;
    
  end
//Reset pulse
initial
  begin
	  rst_n  = 1'b0;
	 # 1000 rst_n = 1'b1;
  end

//Counter _ X
initial
  begin
   in_x = 8'b00000000;
   
  
  forever
  #16  in_x = in_x + 1;
end

//Counter Y
initial 
begin
  
  in_y = 8'b00000000;
  
  forever
  #16  in_y = in_y + 1;
  
end



//Trigger

initial
 begin
 
 trigger  = 1'b1;
 
  forever
  # 10000 trigger = ~trigger;

  end

endmodule
