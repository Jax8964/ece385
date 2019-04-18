`ifndef _PC_SV
`define _PC_SV
typedef enum logic [1:0] {PC_keep, PC_load, PC_inc1, PC_inc2} PC_operation_t;

module PC_unit(
    input logic CLK, RESET,
    input PC_operation_t  PC_operation,
    input logic [15:0] PC_in,

    output logic [15:0] PC_out
);
    logic [15:0] PC_next;
    logic [15:0] PC_incN;
    always_ff @(posedge CLK) begin
        PC_out <= PC_next+PC_incN;
    end
    always_comb begin
        PC_incN = '0;
        PC_next = PC_out;
        unique case (PC_operation)
            PC_keep : ;
            PC_load : begin
                PC_next = PC_in;             
            end
            PC_inc1 : begin
                PC_incN = 16'd1;
            end
            PC_inc2 : begin
                PC_incN = 16'd2;
            end
        endcase
    end
    
endmodule

`endif
