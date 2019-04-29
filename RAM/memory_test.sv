`include "cpu_memory.sv"
`include "../HexDriver.sv"

module memory_test (
    input logic CLOCK_50,
    input logic [17:0]       SW,
    output logic [6:0]      HEX0, HEX1, HEX2, HEX3
);
    logic [15:0] address;
    logic [7:0] out1, out2;
    always_ff @(posedge CLOCK_50) begin
        address <= SW[15:0];
    end
    cpu_memory cpu_memory0(.CLK(CLOCK_50), .w(0), .r(0), .address(address), .address_ext(16'(address+1)), .data(0),
         .out(out1),
         .out_ext(out2)
         );
    HexDriver HexDriver0(.In0(out1[3:0]), .Out0(HEX0));
    HexDriver HexDriver1(.In0(out1[7:4]), .Out0(HEX1));
    HexDriver HexDriver2(.In0(out2[3:0]), .Out0(HEX2));
    HexDriver HexDriver3(.In0(out2[7:4]), .Out0(HEX3));
    
endmodule