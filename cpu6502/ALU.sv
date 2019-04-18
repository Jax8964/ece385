`ifndef _ALU_SV
`define _ALU_SV
`include "ripple_adder.sv"
typedef enum logic [3:0] {
        ALU_OR, ALU_AND, ALU_XOR, ALU_ADD, ALU_ADC, ALU_SUB, ALU_SUBC,
        ALU_SHL, ALU_SHR, ALU_ROR, ALU_ROL,
        ALU_ADD16,
        ALU_PASS
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
        ALU_Z = ALUL_out == 8'b0;  // zero
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
            ALU_ADD :
                ALUL_out = adderL;
            ALU_ADC : begin
                real_cin = cin;
                ALUL_out = adderL;
            end
            ALU_SUB : begin
                add_sub =  1'b1;
                ALUL_out = adderL;
            end
            ALU_SUC : begin
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
            ALU_PASS : begin
                ALUL_out = ALUL0;
                ALUH_out = ALUH0;
            end

        endcase
    end

    add_sub_8bit add_sub_8bitL(.add_sub(add_sub), .A(ALUL0), .B(ALUL1), .cin(real_cin), .cout(cout), .ret(adderL));
    ripple_adder ripple_adderH(.A(ALUH0), .B(ALUH1), .cin(cout), .cout(), .Sum(adderH));
    
endmodule

`endif
