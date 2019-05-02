`ifndef _GAMEPAD_SV
`define _GAMEPAD_SV

module GAMEPAD(
    input logic         CLK,
    input logic         w,r,
    input logic         address,
    input logic [7:0]   data,
    input logic [15:0]  keycode,
    output logic [7:0]  out
);


    logic [7:0] status, status1, status2;
    keycode_decode keycode_decode0(.keycode(keycode[15:8]), .out(status1));
    keycode_decode keycode_decode1(.keycode(keycode[7:0]), .out(status2));
    always_ff @(posedge CLK) begin
        status <= status1 | status2;
    end

    logic [7:0] regs[0:1];
    logic [7:0] regs_next[0:1];
    always_ff @(posedge CLK) begin
        regs <= regs_next;
    end
    always_comb begin
        regs_next = regs;
        if(w)
            regs_next[address] = data;
    end
    
    logic r_prev, shift;
    reg [7:0] shift_reg;
    always_ff @(posedge CLK) begin
        r_prev <= r;
        shift_reg <= regs[0][0] ?  status : (shift ? {shift_reg[6:0], 1'b0} :  shift_reg );
    end
    assign  shift = (r_prev == 1) && (r == 0) && (address == 0);
    assign  out = 8'(shift_reg[7]);

endmodule



module keycode_decode(
    input logic [7:0] keycode,
    output logic [7:0] out
);
    
    parameter A = 8'h0d;     // j
    parameter B = 8'h0e;     // k
    parameter SELECT = 8'h18;// u
    parameter START = 8'h0c; // i
    parameter U = 8'h1A;    // w
    parameter D = 8'h16;    // s
    parameter L = 8'h04;    // a
    parameter R = 8'h07;    // d
    always_comb begin
        case(keycode)
            A: out = {1'b1, 7'b0};
            B: out = {1'b0, 1'b1, 6'b0};
            SELECT: out = {2'b0, 1'b1, 5'b0};
            START: out = {3'b0, 1'b1, 4'b0};
            U: out = {4'b0, 1'b1, 3'b0};
            D: out = {5'b0, 1'b1, 2'b0};
            L: out = {6'b0, 1'b1, 1'b0};
            R: out = {7'b0, 1'b1};
            default: out = '0; 
        endcase
    end


endmodule



`endif
