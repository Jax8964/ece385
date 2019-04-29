`include "../cpu6502/ALU.sv"
module testbenchALU();

timeunit 10ns;	
timeprecision 1ns;
logic           CLK;
/////////////////////////////
ALU_operation_t       ALU_operation;
reg [7:0]             ALUH0, ALUL0, ALUH1, ALUL1;
reg                   cin;
logic [7:0]           ALUH_out, ALUL_out;
logic                 ALU_N, ALU_Z, ALU_C, ALU_V;
ALU ALU_test(.*);
///////////////////////////////
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end
initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end 
initial begin: TEST_VECTORS


///////////////////////////

ALU_operation = ALU_SUB;
ALUH0 = 0;
ALUL0 = 8'h13;

ALUH1 = 0;
ALUL1 = 8'h12;
cin  = 1;
#2;
ALU_operation = ALU_SUB;
ALUH0 = 8'h00;
ALUL0 = 8'h00;

ALUH1 = 8'h00;
ALUL1 = 8'h00;
cin  = 1;
#2;
ALU_operation = ALU_SUB;
ALUH0 = 8'hfe;
ALUL0 = 8'h02;

ALUH1 = 8'h11;
ALUL1 = 8'h03;
cin  = 1;
#2;
ALU_operation = ALU_SUB;
ALUH0 = 8'hfe;
ALUL0 = 8'h6f;

ALUH1 = 8'h11;
ALUL1 = 8'h6f;
cin  = 1;
////////////////////////




end
endmodule
