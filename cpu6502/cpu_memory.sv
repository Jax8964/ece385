/*  2kb actual memory, 2kb ~ 8kb is the copy of first 2kb 
 *  000 0 0 000 0000 0000
 *     |   |2kb
 *     |8kb
 *
 */
module cpu_memory(              // data vaild at next circle 
    input logic         CLK,
    input logic         w,r,
    input logic [15:0]  address,
    input logic [7:0]   in,

    output logic [7:0]  out
);
    logic [7:0] ram [0:2047];
    initial begin
        $readmemh("H:/fpgaNES/NES/cpu6502/cpu_mem.txt",ram);
        $display("0x00: %h", ram[0]);
    end
    logic vaild_address;
    logic [10:0] real_address; 
    always_comb begin
        vaild_address = ~(address[15] | address[14] | address[13]);  // ==000
        real_address = address[10:0];
    end
    
    always @(posedge CLK) begin
        if(w & vaild_address)
            ram[real_address] <= in;
        if(r)
            out <= ram[real_address];
    end

endmodule