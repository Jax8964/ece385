module carry_lookahead_adder16
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    input   logic           cin,
    output  logic[15:0]     Sum,
    output  logic           cout      // 8 bit cout
);

    logic [3:0] pg, gg;
    logic [2:0] c;

    carry_lookahead_adder_4bits f0(.A(A[3:0]),   .B(B[3:0]),   .cin(cin), .s(Sum[3:0]), .pg(pg[0]), .gg(gg[0]));
    carry_lookahead_adder_4bits f1(.A(A[7:4]),   .B(B[7:4]),   .cin(c[0]), .s(Sum[7:4]), .pg(pg[1]), .gg(gg[1]));
    carry_lookahead_adder_4bits f2(.A(A[11:8]),  .B(B[11:8]),  .cin(c[1]), .s(Sum[11:8]), .pg(pg[2]), .gg(gg[2]));
    carry_lookahead_adder_4bits f3(.A(A[15:12]), .B(B[15:12]), .cin(c[2]), .s(Sum[15:12]), .pg(pg[3]), .gg(gg[3]));

    CLU clu_(.p(pg[2:0]), .g(gg[2:0]), .cin(cin), .c(c));

    assign cout = c[1]; //cin&pg[0]&pg[1]&pg[2]&pg[3] | gg[0]&pg[1]&pg[2]&pg[3] | gg[1]&pg[2]&pg[3] | gg[2]&pg[3] | gg[3];


endmodule

module subtracter8
(
    input   logic[7:0]     A,       // A - B - cin
    input   logic[7:0]     B,
    input   logic          cin,
    output  logic[7:0]     Sum,
    output  logic          cout       
);
    logic [1:0] pg, gg;
    logic [1:0] c;
    logic [7:0] real_B;
    logic real_cin;
    always_comb begin
        real_B = ~B;
        real_cin = ~cin;
        c[0] = real_cin&pg[0] | gg[0];
        c[1] = real_cin&pg[0]&pg[1] | gg[0]&pg[1] | gg[1];
        cout = c[1];
    end 
    carry_lookahead_adder_4bits f0(.A(A[3:0]),   .B(real_B[3:0]),   .cin(real_cin), .s(Sum[3:0]), .pg(pg[0]), .gg(gg[0]));
    carry_lookahead_adder_4bits f1(.A(A[7:4]),   .B(real_B[7:4]),   .cin(c[0]), .s(Sum[7:4]), .pg(pg[1]), .gg(gg[1]));    

endmodule




module carry_lookahead_adder_4bits 
(
    input   logic[3:0]     A,
    input   logic[3:0]     B,
    input   logic          cin,
    output  logic[3:0]     s,
    output  logic          pg,
    output  logic          gg
);

    logic [3:0] p, g;
    logic [2:0] c;
    assign p = A^B;
    assign g = A&B;
    CLU clu_(.p(p[2:0]), .g(g[2:0]), .cin(cin), .c(c));

    full_adder fa0(.x(A[0]), .y(B[0]), .z(cin),  .c(), .s(s[0]));
    full_adder fa1(.x(A[1]), .y(B[1]), .z(c[0]), .c(), .s(s[1]));
    full_adder fa2(.x(A[2]), .y(B[2]), .z(c[1]), .c(), .s(s[2]));
    full_adder fa3(.x(A[3]), .y(B[3]), .z(c[2]), .c(),  .s(s[3]));

    assign pg = p[0]&p[1]&p[2]&p[3];
    assign gg = g[3] | g[2]&p[3] | g[1]&p[3]&p[2] | g[0]&p[3]&p[2]&p[1];

endmodule


module CLU(
    input logic [2:0] p,
    input logic [2:0] g,
    input logic cin,
    output logic [2:0] c
);
    always_comb begin
        c[0] = cin&p[0] | g[0];
        c[1] = cin&p[0]&p[1] | g[0]&p[1] | g[1];
        c[2] = cin&p[0]&p[1]&p[2] | g[0]&p[1]&p[2] | g[1]&p[2] | g[2];
     //   c[3] = cin&p[0]&p[1]&p[2]&p[3] | g[0]&p[1]&p[2]&p[3] | g[1]&p[2]&p[3] | g[2]&p[3] | g[3];
    end
endmodule


module full_adder(
    input x,y,z,
    output c,s
);
    assign s = x^y^z;
    assign c = (x&y)|(y&z)|(x&z);

endmodule
