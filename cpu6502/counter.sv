`ifndef _COUNTER_SV
`define _COUNTER_SV
`include "const.sv"


typedef enum logic [1:0] {counter_run, counter_set, counter_halt, counter_inc1} Counter_operation_t;

module Counter_dec #(parameter N = 8)(
    input logic CLK,
    input Counter_operation_t Counter_operation,
    input logic [N-1:0] init_value,

    output logic [N-1:0] out
);
    logic [N-1:0] step, next;
    always_ff @(posedge CLK) begin
        out <= next;
    end

    always_comb begin
        step = 8'(-1);
        next = out + step;
        case (Counter_operation)
            counter_set : 
                next = init_value;
            counter_halt :
                step = '0;
            counter_inc1 :
                step = `CLOCK_PERIOD-1;
        endcase
    end
    
endmodule

`endif
