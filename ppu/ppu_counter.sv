`ifndef _PPU_COUNTER_SV
`define _PPU_COUNTER_SV

module ppu_counter(
    input logic       CLK, RESET, set, halt,
    input logic [8:0] init, max,

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
    reg [11:0] counter_;
    always_ff @(posedge CLK) begin
        if(reset)
            counter_ <= '0;
        else if (halt)
            counter_ <= counter_;
        else
            counter_ <= (counter_[11:3] == max) ? '0 : (counter_ +12'd1);
    end
    assign counter = counter_;
    
endmodule





`endif
