
import opcodes::*;
/*  reset -> fetch -> decode -> execute &  check interrupt -> 
                |____________________________________________|
    NMI：    $FFFA，$FFFB 
    Reset：  $FFFC，$FFFD 
    BRK/IRQ：$FFFE，$FFFF                    
*/
module DECODE(
    input logic                  CLK, RESET, NMI,
    input logic [7:0]            opcode,        // MDR_curr, actually

    output ALU_operation_t      ALU_operation,
    output PC_operation_t       PC_operation,
    output mem_mode_t           mem_mode,

    output ADDR_MUX_t           ADDR_MUX;  
    

);
    /************************* state enum *****************************/
    typedef enum logic [7:0] {
        reset_,
        fetch_0, fetch_1,
        decode_0, decode_1,
        jmp_abs_0, jmp_abs_1,



    } state_t;

    state_t state, next_state, init_state;
    always_ff @(posedge CLK) begin
        if(RESET)
            state <= reset_;
        else
            state <= next_state;
    end
    /***************************** counter ***********************/
    logic [7:0] 		counter, N_circles;	
    logic 				counter_EN, counter_RESET;
    always_ff @(posedge CLK) begin
        counter <= counter_RESET ? N_circles : (counter_EN ? counter-1 : counter);
    end
    opcode_timing opcode_timing0(.CLK(CLK), .in(opcode), .out(N_circles));
    /**************************** initial state ****************************/
    function state_t get_init_state(input logic [7:0] opcode);
        case(opcode[1:0])
            2'b00 : begin

            end
            2'b01 : begin

            end
            2'b10 : begin

            end    
        endcase
    endfunction
    assign init_state = get_init_state(opcode);
    /**************************************************************/
    always_comb begin
        counter_EN = '1;
        counter_RESET = '0;

        ADDR_MUX = ADDR_PC;

        PC_operation = PC_keep;
        mem_mode = MEM_KEEP;        


        case(state)
            reset_: begin
            end
            fetch_0: begin       // M[PC] -> MDR, PC + 1 -> PC
                ADDR_MUX = ADDR_PC;
                mem_mode = MEM_READ;
                PC_operation = PC_inc1;
                next_state = decode_0;
            end
            decode_0: begin       
                ADDR_MUX = ADDR_PC;     // preload operator, operator -> MDRL
                mem_mode = MEM_READ;
                counter_RESET = '1;     // set counter
                next_state = init_state;
            end

            jmp_abs_0: begin       
                ADDR_MUX = ADDR_PC;     // load 2 bytes operator
                mem_mode = MEM_READNEXT;

                PC_operation = PC_inc2;
                next_state = init_state;
            end

    end
    
endmodule




