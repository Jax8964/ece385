
module testbenchPPU();
timeunit 10ns;	
timeprecision 1ns;
logic         CLK;
/////////////////////////////////
reg RESET;
reg halt;
reg [8:0] max;
logic [11:0] counter;
ppu_counter1 ppu_counter1_test(.*, .reset(RESET) );

//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end
initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end 
initial begin: TEST_VECTORS
/////////////////////////////////////////
RESET = '0;
halt = '0;
max = 12'd339;
#2;
RESET = '1;

#4;
RESET = '0;




#4000;





//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end
endmodule
