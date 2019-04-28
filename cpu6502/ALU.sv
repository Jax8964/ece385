`ifndef _ALU_SV
`define _ALU_SV
//`include "ripple_adder.sv"
`include "carry_lookahead_adder.sv"
typedef enum logic [3:0] {
        ALU_OR,         // ALUL0 | ALUL1
        ALU_AND,        // ALUL0 & ALUL1
        ALU_XOR,         // 8 bit 
        ALU_ADC,         // 8 bit 
        ALU_SUB,         // ALUL0 - ALUL1 
        ALU_SUBC,        // ALUL0 - ALUL1 - C
        ALU_SHL,         // 8 bit 
        ALU_SHR,         // 8 bit 
        ALU_ROR,         // 8 bit 
        ALU_ROL,         // 8 bit 
        ALU_ADD16,        // 16 bit adder  ALUL0 + ALUL1, ALUH0 + ALUH1
        ALU_PASS0,        // out = ALUH0, ALUL0
        ALU_PAS1          // out = ALUH1, ALUL1
} ALU_operation_t;

module ALU(                 
    input ALU_operation_t       ALU_operation,
    input logic [7:0]           ALUH0, ALUH1, ALUL0, ALUL1,
    input logic                 cin,

    output logic [7:0]          ALUH_out, ALUL_out,
    output logic                ALU_N, ALU_Z, ALU_C, ALU_V
);

    logic [7:0] adderL, adderH;
    logic real_cin, cout;
    logic add_sub;
    always_comb begin
        ALU_N = ALUL_out[7];        // negative flag
        ALU_Z = (ALUL_out == 8'b0);  // zero
        ALU_C = cout;
        ALU_V = (~ALUL0[7]) & (~ALUL1[7]) & (adderL[7]) | (ALUL0[7]) & (ALUL1[7]) & (~adderL[7]);
        ALUH_out = 8'b0;
        ALUL_out = 8'b0;
        add_sub = 1'b0;
        real_cin = 1'b0;
        unique case (ALU_operation)
            ALU_OR :
                ALUL_out = ALUL0 | ALUL1;
            ALU_AND :
                ALUL_out = ALUL0 & ALUL1;
            ALU_XOR :
                ALUL_out = ALUL0 ^ ALUL1;
            ALU_ADC : begin
                real_cin = cin;
                ALUL_out = adderL;
            end
            ALU_SUB : begin
                add_sub =  1'b1;
                ALUL_out = adderL;
            end
            ALU_SUBC : begin
                add_sub =  1'b1;
                real_cin = cin;
                ALUL_out = adderL;
            end
            ALU_SHL : begin
                ALUL_out = {ALUL0[6:0],1'b0};
                ALU_C = ALUL0[7];
            end
            ALU_ROL : begin
                ALUL_out = {ALUL0[6:0],cin};
                ALU_C = ALUL0[7];
            end
            ALU_SHR : begin
                ALUL_out = {1'b0, ALUL0[7:1]};
                ALU_C = ALUL0[0];
            end
            ALU_ROR : begin
                ALUL_out = {cin, ALUL0[7:1]};
                ALU_C = ALUL0[0];
            end
            ALU_ADD16 : begin
                ALUL_out = adderL;
                ALUH_out = adderH;
            end
            ALU_PASS0 : begin
                ALUL_out = ALUL0;
                ALUH_out = ALUH0;
            end
            ALU_PAS1 : begin
                ALUL_out = ALUL1;
                ALUH_out = ALUH1;
            end
        endcase
    end
    carry_lookahead_adder16 carry_lookahead_adder160(
        .A({ALUL0,ALUH0}), .B({ALUL1,ALUH1}), .sum({adderH,adderL}), .cin(real_cin), .cout(cout) );
    sub_8 sub_80(.A(ALUL0), .B(ALUL1), .sum(), .cin(real_cin), .cout(cout));
    
endmodule

`endif
