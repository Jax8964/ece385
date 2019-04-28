`ifndef _REGS_SV
`define _REGS_SV

/*
 *  some registers.   PC A X Y SP SR
 *
 */
 // PC
 typedef enum logic [2:0] {
    PC_KEEP,       
    PC_LD_ALU, 
    PC_LD_MDR, 
    PC_INC1, 
    PC_INC2
 } PC_operation_t;

 module PC_unit(
    input logic CLK, RESET,
    input PC_operation_t  PC_operation,
    input logic [7:0] ALUH, ALUL, MDRH, MDRL,

    output logic [15:0] PC
 );
    logic [15:0] PC_next;
    logic [15:0] PC_incN;
    always_ff @(posedge CLK) begin
        PC <= PC_next+PC_incN;
    end
    always_comb begin
        PC_incN = '0;
        PC_next = PC;
        case (PC_operation)
            PC_KEEP : ;
            PC_LD_ALU : begin
                PC_next = {ALUH, ALUL};             
            end
            PC_LD_MDR : begin
                PC_next = {MDRH, MDRL};             
            end
            PC_INC1 : begin
                PC_incN = 1;
            end
            PC_INC2 : begin
                PC_incN = 2;
            end
        endcase
    end
endmodule

// A
 typedef enum logic [1:0] {
    A_KEEP, 
    A_LD_ALU, 
    A_LD_MDRH, 
    A_LD_MDRL
 } A_operation_t;

module regA(
    input logic CLK, RESET,
    input logic [7:0] ALUH, ALUL, MDRH, MDRL,
    input A_operation_t A_operation,

    output logic [7:0] A
 );
    logic [7:0] A_next;
    always_ff @(posedge CLK) begin
        if(RESET)
            A <= '0;
        else
            A <= A_next;
    end
    always_comb begin
        A_next = A;
        case (A_operation)
            A_KEEP : ;
            A_LD_ALU : begin
                A_next = ALUL;             
            end
            A_LD_MDRH : begin
                A_next = MDRH;
            end
            A_LD_MDRL : begin
                A_next = MDRL;
            end
        endcase
    end
 endmodule



typedef enum logic [1:0] {
    X_KEEP, 
    X_LD_ALU, 
    X_LD_MDRH, 
    X_LD_MDRL
} X_operation_t;

module regX(
    input logic CLK, RESET,
    input logic [7:0] ALUH, ALUL, MDRH, MDRL,
    input X_operation_t X_operation,

    output logic [7:0] X
 );
    logic [7:0] X_next;
    always_ff @(posedge CLK) begin
        if(RESET)
            X <= '0;
        else
            X <= X_next;
    end
    always_comb begin
        X_next = X;
        case (X_operation)
            X_KEEP : ;
            X_LD_ALU : begin
                X_next = ALUL;             
            end
            X_LD_MDRL : begin
                X_next = MDRL;
            end
            X_LD_MDRH : begin
                X_next = MDRH;
            end
        endcase
    end
endmodule

 typedef enum logic [1:0] {
     Y_KEEP, 
     Y_LD_ALU, 
     Y_LD_MDRH, 
     Y_LD_MDRL
 } Y_operation_t;

 module regY(
    input logic CLK, RESET,
    input logic [7:0] ALUH, ALUL, MDRH, MDRL,
    input Y_operation_t Y_operation,

    output logic [7:0] Y
 );
    logic [7:0] Y_next;
    always_ff @(posedge CLK) begin
        if(RESET)
            Y <= '0;
        else
            Y <= Y_next;
    end
    always_comb begin
        Y_next = Y;
        case (Y_operation)
            Y_KEEP : ;
            Y_LD_ALU : begin
                Y_next = ALUL;             
            end
            Y_LD_MDRL : begin
                Y_next = MDRL;
            end
            Y_LD_MDRH : begin
                Y_next = MDRH;
            end
        endcase
    end
 endmodule


 
// stack from 01FF to 0100
// power up state ? : SP = 0xFD
typedef enum logic [2:0] {
    SP_KEEP, 
    SP_LD_ALU, 
    SP_LD_MDR, 
    SP_DEC1, 
    SP_INC1
 } SP_operation_t;

 module regSP(
    input logic CLK, RESET,
    input logic [7:0] ALUL, MDRL,
    input SP_operation_t SP_operation,

    output logic [7:0] SP
 );
    logic [7:0] SP_next, SP_step;
    always_ff @(posedge CLK) begin
        if(RESET)
            SP <= 8'hFD;
        else
            SP <= SP_next + SP_step;
    end
    always_comb begin
        SP_next = SP;
        SP_step = '0;
        case (SP_operation)
            SP_KEEP : ;
            SP_LD_ALU : begin
                SP_next = ALUL;             
            end
            SP_LD_MDR : begin
                SP_next = MDRL;
            end
            SP_DEC1 : begin
                SP_step = -1;
            end
            SP_INC1 : begin
                SP_step = 1;
            end
        endcase
    end
 endmodule


 /*
    7  bit  0        status register
    ---- ----
    NVss DIZC
    |||| ||||
    |||| |||+- Carry
    |||| ||+-- Zero
    |||| |+--- Interrupt Disable
    |||| +---- Decimal
    ||++------ No CPU effect, see: the B flag
    |+-------- Overflow
    +--------- Negative

    power up state ?
*/
typedef enum logic [3:0] {
        SR_KEEP, 
        SR_LD_ALU, 
        SR_LD_MDRH, 
        SR_LD_MDRL,
        SR_SET,                     // set from ALU flag
        SR_CLC, SR_CLD, SR_CLI, SR_CLV, SR_SEC, SR_SED, SR_SEI,     // clear or set flags
        SR_BIT             
 } SR_operation_t;

 module regSR(
    input logic CLK, RESET,
    input logic [7:0] ALUH, ALUL, MDRH, MDRL,
    input logic N_in, V_in, Z_in, C_in,         // from ALU
                B_flag,                         // B_flag is special
    input logic setN, setV, setZ, setC,         // set which flag (from ALU)
    input SR_operation_t SR_operation,

    output logic [7:0] SR
 );
    logic [7:0] SR_reg, SR_next, SR_new, SR_set_mask, SR_setted;
    always_ff @(posedge CLK) begin
        if(RESET)
            SR_reg <= '0;
        else
            SR_reg <= SR_next;
    end
    always_comb begin
        SR_new = {N_in, V_in, SR_reg[5:2], Z_in, C_in};
        SR_set_mask = {setN, setV, 4'b0, setZ, setC};
        SR_setted = (~SR_set_mask)&SR_reg | SR_set_mask&SR_new;
        SR_next = SR_reg;
        SR = {SR_reg[7:6], 1'b0, B_flag, SR_reg[3:0]};
        case (SR_operation)
            SR_KEEP : ;
            SR_LD_ALU : begin
                SR_next = ALUL;             
            end
            SR_LD_MDRH : begin
                SR_next = MDRH;
            end
            SR_LD_MDRL : begin
                SR_next = MDRL;
            end
            SR_CLC :
                SR_next = {SR_reg[7:1],1'b0};
            SR_CLD :
                SR_next = {SR_reg[7:4],1'b0,SR_reg[2:0]};
            SR_CLI :
                SR_next = {SR_reg[7:3],1'b0,SR_reg[1:0]};
            SR_CLV :
                SR_next = {SR_reg[7],1'b0,SR_reg[5:0]};
            SR_SEC :
                SR_next = {SR_reg[7:1],1'b1};
            SR_SED :
                SR_next = {SR_reg[7:4],1'b1,SR_reg[2:0]};
            SR_SEI :
                SR_next = {SR_reg[7:3],1'b1,SR_reg[1:0]};
            SR_SET :
                SR_next = SR_setted;
            SR_BIT :
                SR_next = {MDRL[7:6], SR_reg[5:2], Z_in, SR_reg[0]};
        endcase
    end
 endmodule


 `endif
