`ifndef _GAMEPAD_SV
`define _GAMEPAD_SV
module GAMEPAD(
    input logic         CLK,
    input logic         w,r,
    input logic         address,
    input logic [7:0]   data,

    output logic [7:0]  out
);
    logic [7:0] regs[0:1];
    logic [7:0] regs_next[0:1];
    always_ff @(posedge CLK) begin
        regs <= regs_next;
    end


    always_comb begin
        regs_next = regs;
        out = regs[address];
        if(w)
            regs_next[address] = data;
    end
    
endmodule

`endif
