`include "../ppu/ppu_top.sv" 
module testbenchPPU();
timeunit 10ns;	
timeprecision 1ns;
logic         CLK;
/////////////////////////////////
reg RESET;
logic NMI;
ppu_top ppu_test(
                    .*, .mirroring_type('0), .reg_data_in('0), .addr('0), .r('0), .w('0), 
                    .reg_data_out(), .cpu_address_ext(), .cpu_data_ext(),
                    .DrawX('0), .DrawY('0), .VGA_B(), .VGA_R(), .VGA_G()
     ); 
logic [8:0] render_counter, n_scanlines;
logic       prepare;
always_comb begin
    render_counter = ppu_test.render_screen0.counter[11:3];
    n_scanlines = ppu_test.render_screen0.n_scanlines;
    prepare = ppu_test.render_screen0.prepare;
end

logic [11:0] counter_;
ppu_counter1 ppu_counter1_test(.*, .reset(RESET), .halt('0), .max(8'd339), .counter(counter_) );
logic [8:0] max;
assign max = ppu_counter1_test.max;
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




#40000000;





//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end
endmodule
