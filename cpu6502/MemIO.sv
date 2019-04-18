`ifndef _MEMIO_SV
`define _MEMIO_SV

typedef enum logic [2:0] {MEM_READ1, MEM_READ2, MEM_WRITE, MEM_KEEP} MEM_opreation_t;

module MemIO(
    input logic CLK, RESET,
    input logic [17:0] SW,      // for test
    input logic [15:0] addr,
    input logic [7:0]  data,
    input MEM_opreation_t MEM_opreation,

    output logic [7:0] MDRL, MDRH
);

    logic w;
    logic [7:0] MDRL_next, MDRH_next, memL, memH;
    cpu_memory cpu_memory0( .CLK(CLK), .w(w), .address(addr), .in(data), .OUTL(memL),.OUTH(memH));    

    always_ff @(posedge CLK) begin
        MDRL <= MDRL_next;
        MDRH <= MDRH_next;
    end
    always_comb begin
        w = 1'b0;
        MDRL_next = MDRL;
        MDRH_next = MDRH;
        case (MEM_opreation)
            MEM_KEEP : ;
            MEM_WRITE : begin
                w = 1'b1;
            end
            MEM_READ1 : begin
                MDRL_next = memL;
            end
            MEM_READ2 : begin
                MDRL_next = addr == 16'hFFFC ? SW[7:0] : memL;
                MDRH_next = addr == 16'hFFFC ? SW[15:8] : memH;
            end
        endcase
    end
    
endmodule

`endif
