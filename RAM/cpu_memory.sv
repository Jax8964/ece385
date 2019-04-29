`ifndef _CPU_MEMORY_SV
`define _CPU_MEMORY_SV
//`define MAPPER0
/*  2kb actual memory, 2kb ~ 8kb is the copy of first 2kb 
 *  000 0 0 000 0000 0000
 *     |   |2kb
 *     |8kb
  * 0x8000 ~ 0xffff is game code
 *  dual port, second read port for ppu
 *
 *  https://wiki.nesdev.com/w/index.php/NROM

 *  mapper 0: 
    16kb: 0x8000 ~ 0xbfff , mirror in 0xc000 ~ 0xffff
    32kb: 0x8000 ~ 0xffff
 */
module cpu_memory(              // data vaild at current circle 
    input logic         CLK,
    input logic         w, r,
    input logic [15:0]  address, address_ext,
    input logic [7:0]   data,

    output logic [7:0]  out, out_ext
);
    logic [15:0] ram [0:16'hffff];
    logic [15:0] real_address, real_address_ext; 
    initial begin
        $readmemh("H:/fpgaNES/NES/cpu6502/test.txt",ram);
        
        //$display("0x00: %h", ram[0]);
    end
    always_comb begin
        if(address[15:13] == 3'b0)    real_address = {5'b0,address[10:0]};
        else 
            `ifdef MAPPER0
                    real_address = {2'b11, address[13:0]};
            `else
                    real_address = address;
            `endif
        if(address_ext[15:13] == 3'b0)  real_address_ext = {5'b0,address_ext[10:0]};    
        else    
            `ifdef MAPPER0
                    real_address_ext = {2'b11, address_ext[13:0]};
            `else
                    real_address_ext = address_ext;
            `endif
    end
    always @(negedge CLK) begin
        if(w)
            ram[real_address] <= data;
        out = ram[real_address];
        out_ext = ram[real_address_ext];
    end

endmodule

`endif
