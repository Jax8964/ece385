module cpu6502_top(
    input logic CLK, RESET, NMI,
    input logic [3:0] KEY,

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output logic [17:0] LEDR[17:0],
    output logic [7:0] LEDG
);

    logic [15:0]    PC;
    logic [7:0]     A,X,Y,SR,SP;
    
endmodule