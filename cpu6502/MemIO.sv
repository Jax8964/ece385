`ifndef _MEMIO_SV
`define _MEMIO_SV
`include "cpu_memory.sv"
typedef enum logic [1:0] {
    MEM_KEEP,           // keep MDR
    MEM_READ1,          // M[addr] -> MDRL
    MEM_READ2,          // M[addr+1] -> MDRH
    MEM_WRITE          // data -> M[addr]
} MEM_opreation_t;
/*
 *      deal with MDR
 *
 */
module MemIO(             
    input logic CLK, RESET,
    input logic [17:0] SW,      // for test
    input logic [15:0] addr,
    input logic [7:0]  data,
    input MEM_opreation_t MEM_opreation,
    input logic MEM_LDMAR,      // if 1, store current addr

    output logic [7:0] MDRL, MDRH,
    output logic [15:0] MAR
);

    logic w, r, LD_MAR;
    logic [7:0] MDRL_next, MDRH_next, mem_out, out_ext;
    logic [15:0] real_addr, address_ext;
    cpu_memory cpu_memory0( .*, .address(real_addr), .data(data), .out(mem_out));    

    always_ff @(posedge CLK) begin
        MDRL <= MDRL_next;
        MDRH <= MDRH_next;
        MAR  <= LD_MAR ? addr : MAR;
    end
    always_comb begin
        w = '0;
        r = '0;
        LD_MAR = '0;
        real_addr = addr;
        MDRL_next = MDRL;
        MDRH_next = MDRH;
        case (MEM_opreation)
            MEM_KEEP : ;
            MEM_WRITE : begin
                w = '1;
            end
            MEM_READ1 : begin           // M[addr] -> MDRL
                r = '1;
                MDRL_next = mem_out;
            end
            MEM_READ2 : begin           // M[addr+1] -> MDRH
                r = '1;
                real_addr = addr+1;
                MDRH_next = mem_out;
            end
        endcase
    end
    
endmodule

`endif
