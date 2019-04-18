
module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic           CLK;
integer         i = 0;
/////////////////////////////
logic RESET, NMI;
logic [17:0] SW;
// logic [3:0] KEY;

// logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
// logic [17:0] LEDR;
// logic [7:0] LEDG;

cpu6502_top cpu6502_top_test(.*);

logic [15:0]    PC;
logic [7:0]     state,counter;
logic [7:0]     MDRL, MDRH;
always_comb begin
    PC = cpu6502_top_test.PC;
    state = cpu6502_top_test.CONTROL0.state;
    MDRL = cpu6502_top_test.MDRL;
    MDRH = cpu6502_top_test.MDRH;
    counter = cpu6502_top_test.CONTROL0.counter;
end
// Toggle the clock
// #1 means wait for a delay of 1 timeunit

always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end
initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end 
// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program

initial begin: TEST_VECTORS

RESET = '0;
SW = 18'd8;
NMI = '0;

#1;
RESET = '1;

#4;
RESET = '0;

#100;






end
endmodule
