`ifndef _RIPPLE_ADDER_
`define _RIPPLE_ADDER_


module add_sub_8bit
(
    input   logic          add_sub,     // 0 adder | 1 subtractor
    input   logic[7:0]     A,
    input   logic[7:0]     B,
    input   logic          cin,

    output  logic          cout,
    output  logic[7:0]     ret     // add_sub == 0: ret = A+B+cin  ,   add_sub == 1: ret = A-B-cin
);
    logic [7:0] C;
    logic real_cin;
    ripple_adder adder0(.A(A), .B(C), .cin(real_cin), .Sum(ret), .cout(cout) );
    
    always_comb begin
        C = {add_sub, add_sub, add_sub, add_sub, add_sub, add_sub, add_sub, add_sub} ^ B;
        real_cin = add_sub ^ cin;
    end 
endmodule




module ripple_adder
(
    input   logic[7:0]     A,
    input   logic[7:0]     B,
    input   logic          cin,
    output  logic[7:0]     Sum,
    output  logic          cout
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    
    logic c0;
    four_bit_ripple_adder f0(.x(A[3:0]),   .y(B[3:0]),   .z(cin), .c(c0), .s(Sum[3:0]));
    four_bit_ripple_adder f1(.x(A[7:4]),   .y(B[7:4]),   .z(c0), .c(cout), .s(Sum[7:4]));
     
endmodule



module four_bit_ripple_adder      //ripple adder
(
    input [3:0] x,
    input [3:0] y,
    input z,
    output logic [3:0] s,
    output logic c
);
    logic c0, c1, c2;
    full_adder fa0(.x(x[0]), .y(y[0]), .z(z),  .c(c0), .s(s[0]));
    full_adder fa1(.x(x[1]), .y(y[1]), .z(c0), .c(c1), .s(s[1]));
    full_adder fa2(.x(x[2]), .y(y[2]), .z(c1), .c(c2), .s(s[2]));
    full_adder fa3(.x(x[3]), .y(y[3]), .z(c2), .c(c),  .s(s[3]));
endmodule

module full_adder(
    input x,y,z,
    output c,s
);
    assign s = x^y^z;
    assign c = (x&y)|(y&z)|(x&z);

endmodule

`endif