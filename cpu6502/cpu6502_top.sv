`include "MUXs.sv"
`include "MemIO.sv"
`include "regs.sv"
`include "ALU.sv"
`include "MUXs.sv"
`include "CONTROL.sv"
`include "const.sv"
`include "../HexDriver.sv"


module cpu6502_top(
    input logic              CLOCK_50, //RESET, NMI,
    input logic [17:0]       SW,
    input logic [3:0]        KEY,

     output logic [6:0]      HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
     output logic [17:0]     LEDR,
     output logic [7:0]      LEDG
);
    logic CLK, RESET, NMI, IRQ, CONTINUE, HALT;      // I/O input
    always_comb begin
        CLK = CLOCK_50;
        RESET = ~KEY[0];	
        NMI = ~KEY[1];
        IRQ = ~KEY[2];
        CONTINUE = ~KEY[3];
    end
    /**************************** regs *******************************/
    logic [15:0]    PC, MAR;        // mem address source
    logic [7:0]     A,              // regs
                    X, 
                    Y, 
                    SR,             // status register
                    SP,             // stack pointer
                    ALUL, ALUH,     // ALU output
                    MDRL, MDRH;     // mem read data

    PC_operation_t      PC_operation;
    A_operation_t   A_operation;
    X_operation_t   X_operation;
    Y_operation_t   Y_operation;
    SP_operation_t  SP_operation;
    SR_operation_t  SR_operation;
    logic N_in, V_in, Z_in, C_in, B_flag;
    logic setN, setV, setZ, setC;

    PC_unit PC_unit0( .*);
    regA regA0(.*);
    regX regX0(.*);
    regY regY0(.*);
    regSP regSP0(.*);
    regSR regSR0(.*);


    MEM_opreation_t     MEM_opreation;
    ST_MUX_t            ST_MUX;
    ADDR_MUX_t          ADDR_MUX;
    logic               MEM_LDMAR;
    logic               page_cross;

    ALU_operation_t     ALU_operation;
    ALU_MUX_t ALU_MUX;

    /*************************** Memory ******************************/
    logic [7:0] mem_data;
    logic [15:0]    addr;
    MemIO MemIO0(.*, .data(mem_data));
    ST_MUX_unit ST_MUX_unit0( .*, .data(mem_data) );      
    ADDR_MUX_unit ADDR_MUX_unit0(.*);           // addr

    /*************************** ALU ******************************/
    logic [7:0]           ALUH0, ALUH1, ALUL0, ALUL1;
    ALU ALU0(.*, .cin(`FLAG_C), .ALUL_out(ALUL), .ALUH_out(ALUH), .ALU_N(N_in), .ALU_V(V_in), .ALU_Z(Z_in), .ALU_C(C_in) );
    ALU_MUX_unit ALU_MUX_unit0(.*);

    /*************************** control ******************************/
    CONTROL_unit CONTROL0(.*, .opcode(MDRL), .page_cross(C_in));



    always_comb begin           // I/O output
        LEDR[15:0] = PC;
	    LEDR[16] = RESET;
    end

    HexDriver HexDriver0(.In0(MDRL[3:0]), .Out0(HEX0));
    HexDriver HexDriver1(.In0(MDRL[7:4]), .Out0(HEX1));
    HexDriver HexDriver2(.In0('0), .Out0(HEX2));
    HexDriver HexDriver3(.In0('0), .Out0(HEX3));
    HexDriver HexDriver4(.In0('0), .Out0(HEX4));
    HexDriver HexDriver5(.In0('0), .Out0(HEX5));
    HexDriver HexDriver6(.In0('0), .Out0(HEX6));
    HexDriver HexDriver7(.In0('0), .Out0(HEX7));

endmodule
