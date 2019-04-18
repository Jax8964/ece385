module ram ( 
    input logic         CLK,
    input logic         w,
    input logic [9:0]  address,
    input logic [7:0]   in,

    output reg [7:0]  out
); 

logic [7:0] mem [0:1023];
always @ (posedge CLK) 
begin 
    if (w) mem[address] = in; 
    out = mem[address];
end
endmodule

module single_clk_ram( output reg [7:0] q, input [7:0] d, input [6:0] write_address, read_address, input we, clk
); reg [7:0] mem [127:0];
always @ (posedge clk) begin if (we)
mem[write_address] <= d; q <= mem[read_address]; // q doesn't get d in this clock cycle end endmodule