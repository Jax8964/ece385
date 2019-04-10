module cpu_memory(
    input logic CLK, RESET
);
    typedef struct packed {logic [3:0] high, low;} test_t;
    test_t state,state_in;
    test_t state_init = {.high(4'b1)} ;

    always_ff @(posedge CLK) begin
        state <= state_init;
    end
endmodule