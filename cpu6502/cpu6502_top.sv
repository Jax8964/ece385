module cpu6502_top(
    input logic             CLK, RESET, NMI,
    input logic [17:0]      SW,
    input logic [3:0]       KEY,

    output logic [6:0]      HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output logic [17:0]     LEDR,
    output logic [7:0]      LEDG
);

    logic [15:0]    PC;
    logic [7:0]     A, A_next, 
                    X, X_next, 
                    Y, Y_next, 
                    SR, SR_next, 
                    SP, SP_next,
                    ALUL, ALUH,     // ALU output
                    MDRL, MDRH;

    PC_operation_t      PC_operation;
    PC_MUX_t            PC_MUX;

    MEM_opreation_t     MEM_opreation;
    MEM_MUX_t           MEM_MUX;
    ADDR_MUX_t          ADDR_MUX;

    always_ff @(posedge CLK) begin
        A <= A_next;
        X <= X_next;
        Y <= Y_next;
        SR <= SR_next;
        SP <= SP_next;
    end


    /*************************** PC ******************************/
    logic [15:0] PC_in;
    PC_unit PC_unit0( .*, .PC_out(PC));
    PC_MUX_unit PC_MUX_unit0(.*);

    /*************************** Memory ******************************/
    logic [7:0] mem_data;
    logic [15:0]    addr;
    MemIO MemIO0(.*, .SW(SW), .addr(addr), .data(mem_data), );
    MEM_MUX_unit MEM_MUX_unit0( .*, .data(mem_data) );      
    ADDR_MUX_unit ADDR_MUX_unit0(.*);           // addr



    /*************************** control ******************************/
    CONTROL_unit CONTROL0(.*, .opcode(MDRL));

endmodule
