`ifndef _MUXS_SV
`define _MUXS_SV

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


/********************* ADDR_MUX *****************************/
typedef enum logic [3:0] {      // address source
    ADDR_PC,
    ADDR_MDR,
    ADDR_MDRL,
    ADDR_ALU,
    ADDR_ALUL,
    ADDR_SP,
    ADDR_MAR,

    ADDR_RESET,    
    ADDR_NMI,
    ADDR_BRK

} ADDR_MUX_t;

module ADDR_MUX_unit(
    input ADDR_MUX_t            ADDR_MUX,            // select address
    input logic [7:0]           MDRL, MDRH, ALUL, ALUH, SP,
    input logic [15:0]          PC, MAR,

    output logic [15:0]         addr
);
    always_comb begin
        addr = PC;
        case(ADDR_MUX)
            ADDR_PC : 
                addr = PC;
            ADDR_MAR : 
                addr = MAR;
            ADDR_MDR :
                addr = {MDRH,MDRL};
            ADDR_MDRL :
                addr = {8'b0,MDRL};
            ADDR_ALU : 
                addr = {ALUH, ALUL};
            ADDR_ALUL : 
                addr = {8'b0, ALUL};
            ADDR_SP : 
                addr = {8'b01, SP};
            ADDR_RESET :
                addr = 16'hFFFC;
            ADDR_NMI :
                addr = 16'hFFFA;
            ADDR_BRK :
                addr = 16'hFFFE;
        endcase
    end
endmodule


/********************* ST_MUX *****************************/
typedef enum logic [2:0] {
    ST_ALUL,        
    ST_ALUH,
    ST_A,
    ST_X,
    ST_Y,
    ST_SR,
    ST_PCL,
    ST_PCH        
} ST_MUX_t;

module ST_MUX_unit(                // memory store data input
    input ST_MUX_t              ST_MUX,          
    input logic [7:0]           ALUL, ALUH, A, X, Y, SR,
    input logic [15:0]          PC,

    output logic [7:0]          data
);
    always_comb begin
        data = 8'b0;
        case(ST_MUX)
            ST_ALUL: 
                data = ALUL;
            ST_ALUH:
                data = ALUH;
            ST_A:
                data = A;
            ST_X:
                data = X;       
            ST_Y:
                data = Y;  
            ST_SR:
                data = SR;
            ST_PCL:
                data = PC[7:0];  
            ST_PCH:
                data = PC[15:8];           
        endcase
    end
endmodule

`endif
