/********************* ALU_MUX *****************************/
typedef enum logic [2:0] {
    ALU_MA     // memory and A
    


} ALU_MUX_t;

module ALU_MUX_unit(            // ALU input
    input ALU_MUX_t             ALU_MUX,            // select input of ALU

    input logic [7:0]           MDR_prev, MDR_curr, A, X, Y,
    output logic [7:0]          ALUH0, ALUH1, ALUL0, ALUL1
);


    always_comb begin
        ALUH0 = 8'b0;
        ALUH1 = 8'b0;
        ALUL0 = 8'b0;
        ALUL1 = 8'b0;
        case(ALU_MUX)
            ALU_MA: begin
                ALUL0 = MDR_curr;
                ALUL1 = A;
            end


        endcase
    end
        
endmodule
/********************* PC_MUX *****************************/
typedef enum logic [2:0] {      // PC input
    PC_RESET,    
    PC_NMI,
    PC_BRK,
    PC_abs          // absolute addressing
} PC_MUX_t;

module PC_MUX_unit(
    input PC_MUX_t              PC_MUX,            // select input of ALU
    input logic [7:0]           MDRL, MDRH, ALUL, ALUH, A, X, Y,

    output logic [15:0]         PC_in
);
    always_comb begin
        PC_in = '0;
        case(PC_MUX)
            PC_RESET: begin
                PC_in = 16'hFFFC;
            end
            PC_NMI: begin
                PC_in = 16'hFFFA;
            end
            PC_BRK: begin
                PC_in = 16'hFFFE;
            end
            PC_abs: begin
                PC_in = {MDRH,MDRL};
            end
        endcase
    end
        
endmodule

/********************* ADDR_MUX *****************************/
typedef enum logic [2:0] {      // address input
    ADDR_PC,
    ADDR_MDR

} ADDR_MUX_t;

module ADDR_MUX_unit(
    input ADDR_MUX_t            ADDR_MUX,            // select address

    input logic [7:0]           MDRL, MDRH, ALUL, ALUH, A, X, Y,
    input logic [15:0]          PC,

    output logic                addr
);

    always_comb begin
        addr = PC;
        case(ADDR_MUX)
            ADDR_PC : 
                addr = PC;
            ADDR_MDR :
                addr = {MDRH,MDRL};
        endcase
    end
        
endmodule


/********************* MEM_MUX *****************************/
typedef enum logic [2:0] {
    ST_ALUL,        
    ST_ALUH        
} MEM_MUX_t;

module MEM_MUX_unit(                // memory store data input
    input MEM_MUX_t             MEM_MUX,          
    input logic [7:0]           ALUL, ALUH,

    output logic [7:0]          data
);

    always_comb begin
        data = 8'b0;
        case(MEM_MUX)
            ST_ALUL: 
                data = ALUL;
            ST_ALUH:
                data = ALUH;
        endcase
    end
        
endmodule
