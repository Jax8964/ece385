`ifndef _CPU_MEMORY_SV
`define _CPU_MEMORY_SV
/*  2kb actual memory, 2kb ~ 8kb is the copy of first 2kb 
 *  000 0 0 000 0000 0000
 *     |   |2kb
 *     |8kb
  * 0x8000 ~ 0xffff is game code
 *  dual port, second read port for ppu
 *
 *  
 */
module cpu_memory(              // data vaild at current circle 
    input logic         CLK,
    input logic         w, r,
    input logic [15:0]  address, address_ext,
    input logic [7:0]   data,

    output logic [7:0]  out, out_ext
);
    logic [7:0] ram [0:16'hffff];
    logic [15:0] real_address, real_address_ext; 
    initial begin
        $readmemh("F:/fpgaNES/NES/cpu6502/test.txt",ram);
        
        //$display("0x00: %h", ram[0]);
    end
    always_comb begin
        if(address < 16'h2000)
            real_address = {5'b0,address[10:0]};
        else 
            real_address = address;
        if(address_ext < 16'h2000)
            real_address_ext = {5'b0,address_ext[10:0]};    
        else    
            real_address_ext = address_ext;
    end
    
    always @(negedge CLK) begin
        if(w)
            ram[real_address] <= data;
        out = ram[real_address];
        out_ext = ram[real_address_ext];
    end

endmodule

`endif
