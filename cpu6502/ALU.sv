`ifndef _ALU_SV
`define _ALU_SV
`include "carry_lookahead_adder.sv"
typedef enum logic [3:0] {
        ALU_OR,         // ALUL0 | ALUL1
        ALU_AND,        // ALUL0 & ALUL1
        ALU_XOR,         // ALUL0 ^ ALUL1
        ALU_ADC,         // ALUL0 + ALUL1 + C
        ALU_SUB,         // ALUL0 - ALUL1 
        ALU_SUBC,        // ALUL0 - ALUL1 - C
        ALU_SHL,         // 8 bit 
        ALU_SHR,         // 8 bit 
        ALU_ROR,         // 8 bit 
        ALU_ROL,         // 8 bit 
        ALU_ADD16,        // ALUL0 + ALUL1, ALUH0 + ALUH1
        ALU_PASS0,        // out = ALUH0, ALUL0
        ALU_PASS0H        // out = ALUL0, ALUH0
} ALU_operation_t;
// typedef enum logic [2:0] {      // ALU0    |     ALU1
//     ALU_AM,                     // 00,A          MDR
//     ALU_XM,                     // 00,X          MDR
//     ALU_YM,                     // 00,Y          MDR
//     ALU_PCM,                    // PC            MDRL(sign extention)   used for branch 
//     ALU_INCM,                   // MDR           00,1
//     ALU_INCX,                   // SP,X          00,1                   ALUH not important, just for pass SR, SP
//     ALU_INCY                    // SR,Y          00,1
// } ALU_MUX_t;
module ALU(                 
    input ALU_operation_t       ALU_operation,
    input logic [7:0]           ALUH0, ALUH1, ALUL0, ALUL1,
    input logic                 cin,

    output logic [7:0]          ALUH_out, ALUL_out,
    output logic                ALU_N, ALU_Z, ALU_C, ALU_V
);

    logic [7:0] adderL, adderH, sub_out;
    logic real_cin, adder_cout, sub_cout, adder_V, sub_V;
    always_comb begin
        adder_V = (~ALUL0[7]) & (~ALUL1[7]) & (adderL[7]) | (ALUL0[7]) & (ALUL1[7]) & (~adderL[7]);
        sub_V = (~ALUL0[7]) & (ALUL1[7]) & (sub_out[7]) | (ALUL0[7]) & (~ALUL1[7]) & (~sub_out[7]);
        ALU_N = ALUL_out[7];        // negative flag
        ALU_Z = ALUL_out == 8'b0;//~(ALUL_out[7] | ALUL_out[6] | ALUL_out[5] | ALUL_out[4] | ALUL_out[3] | ALUL_out[2] | ALUL_out[1] | ALUL_out[0]);  // zero
    
    end
    always_comb begin
        ALUH_out = 8'b0;
        ALUL_out = 8'b0;
        real_cin = 1'b0;
        ALU_C = adder_cout;
        ALU_V = adder_V;
        case (ALU_operation)
            ALU_OR :
                ALUL_out = ALUL0 | ALUL1;
            ALU_AND :
                ALUL_out = ALUL0 & ALUL1;
            ALU_XOR :
                ALUL_out = ALUL0 ^ ALUL1;
            ALU_ADC : begin
                real_cin = cin;
                ALUH_out = adderH;
                ALUL_out = adderL;
            end
            ALU_SUB : begin
                ALUL_out = sub_out;
                ALU_V = sub_V;
                ALU_C = sub_cout;
            end
            ALU_SUBC : begin
                real_cin = cin;
                ALUL_out = sub_out;
                ALU_V = sub_V;
                ALU_C = sub_cout;
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
            ALU_PASS0H : begin
                ALUL_out = ALUH0;
                ALUH_out = ALUL0;
            end
            default : ;
        endcase
    end

    carry_lookahead_adder16 carry_lookahead_adder160(
        .A({ALUH0,ALUL0}), 
        .B({ALUH1,ALUL1}), 
        .Sum({adderH,adderL}), 
        .cin(real_cin), 
        .cout(adder_cout) 
    );
    subtracter8 sub_80(.A(ALUL0), .B(ALUL1), .Sum(sub_out), .cin(real_cin), .cout(sub_cout));

endmodule


/********************* ALU_MUX *****************************/
typedef enum logic [2:0] {      // ALU0    |     ALU1
    ALU_AM,                     // 00,A          MDR
    ALU_XM,                     // 00,X          MDR
    ALU_YM,                     // 00,Y          MDR
    ALU_PCM,                    // PC            MDRL(sign extention)   used for branch 
    ALU_INCM,                   // MDR           00,1
    ALU_INCX,                   // SP,X          00,1                   ALUH not important, just for pass SR, SP
    ALU_INCY                    // SR,Y          00,1
} ALU_MUX_t;

module ALU_MUX_unit(           
    input ALU_MUX_t             ALU_MUX,            // select input of ALU
    input logic [7:0]           MDRH, MDRL, A, X, Y, SP, SR,
    input logic [15:0]          PC, 

    output logic [7:0]          ALUH0, ALUH1, ALUL0, ALUL1
);
    always_comb begin
        ALUH0 = 8'b0;
        ALUH1 = 8'b0;
        ALUL0 = 8'b0;
        ALUL1 = 8'b0;
        case(ALU_MUX)
            ALU_AM: begin
                ALUL0 = A;
                ALUH1 = MDRH;
                ALUL1 = MDRL;
            end
            ALU_XM: begin
                ALUL0 = X;
                ALUH1 = MDRH;
                ALUL1 = MDRL;
            end
            ALU_YM: begin
                ALUL0 = Y;
                ALUH1 = MDRH;
                ALUL1 = MDRL;
            end
            ALU_PCM: begin
                ALUH0 = PC[15:8];
                ALUL0 = PC[7:0];
                ALUH1 = {8{MDRL[7]}};
                ALUL1 = MDRL;
            end            
            ALU_INCM: begin
                ALUH0 = MDRH;
                ALUL0 = MDRL;
                ALUL1 = 1;
            end
            ALU_INCX: begin
                ALUH0 = SP;
                ALUL0 = X;
                ALUL1 = 1;
            end
            ALU_INCY: begin
                ALUH0 = SR;
                ALUL0 = Y;
                ALUL1 = 1;
            end
        endcase
    end
endmodule

`endif

