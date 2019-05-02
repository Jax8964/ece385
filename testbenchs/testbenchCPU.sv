`include "../cpu6502/cpu6502_top.sv" 
module testbenchCPU();
timeunit 10ns;	
timeprecision 1ns;
logic         CLK;
/////////////////////////////////
reg RESET;
reg [17:0]  SW;
reg          NMI;
reg [7:0]    keycode;

cpu6502_top cpu6502_top_test(.*,.CLOCK_50(CLK), .KEY({3'b1,~RESET}),
    .HEX0(), .HEX1(), .HEX2(), .HEX3(), .keycode('0),
    .LEDR(), .LEDG(), .addr(), .ppu_reg_data(), .address_ext(), .mem_data_ext(), .ALU_data_out(), .ppu_reg_w(), .ppu_reg_r()
);


logic [15:0]    PC, MAR;
state_t         state;
logic [7:0]     A,              // regs
                X, 
                Y, 
                SR,             // status register
                SP,             // stack pointer
                ALUL, ALUH,     // ALU output
                ALUL0, ALUL1, 
                MDRL, MDRH;     // mem readed data
logic [15:0] addr, mem_address, real_address;
logic [7:0]  cpu_mem_out, mem_inner_data;
logic MEM_LDMDRL;
ALU_operation_t ALU_operation;
ALU_MUX_t ALU_MUX;
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
    cpu_mem_out = cpu6502_top_test.mem_data;
    mem_address = cpu6502_top_test.cpu_memory0.address;
    real_address = cpu6502_top_test.cpu_memory0.real_address;
    mem_inner_data = cpu6502_top_test.cpu_memory0.out;
    MEM_LDMDRL = cpu6502_top_test.CONTROL0.MEM_LDMDRL;
    ALU_operation = cpu6502_top_test.ALU_operation;
    ALU_MUX = cpu6502_top_test.ALU_MUX;
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
