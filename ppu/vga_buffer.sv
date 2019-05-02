`ifndef _VGA_BUFFER_SV
`define _VGA_BUFFER_SV

module vga_buffer(
    input logic         CLK, w,
    input logic [15:0]  address, address_ext,
    input logic [7:0]   data,

    output logic [7:0]  out_ext

);
    logic [7:0] ram [0:16'hffff];
   initial begin
        $readmemh("F:/fpgaNES/NES/ppu/mali.txt",ram);
    end
    always @(negedge CLK) begin
        if(w)
            ram[address] <= data;
        out_ext = ram[address_ext];
    end
endmodule

`endif

