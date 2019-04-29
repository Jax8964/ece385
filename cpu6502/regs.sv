`ifndef _REGS_SV
`define _REGS_SV
/*  https://wiki.nesdev.com/w/index.php/CPU_power_up_state
    P = $34[1] (IRQ disabled)[2]
    A, X, Y = 0
    S = $FD
    $4017 = $00 (frame irq enabled)
    $4015 = $00 (all channels disabled)
*/
/*
 *  some registers.   PC A X Y SP SR
 *
 */
 // PC
 typedef enum logic [1:0] {
    PC_KEEP,       
    PC_LD,          // load from ALU
    PC_INC1,         // PC++
    PC_DEC1
 } PC_operation_t;

 module PC_unit(
    input logic CLK, RESET,
    input PC_operation_t  PC_operation,
    input logic [7:0] ALUH, ALUL,

    output logic [15:0] PC
 );
    logic [15:0] PC_next;
    always_ff @(posedge CLK) begin
        PC <= PC_next;
    end
    always_comb begin
        PC_next = PC;
        case (PC_operation)
            PC_KEEP : ;
            PC_LD : begin
                PC_next = {ALUH, ALUL};             
            end
            PC_INC1 : begin
                PC_next = 16'(PC+1);
            end
            PC_DEC1 : begin
                PC_next = 16'(PC-1);
            end
            default: ;
        endcase
    end
endmodule

// A
module regA(
    input logic CLK, RESET, A_LD,       // load A from ALUL
    input logic [7:0] ALUL,
    output logic [7:0] A
 );
    always_ff @(posedge CLK) begin
        if(RESET)
            A <= '0;
        else
            A <= A_LD ? ALUL : A;
    end
 endmodule


// X
module regX(
    input logic CLK, RESET, X_LD,       // load X from ALUL
    input logic [7:0] ALUL,
    output logic [7:0] X
 );
    always_ff @(posedge CLK) begin
        if(RESET)
            X <= '0;
        else
            X <= X_LD ? ALUL : X;
    end
 endmodule

//Y
module regY(
    input logic CLK, RESET, Y_LD,       // load Y from ALUL
    input logic [7:0] ALUL,
    output logic [7:0] Y
 );
    always_ff @(posedge CLK) begin
        if(RESET)
            Y <= '0;
        else
            Y <= Y_LD ? ALUL : Y;
    end
 endmodule

 
// stack from 01FF to 0100
// power up state ? : SP = 0xFD
typedef enum logic [1:0] {
    SP_KEEP, 
    SP_LD, 
    SP_DEC1, 
    SP_INC1
 } SP_operation_t;

 module regSP(
    input logic CLK, RESET,
    input logic [7:0] ALUL,
    input SP_operation_t SP_operation,

    output logic [7:0] SP
 );
    logic [7:0] SP_next;
    always_ff @(posedge CLK) begin
        if(RESET)
            SP <= 8'hFD;
        else
            SP <= SP_next;
    end
    always_comb begin
        SP_next = SP;
        case (SP_operation)
            SP_KEEP : ;
            SP_LD : begin
                SP_next = ALUL;             
            end
            SP_DEC1 : begin
                SP_next = 8'(SP-1);
            end
            SP_INC1 : begin
                SP_next = 8'(SP+1);
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
        SR_LD,
        SR_SET,                     // set from ALU flag
        SR_CLC, SR_CLD, SR_CLI, SR_CLV, SR_SEC, SR_SED, SR_SEI,     // clear or set flags
        SR_BIT             
 } SR_operation_t;

 module regSR(
    input logic CLK, RESET,
    input logic [7:0] ALUL, MDRL,
    input logic N_in, V_in, Z_in, C_in,         // from ALU
                B_flag,                         // B_flag is special
    input logic setN, setV, setZ, setC,         // set which flag (from ALU)
    input SR_operation_t SR_operation,

    output logic [7:0] SR
 );
    logic [7:0] SR_reg, SR_next, SR_new, SR_set_mask, SR_setted;
    always_ff @(posedge CLK) begin
        if(RESET)
            SR_reg <= 8'h24;
        else
            SR_reg <= SR_next;
    end
    always_comb begin
        SR_new = {N_in, V_in, SR_reg[5:2], Z_in, C_in};
        SR_set_mask = {setN, setV, 4'b0, setZ, setC};
        SR_setted = (~SR_set_mask)&SR_reg | SR_set_mask&SR_new;
        SR_next = SR_reg;
        SR = {SR_reg[7:6], 1'b1, B_flag, SR_reg[3:0]};
        case (SR_operation)
            SR_KEEP : ;
            SR_LD : begin
                SR_next = ALUL;             
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
