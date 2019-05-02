`include "../ppu/ppu_top.sv" 
module testbenchPPU();
timeunit 10ns;	
timeprecision 1ns;
logic         CLK;
/////////////////////////////////
reg RESET;
logic NMI;
ppu_top ppu_top0(
                    .*, .mirroring_type('0), .reg_data_in('0), .addr('0), .r('0), .w('0), 
                    .reg_data_out(), .cpu_address_ext(), .cpu_data_ext(),
                    .DrawX('0), .DrawY('0), .VGA_B(), .VGA_R(), .VGA_G()
     ); 



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

#2;
RESET = '1;

#4;
RESET = '0;




#200;





//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end
endmodule
