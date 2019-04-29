`ifndef _CPU_6502_SV
`define _CPU_6502_SV

`include "MemIO.sv"
`include "cpu_memory.sv"
`include "GAMEPAD.sv"
`include "regs.sv"
`include "ALU.sv"
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

    state_t out_state;
    integer data_wr0;
    // synthesis translate_off
    initial begin
        data_wr0 = $fopen("H:/fpgaNES/NES/cpu6502/test_result.txt","w");
    end
    always  @(posedge (out_state == counter_1))begin
            $fwrite(data_wr0,"%4h\t%P\tA:%2X X:%2X Y:%2X P:%2X SP:%2X\n", PC, CONTROL0.exe_state, A, X, Y, SR, SP );
    end
    // synthesis translate_on
    always_comb begin
        CLK = CLOCK_50;
    end
    always_ff @(posedge CLK) begin
        RESET <= ~KEY[0];	
        NMI <= ~KEY[1];
        IRQ <= ~KEY[2];
        CONTINUE <= ~KEY[3];
        HALT <= SW[17];        
    end
    /**************************** regs *******************************/
    logic [15:0]    PC, MAR;        // mem address source
    logic [7:0]     A,              // regs
                    X, 
                    Y, 
                    SR,             // status register
                    SP,             // stack pointer
                    ALUL, ALUH,     // ALU output
                    MDRL, MDRH;     // mem readed data

    PC_operation_t      PC_operation;
    logic               A_LD;
    logic               X_LD;
    logic               Y_LD;
    SP_operation_t      SP_operation;
    SR_operation_t      SR_operation;

    logic N_in, V_in, Z_in, C_in, B_flag;
    logic setN, setV, setZ, setC;

    PC_unit PC_unit0( .*);
    regA regA0(.*);
    regX regX0(.*);
    regY regY0(.*);
    regSP regSP0(.*);
    regSR regSR0(.*);


    ADDR_MUX_t          ADDR_MUX;
    logic               MEM_LDMAR, MEM_LDMDRH, MEM_LDMDRL;
    logic               MEMIO_W, MEMIO_R;

    ALU_operation_t     ALU_operation;
    ALU_MUX_t           ALU_MUX;


    /*************************** Memory ******************************/
    logic [15:0] addr, address_ext;
    logic [7:0]  mem_data, gamepad_data, ppu_reg_data, mem_data_ext;
    logic        mem_w, mem_r, gamepad_w, gamepad_r, ppu_reg_w, ppu_reg_r;
    MemIO MemIO0(.*, 
                 .w(MEMIO_W),
                 .r(MEMIO_R)
        );
    ADDR_MUX_unit ADDR_MUX_unit0(.*);           // addr
    cpu_memory cpu_memory0(.*, .w(mem_w), .r(mem_r), .address(addr), .data(ALUL), .out(mem_data), .out_ext(mem_data_ext));
    GAMEPAD GAMEPAD0(.*, .w(gamepad_w), .r(gamepad_r), .address(addr), .data(ALUL), .out(gamepad_data));


    /*************************** ALU ******************************/
    logic [7:0]           ALUH0, ALUH1, ALUL0, ALUL1;
    ALU ALU0(.*, .cin(`FLAG_C), 
             .ALUL_out(ALUL), .ALUH_out(ALUH), 
             .ALU_N(N_in), .ALU_V(V_in), .ALU_Z(Z_in), .ALU_C(C_in) 
    );
    ALU_MUX_unit ALU_MUX_unit0(.*);

    /*************************** control ******************************/
    CONTROL_unit CONTROL0(.*, .opcode(MDRL), .page_cross(C_in));



    always_comb begin           // I/O output
        address_ext = SW[15:0];
        LEDR[15:0] = PC;
	    LEDR[16] = RESET;
    end

    HexDriver HexDriver0(.In0(PC[3:0]), .Out0(HEX0));
    HexDriver HexDriver1(.In0(PC[7:4]), .Out0(HEX1));
    HexDriver HexDriver2(.In0(PC[11:8]), .Out0(HEX2));
    HexDriver HexDriver3(.In0(PC[15:12]), .Out0(HEX3));
    HexDriver HexDriver4(.In0('0), .Out0(HEX4));
    HexDriver HexDriver5(.In0('0), .Out0(HEX5));
    HexDriver HexDriver6(.In0(mem_data_ext[3:0]), .Out0(HEX6));
    HexDriver HexDriver7(.In0(mem_data_ext[7:4]), .Out0(HEX7));

endmodule

`endif
