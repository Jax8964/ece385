`include "../cpu6502/cpu6502_top.sv" 
module testbench();
timeunit 10ns;	
timeprecision 1ns;
logic         CLK;
/////////////////////////////////
reg RESET, NMI;
reg [17:0] SW;

cpu6502_top cpu6502_top_test(.*,.CLOCK_50(CLK), .KEY({2'b1,~NMI,~RESET}),
    .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5(), .HEX6(), .HEX7(), 
    .LEDR(), .LEDG()
);


logic [15:0]    PC, MAR, addr;        // mem address source
state_t         state;
logic [7:0]     A,              // regs
                X, 
                Y, 
                SR,             // status register
                SP,             // stack pointer
                ALUL, ALUH,     // ALU output
                ALUL0, ALUL1,
                MDRL, MDRH;     // mem readed data
always_comb begin
    state = cpu6502_top_test.CONTROL0.state;
    PC = cpu6502_top_test.PC;
    MAR = cpu6502_top_test.MAR;
    addr = cpu6502_top_test.addr;
    A = cpu6502_top_test.A;
    X = cpu6502_top_test.X;
    Y = cpu6502_top_test.Y;
    SR = cpu6502_top_test.SR;
    SP = cpu6502_top_test.SP;
    ALUL0 = cpu6502_top_test.ALUL0;
    ALUL1 = cpu6502_top_test.ALUL1;
    ALUL = cpu6502_top_test.ALUL;
    ALUH = cpu6502_top_test.ALUH;
    MDRL = cpu6502_top_test.MDRL;
    MDRH = cpu6502_top_test.MDRH;
end

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
SW = 18'd0;
NMI = '0;

#1;
RESET = '1;

#4;
RESET = '0;

#200;





//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end
endmodule
