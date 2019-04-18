`ifndef _CONTROL_SV
`define _CONTROL_SV
`include "PC.sv"
`include "cpu_memory.sv"
`include "MemIO.sv"
`include "MUXs.sv"
/*  reset -> fetch -> decode -> execute &  check interrupt -> 
                |____________________________________________|
    NMI：    $FFFA，$FFFB 
    Reset：  $FFFC，$FFFD 
    BRK/IRQ：$FFFE，$FFFF                    
*/
module CONTROL_unit(
    input logic                 CLK, RESET, NMI,
    input logic [7:0]           opcode,        // MDR_curr, actually

    output PC_operation_t       PC_operation,
    output PC_MUX_t             PC_MUX,

    output MEM_opreation_t      MEM_opreation,
    output MEM_MUX_t            MEM_MUX,
    output ADDR_MUX_t           ADDR_MUX
);
    /************************* state enum *****************************/
    typedef enum logic [7:0] {
        reset_0, reset_1, reset_2, reset_3,
        fetch_0, fetch_1,
        decode_0, decode_1,
        counter_,

        read_abs_0, read_abs_1,         // read addressing modes
        read_indir_0, read_indir_1, read_indir_2, read_indir_3,
        jmp_abs_0, jmp_abs_1,
        jmp_indir_0, jmp_indir_1,

        NMI_0, NMI_1

    } state_t;

    state_t state, next_state, init_state, state_restore, state_restore_next;
    logic LD_state_restore;
    always_ff @(posedge CLK) begin
        if(RESET) begin
            state <= reset_0;
            state_restore <= reset_0;
		  end
        else begin
            state <= next_state;
            state_restore <= LD_state_restore ? state_restore_next : state_restore;
		  end
    end
    /***************************** counter and timing ***********************/
    logic [7:0] 		counter, N_circles;	
    logic 				counter_EN, counter_RESET;
    always_ff @(posedge CLK) begin
        counter <= counter_RESET ? N_circles : (counter_EN ? counter-1 : counter);
    end
    opcode_timing opcode_timing0(.CLK(CLK), .in(opcode), .out(N_circles));
    /**************************** decode logic ****************************/
    always_comb begin
        init_state = reset_0;
        state_restore_next = reset_0;
        case(opcode[1:0])
            2'b00 : begin
                case(opcode[7:2])
                    6'b010011: begin
                        init_state = jmp_abs_0;
                    end
                    6'b011011: begin
                        init_state = read_indir_0;
                        state_restore_next = jmp_abs_0;
                    end
                endcase
            end
            2'b01 : begin

            end
            2'b10 : begin

            end    
        endcase
    end
    /**************************************************************/
    always_comb begin
        counter_EN = '1;
        counter_RESET = '0;
        next_state = reset_0;
        LD_state_restore = '0;

        PC_operation = PC_keep;
        PC_MUX = PC_abs;

        MEM_opreation = MEM_KEEP;
        MEM_MUX = ST_ALUL;
        ADDR_MUX = ADDR_PC;

        case(state)
            reset_0: begin
                PC_operation = PC_load;
                PC_MUX = PC_RESET;
                next_state = reset_1;
            end
            reset_1: begin
                ADDR_MUX = ADDR_PC;     // load operator, 2bytes
                MEM_opreation = MEM_READ2;
                next_state = reset_2;
            end
            reset_2: begin      
                PC_MUX = PC_abs; 
                PC_operation = PC_load;
                next_state = fetch_0;
            end

            fetch_0: begin       // M[PC] -> MDR, PC + 1 -> PC
                ADDR_MUX = ADDR_PC;
                MEM_opreation = MEM_READ1;
                PC_operation = PC_inc1;
                next_state = decode_0;
            end
            decode_0: begin       
                ADDR_MUX = ADDR_PC;     // preload operator, operator -> MDR
                MEM_opreation = MEM_READ2;
                counter_RESET = '1;     // set counter
                LD_state_restore = '1;
                next_state = init_state;
            end

            jmp_abs_0: begin      
                PC_MUX = PC_abs; 
                PC_operation = PC_load;
                next_state = counter_;
            end

            read_indir_0: begin       
                ADDR_MUX = ADDR_MDR; 
                MEM_opreation = MEM_READ2;
                next_state = state_restore;
            end

            counter_ : begin
                if(counter == 0) begin
                    next_state = NMI ? NMI_0 : fetch_0;
                end
                else
                    next_state = counter_;
            end
        endcase
    end
    
endmodule

`endif


