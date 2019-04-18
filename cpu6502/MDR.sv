typedef enum logic [2:0] {MEM_READ, MEM_READNEXT, MEM_WRITE, MEM_KEEP} mem_mode_t;

module MDR(
    input logic CLK, RESET,
    input logic [15:0] addr,
    input logic [7:0]  data,
    input mem_mode_t mem_mode,

    output logic [7:0] MDR_prev, MDR_curr
);

    logic w, r;
    logic [15:0] real_addr;
    logic [7:0] MDR_prev_next;
    cpu_memory cpu_memory0( .CLK(CLK), .w(w), .r(r), .address(real_addr), .in(data), .out(MDR_curr));    

    always_ff @(posedge CLK) begin
        MDR_prev <= MDR_prev_next;
    end
    always_comb begin
        w = 1'b0;
        r = 1'b0;
        real_addr = addr;
        MDR_prev_next = MDR_prev;
        case (mem_mode)
            MEM_KEEP : ;
            MEM_WRITE : begin
                w = 1'b1;
            end
            MEM_READ : begin
                r = 1'b1;
            end
            MEM_READNEXT : begin
                r = 1'b1;
                real_addr = addr+1;
                MDR_prev_next = MDR_curr;
            end
        endcase
    end
    
endmodule