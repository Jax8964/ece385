`ifndef _PPU_COUNTER_SV
`define _PPU_COUNTER_SV

module ppu_counter(
    input logic       CLK, RESET, set, 
    input logic [8:0] init,

    output logic [11:0] counter

);
    reg [11:0] counter_;
    always_ff @(posedge CLK) begin
        if(RESET)
            counter_ <= '0;
        if (set)
            counter_ <= {init, 3'b0};
        else
            counter_ <= counter_ +12'd1;
    end
    assign counter = counter_;
    
endmodule


module ppu_counter1(
    input logic       CLK, reset, halt,
    input logic [8:0] max, 

    output logic [11:0] counter

);
    logic [11:0] counter_next;
    logic [8:0]  max_store;
    always_ff @(posedge CLK) begin
        if (reset) begin
            counter <= '0;
            max_store <= max;
        end
        else 
            counter <= counter_next;
    end
    always_comb begin
        case( {halt, (counter[11:3] == max)} )
            2'b10:  counter_next = counter;
            2'b01:  counter_next = '0;
            default : counter_next = counter + 12'd1;
        endcase
    end
    
endmodule





`endif
