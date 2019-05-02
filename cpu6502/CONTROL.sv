`ifndef _CONTROL_SV
`define _CONTROL_SV
`include "MemIO.sv"
`include "opcode_decode.sv"
`include "counter.sv"
`include "regs.sv"
`include "ALU.sv"
`include "const.sv"

/*  reset -> fetch -> decode -> execute &  check interrupt -> 
                |____________________________________________|
    NMI：    $FFFA，$FFFB 
    Reset：  $FFFC，$FFFD 
    BRK/IRQ：$FFFE，$FFFF                    
*/
module CONTROL_unit(
    input logic                 CLK, RESET, NMI, IRQ, HALT,
                                CONTINUE,  // for test, KEY[3]
    input logic [7:0]           opcode,        // MDRL, actually
                                SR,         // status register
    input logic                 page_cross,    // delay when page_cross occurs

    output PC_operation_t       PC_operation,
    output logic                A_LD, X_LD, Y_LD,
    output SP_operation_t       SP_operation,
    output SR_operation_t       SR_operation,
    output logic                B_flag, setN, setV, setZ, setC,

    output ADDR_MUX_t           ADDR_MUX,
    output logic                MEM_LDMAR, MEM_LDMDRH, MEM_LDMDRL, 
                                MEMIO_W, MEMIO_R,

    output ALU_MUX_t            ALU_MUX,
    output ALU_operation_t      ALU_operation,

    output state_t                out_state
);
    logic NMI_restore, NMI_clear;
    always_ff @(posedge CLK) begin
        if(NMI_clear)
            NMI_restore <= '0;
        else if(NMI)
            NMI_restore <= '1;
        else    
            NMI_restore <= NMI_restore;
    end
    /************************* state  *****************************/
    state_t state, next_state, addr_state, exe_state, exe_state_next;
    logic [7:0] decode_info, decode_info_next;
    logic LD_decode_info;
    always_ff @(posedge CLK) begin
        state       <= RESET          ? reset_0          : next_state;
        exe_state   <= LD_decode_info ? exe_state_next   : exe_state;
        decode_info <= LD_decode_info ? decode_info_next : decode_info;
    end
    /***************************** counter and timing ***********************/
    Counter_operation_t Counter_operation;
    logic [7:0] counter_init, counter_out;
    opcode_timing opcode_timing0(.CLK(CLK), .in(opcode), .out(counter_init));
    Counter_dec Counter_dec0(.*, .init_value(counter_init), .out(counter_out));

    /**************************** decode  ****************************/
    logic [7:0] addr_temp, exe_temp;
    opcode_addr_state opcode_addr_state0(.CLK(CLK), .in(opcode), .out(addr_temp));
    opcode_exe_state  opcode_exe_state0 (.CLK(CLK), .in(opcode), .out(exe_temp));
    opcode_info       opcode_info0(.CLK(CLK), .in(opcode), .out(decode_info_next));
    logic page_cross_en, mem_read_en;
    always_comb begin
        page_cross_en  = decode_info[0];
        mem_read_en    = decode_info[1];
        addr_state     = state_t'(addr_temp);
        exe_state_next = state_t'(exe_temp);
    end
    /**************************************************************/
    always_comb begin
        out_state = state;
        Counter_operation = counter_run;
        NMI_clear = '0;

        LD_decode_info = '0;
        next_state = fetch_;
        
        ADDR_MUX   = ADDR_PC;
        MEM_LDMAR  = 0;
        MEM_LDMDRH = 0;
        MEM_LDMDRL = 0;
        MEMIO_W    = 0;
        MEMIO_R    = 0;

        ALU_MUX = ALU_INCM;
        ALU_operation = ALU_PASS0;      // default: ALUL = MDRL, ALUH = MDRH
        // regs
        PC_operation = PC_KEEP;         // keep PC
        A_LD = 0;
        X_LD = 0;
        Y_LD = 0;
        SP_operation = SP_KEEP;
        SR_operation = SR_KEEP;
        B_flag = '0;
        setN = '0;
        setV = '0;
        setZ = '0;
        setC = '0;
`define MEM_GET1  MEMIO_R = 1;  MEM_LDMDRL = 1; MEM_LDMAR = 1;
`define MEM_GET2  ADDR_MUX = ADDR_MAR1;  MEMIO_R = 1;  MEM_LDMDRH = 1;
`define ALU_PASS_MDR  ALU_MUX = ALU_INCM;  ALU_operation = ALU_PASS0;
`define ALU_PASS_A  ALU_MUX = ALU_AM;  ALU_operation = ALU_PASS0;
`define ALU_PASS_X  ALU_MUX = ALU_XM;  ALU_operation = ALU_PASS0;
`define ALU_PASS_Y  ALU_MUX = ALU_YM;  ALU_operation = ALU_PASS0;
`define ALU_PASS_PCL  ALU_MUX = ALU_PCM;  ALU_operation = ALU_PASS0;
`define ALU_PASS_PCH  ALU_MUX = ALU_PCM;  ALU_operation = ALU_PASS0H;
`define ALU_PASS_SR   ALU_MUX = ALU_INCY;  ALU_operation = ALU_PASS0H;
`define ALU_PASS_SP   ALU_MUX = ALU_INCX;  ALU_operation = ALU_PASS0H;
`define MEM_FETCH1  ADDR_MUX   = ADDR_PC; MEMIO_R = 1;  MEM_LDMDRL = 1; MEM_LDMAR = 1; PC_operation = PC_INC1;
`define MEM_FETCH2  ADDR_MUX = ADDR_MAR1;  MEMIO_R = 1;  MEM_LDMDRH = 1; PC_operation = PC_INC1;
`define ADDR_PRE_READ  MEM_LDMAR = 1; MEMIO_R = mem_read_en; MEM_LDMDRL =  mem_read_en;
`define SET_NZ    setN = 1; setZ = 1; SR_operation = SR_SET;
`define SET_NZCV    setN = 1; setZ = 1;setC = 1; setV = 1; SR_operation = SR_SET;
`define SET_NZC    setN = 1; setZ = 1;setC = 1; SR_operation = SR_SET;
`define SET_ZC     setZ = 1;setC = 1; SR_operation = SR_SET;
`define STORE_MAR  ADDR_MUX = ADDR_MAR; MEMIO_W = 1;        // store ALUL to MAR
`define STACK_PUSH  ADDR_MUX = ADDR_SP; MEMIO_W = 1; SP_operation = SP_DEC1;       // store ALUL to SP
`define STACK_PULL1 ADDR_MUX = ADDR_SP1; `MEM_GET1 SP_operation = SP_INC1;
`define STACK_PULL2  `MEM_GET2  SP_operation = SP_INC1;
        case(state)
            reset_0: begin          
                ADDR_MUX = ADDR_RESET;     // read M[16'hFFFC]
                `MEM_GET1
                next_state = reset_1;
            end
            reset_1: begin          
                `MEM_GET2
                next_state = reset_2;
            end
            reset_2: begin          
                `ALU_PASS_MDR
                PC_operation = PC_LD;      // load PC from ALU
                next_state = fetch_;        // start first instruction
            end
// M[PC] -> MDR, PC + 1 -> PC
            fetch_: begin       
                `MEM_FETCH1
                next_state = decode_;
            end
            decode_: begin      
                LD_decode_info = '1;                 // get address state, exe state
                Counter_operation = counter_set;     // set counter
                next_state = addr_state;
            end
// no mem operand
            addr_none:           
                next_state = exe_state;
// operand 2 bytes is addr 
            addr_abs: begin      
                `MEM_FETCH1
                next_state = addr_abs1;
            end      
            addr_abs1: begin        // load operand
                `MEM_FETCH2
                next_state = addr_abs2;
            end   
            addr_abs2: begin     
                ADDR_MUX = ADDR_MDR;  
                MEM_LDMAR = 1;
                next_state = addr_abs3;
            end   
            addr_abs3: begin     
                ADDR_MUX = ADDR_MAR;  
                MEMIO_R = mem_read_en; MEM_LDMDRL =  mem_read_en;
                next_state = exe_state;
            end   
// operand[1:0] + unsigned X  is addr 
            addr_absX: begin       
                `MEM_FETCH1
                next_state = addr_absX1;
            end      
            addr_absX1: begin        // load operand
                `MEM_FETCH2
                next_state = addr_absX2;
            end   
            addr_absX2: begin       // load data (1 byte)
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALU;
                `ADDR_PRE_READ
                next_state = exe_state;
            end    
// operand[1:0] + unsigned Y  is addr 
            addr_absY: begin       
                `MEM_FETCH1
                next_state = addr_absY1;
            end      
            addr_absY1: begin        // load operand
                `MEM_FETCH2
                next_state = addr_absY2;
            end   
            addr_absY2: begin       // load data (1 byte)
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALU;
                `ADDR_PRE_READ
                next_state = exe_state;
            end        
// operand 1 byte is signed offset of PC
            addr_relative: begin     // don't increase PC here,  for branch only
                `MEM_FETCH1
                next_state = exe_state;
            end     
// operand 1 byte is data
            addr_immed: begin     
                `MEM_FETCH1
                next_state = exe_state;
            end
// operand 2 bytes is addr of addr
            addr_indir: begin          
                `MEM_FETCH1
                next_state = addr_indir1;
            end
            addr_indir1: begin          
                `MEM_FETCH2
                next_state = addr_indir2;
            end
            addr_indir2: begin          
                ADDR_MUX = ADDR_MDR;
                `MEM_GET1
                next_state = addr_indir3;
            end
            addr_indir3: begin          //TODO: now all indirect will in same bank
                //`MEM_GET2
                ADDR_MUX = ADDR_MARL1;  
                MEMIO_R = 1;  
                MEM_LDMDRH = 1;
                next_state = addr_indir4;
            end
            addr_indir4: begin       // load data (1 byte)
                ADDR_MUX = ADDR_MDR;
                `ADDR_PRE_READ
                next_state = exe_state;
            end  
// 1 byte, (X+operand) mod 256 is addr of addr
            addr_indexX: begin       // PC+1 -> PC
                `MEM_FETCH1
                next_state = addr_indexX1;
            end      
            addr_indexX1: begin        // (X+operand) mod 256
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                `MEM_GET1
                next_state = addr_indexX2;
            end   
            addr_indexX2: begin        // (X+operand) mod 256
                ADDR_MUX = ADDR_MARL1;  
                MEMIO_R = 1;  
                MEM_LDMDRH = 1;
                next_state = addr_indir4;
            end 
//1, M[operand] + Y mod 256 is addr
            addr_indexY: begin       // PC+1 -> PC  M[operand]
                `MEM_FETCH1
                next_state = addr_indexY1;
            end      
            addr_indexY1: begin        // M[operand]
                ADDR_MUX = ADDR_MDRL;
                `MEM_GET1
                next_state = addr_indexY2;
            end   
            addr_indexY2: begin        // M[operand+1 mod 256]
                ADDR_MUX = ADDR_MARL1;  
                MEMIO_R = 1;  
                MEM_LDMDRH = 1;
                next_state = addr_indexY3;
            end 
            addr_indexY3: begin        //  + Y 
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALU;
                `ADDR_PRE_READ
                next_state = exe_state;
            end   
//1 byte operand is addr
            addr_zero: begin       // PC+1 -> PC
                `MEM_FETCH1
                next_state = addr_zero1;
            end 
            addr_zero1: begin       // PC+1 -> PC
                ADDR_MUX = ADDR_MDRL;
                `ADDR_PRE_READ
                next_state = exe_state;
            end 
//1 byte operand + X is addr
            addr_zeroX: begin       // PC+1 -> PC
                `MEM_FETCH1
                next_state = addr_zeroX1;
            end 
            addr_zeroX1: begin       // (X+operand) mod 256
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                `ADDR_PRE_READ
                next_state = exe_state;
            end 
//1 byte operand + Y is addr
            addr_zeroY: begin       // PC+1 -> PC
                `MEM_FETCH1
                next_state = addr_zeroY1;
            end 
            addr_zeroY1: begin       // (Y+operand) mod 256
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                `ADDR_PRE_READ
                next_state = exe_state;
            end 
//////////////////////////////////////////////////////////////////
// opcode set 01, mainly about A
// A or M -> A          NZ
            op_ORA_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_OR;
                A_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
// A & M -> A            set NZ
            op_AND_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_AND;
                A_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
// A XOR M -> A
            op_EOR_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_XOR;
                A_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
// A + M + C -> A, C            set NZCV
            op_ADC_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_ADC;
                A_LD = 1;
                `SET_NZCV
                next_state = counter_;
            end
// A - M,           NZC
            op_CMP_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_SUB;
                `SET_NZC
                next_state = counter_;
            end
            op_SBC_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_SUBC;
                A_LD = 1;
                `SET_NZCV
                next_state = counter_;
            end
// M --
            op_DEC_: begin
                ALU_MUX = ALU_INCM;
                ALU_operation = ALU_SUB;
                `STORE_MAR   
                `SET_NZ
                next_state = counter_;
            end  
// M ++ 
            op_INC_: begin
                ALU_MUX = ALU_INCM;
                ALU_operation = ALU_ADD16;
                `STORE_MAR   
                `SET_NZ
                next_state = counter_;
            end   

           op_INY_: begin
                ALU_MUX = ALU_INCY;
                ALU_operation = ALU_ADD16;
                Y_LD = 1;
                `SET_NZ
                next_state = counter_;                   
            end
            op_INX_: begin
                ALU_MUX = ALU_INCX;
                ALU_operation = ALU_ADD16;
                X_LD = 1;
                `SET_NZ
                next_state = counter_;  
            end
            op_DEY_: begin                      // Y-1 -> Y
                ALU_MUX = ALU_INCY;
                ALU_operation = ALU_SUB;
                Y_LD = 1;
                `SET_NZ
                next_state = counter_;                
            end
            op_DEX_: begin
                ALU_MUX = ALU_INCX;
                ALU_operation = ALU_SUB;
                X_LD = 1;
                `SET_NZ
                next_state = counter_;                  
            end
// X - M        NZC
            op_CPX_: begin      // X-M
                ALU_MUX = ALU_XM;
                ALU_operation = ALU_SUB;
                `SET_NZC
                next_state = counter_;
            end
// Y - M
            op_CPY_: begin      // Y-M
                ALU_MUX = ALU_YM;
                ALU_operation = ALU_SUB;
                `SET_NZC
                next_state = counter_;
            end
////////////////////////////////////////////////////
// M shift left, add 0            NZC
            op_ASL_: begin
                ALU_operation = ALU_SHL;
                ADDR_MUX = ADDR_MAR;
                MEMIO_W  = 1;
                `SET_NZC
                next_state = counter_;
            end
            op_ROL_: begin
                ALU_operation = ALU_ROL;
                ADDR_MUX = ADDR_MAR;
                MEMIO_W  = 1;
                `SET_NZC    
                next_state = counter_;
            end     
// M shift right, add 0            ZC
            op_LSR_: begin
                ALU_operation = ALU_SHR;
                ADDR_MUX = ADDR_MAR;
                MEMIO_W  = 1;
                `SET_NZC    
                next_state = counter_;
            end         
            op_ROR_: begin
                ALU_operation = ALU_ROR;
                ADDR_MUX = ADDR_MAR;
                MEMIO_W  = 1;
                `SET_NZC    
                next_state = counter_;
            end
// A shift left         NZC
            op_ASLA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_SHL;
                A_LD = 1;
                `SET_NZC
                next_state = counter_;
            end
            op_ROLA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_ROL;
                A_LD = 1;
                `SET_NZC
                next_state = counter_;
            end
// A shift reght, add 0            ZC
            op_LSRA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_SHR;
                A_LD = 1;
                `SET_NZC
                next_state = counter_;
            end
            op_RORA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_ROR;
                A_LD = 1;
                `SET_NZC
                next_state = counter_;
            end
            op_STA_: begin
                `ALU_PASS_A
                `STORE_MAR
                next_state = counter_;
            end
// M -> A               NZ
            op_LDA_: begin
                `ALU_PASS_MDR
                A_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
            op_STX_: begin
                `ALU_PASS_X
                `STORE_MAR
                next_state = counter_;
            end
// M -> X ,    NZ
            op_LDX_: begin
                `ALU_PASS_MDR
                X_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
            op_STY_: begin
                `ALU_PASS_Y
                `STORE_MAR
                next_state = counter_;
            end
            op_LDY_: begin
                `ALU_PASS_MDR
                Y_LD = 1;
                `SET_NZ
                next_state = counter_;
            end
// M7 -> N, M6 -> V, A & M   set Z
            op_BIT_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_AND;
                SR_operation = SR_BIT;
                next_state = counter_;
            end


// stack operation
            op_PHP_: begin          // push SR
                B_flag = 1;
                `ALU_PASS_SR
                `STACK_PUSH
                next_state = counter_;                
            end
            op_PHA_: begin
                `ALU_PASS_A
                `STACK_PUSH
                next_state = counter_;                  
            end
            op_PLP_: begin          // pull SR
                `STACK_PULL1
                next_state = op_PLP_1;                  
            end
            op_PLP_1: begin          // pull SR
                `ALU_PASS_MDR
                SR_operation = SR_LD;
                next_state = counter_;                  
            end
            op_PLA_: begin
                `STACK_PULL1
                next_state = op_PLA_1;                
            end
            op_PLA_1: begin
                `ALU_PASS_MDR
                A_LD = 1;
                `SET_NZ
                next_state = counter_;                
            end
////////////////////////////// X Y SR operation
            op_CLC_: begin
                SR_operation = SR_CLC;
                next_state = counter_;  
            end
            op_SEC_: begin
                SR_operation = SR_SEC;
                next_state = counter_;  
            end
            op_CLI_: begin
                SR_operation = SR_CLI;
                next_state = counter_;  
            end
            op_SEI_: begin
                SR_operation = SR_SEI;
                next_state = counter_;  
            end
            op_CLV_: begin
                SR_operation = SR_CLV;
                next_state = counter_;  
            end
            op_CLD_: begin
                SR_operation = SR_CLD;
                next_state = counter_;  
            end
            op_SED_: begin
                SR_operation = SR_SED;
                next_state = counter_;  
            end


// A -> X
            op_TAX_: begin
                `ALU_PASS_A
                X_LD = 1;
                `SET_NZ
                next_state = counter_;                 
            end
            op_TAY_: begin                  // A -> Y
                `ALU_PASS_A
                Y_LD = 1;
                `SET_NZ
                next_state = counter_;   
            end
            op_TYA_: begin
                `ALU_PASS_Y
                A_LD = 1;
                `SET_NZ
                next_state = counter_;                 
            end
            op_TXA_: begin      // X -> A
                `ALU_PASS_X
                A_LD = 1;
                `SET_NZ
                next_state = counter_;  
            end
            op_TXS_: begin      // X -> SP
                `ALU_PASS_X
                SP_operation = SP_LD;
                next_state = counter_;                 
            end
// A -> X             
            op_TSX_: begin      // SP -> X
                `ALU_PASS_SP
                X_LD = 1;
                `SET_NZ
                next_state = counter_;                  
            end

            op_NOP_: begin
                next_state = counter_;                  
            end


// common branch
            branch_: begin      // always branch
                PC_operation = PC_LD;
                ALU_MUX = ALU_PCM;
                ALU_operation = ALU_ADD16;  // PC + 8bit signed
                next_state = counter_;
            end
            op_BCC_:       // c clear
                next_state = `FLAG_C ? counter_ : branch_;
            op_BCS_: 
                next_state = `FLAG_C ? branch_ : counter_;
            op_BEQ_:       // Z = 1
                next_state = `FLAG_Z ? branch_ : counter_;
            op_BMI_:       // N = 1
                next_state = `FLAG_N ? branch_ : counter_;
            op_BNE_:       // Z = 0
                next_state = `FLAG_Z ? counter_ : branch_;
            op_BPL_:       // N = 0
                next_state = `FLAG_N ? counter_ : branch_;
            op_BVC_:       // V = 0
                next_state = `FLAG_V ? counter_ : branch_;
            op_BVS_:       // V = 1
                next_state = `FLAG_V ? branch_ : counter_;

// TODO: push PCH, PCL, SR
            op_BRK_: begin     // push PCH
                `ALU_PASS_PCH
                `STACK_PUSH
                next_state = op_BRK_1;
            end
            op_BRK_1: begin     // push PCL
                `ALU_PASS_PCL
                `STACK_PUSH
                next_state = op_BRK_2;
            end
            op_BRK_2: begin     // push SR
                B_flag = 1;
                `ALU_PASS_SR
                `STACK_PUSH
                next_state = IRQ_3;
            end
            IRQ_: begin     // push PCH
                `ALU_PASS_PCH
                `STACK_PUSH
                next_state = IRQ_1;
            end
            IRQ_1: begin     // push PCL
                `ALU_PASS_PCL
                `STACK_PUSH
                next_state = IRQ_2;
            end
            IRQ_2: begin     // push SR
                `ALU_PASS_SR
                `STACK_PUSH
                next_state = IRQ_3;
            end
            IRQ_3: begin          
                ADDR_MUX = ADDR_BRK;     // read M[16'hFFFC]
                `MEM_GET1
                next_state = IRQ_4;
            end
            IRQ_4: begin          
                `MEM_GET2
                next_state = IRQ_5;
            end
            IRQ_5: begin          
                `ALU_PASS_MDR
                PC_operation = PC_LD;      // load PC from ALU
                SR_operation = SR_SEI;      // set I, disable interrupt
                next_state = counter_;   // start first instruction
            end
            NMI_: begin     // push PCH
                `ALU_PASS_PCH
                `STACK_PUSH
                NMI_clear = '1;
                next_state = NMI_1;
            end
            NMI_1: begin     // push PCL
                `ALU_PASS_PCL
                `STACK_PUSH
                next_state = NMI_2;
            end
            NMI_2: begin     // push SR
                `ALU_PASS_SR
                `STACK_PUSH
                next_state = NMI_3;
            end
            NMI_3: begin          
                ADDR_MUX = ADDR_NMI;     // read M[16'hFFFC]
                `MEM_GET1
                next_state = IRQ_4;
            end

// 2 byte operand -> PC
            op_JMP_: begin
                `ALU_PASS_MDR
                PC_operation = PC_LD;
                next_state = counter_;
            end
// push PC-1, jmp
            op_JSR_: begin     //  PC --
                PC_operation = PC_DEC1;
                next_state = op_JSR_1;
            end
            op_JSR_1: begin     // push PCL
                `ALU_PASS_PCH
                `STACK_PUSH
                next_state = op_JSR_2;
            end
            op_JSR_2: begin     // push PC
                `ALU_PASS_PCL
                `STACK_PUSH
                next_state = op_JMP_;
            end
// pull PC, PC = PC + 1
            op_RTS_: begin     // pull PC, PC++, from branch
                `STACK_PULL1       // PCL -> MDRL    SP++
                next_state = op_RTS_1;                  
            end 
            op_RTS_1: begin     
                `STACK_PULL2      // PCH -> MDRH     SP++
                next_state = op_RTS_2;                  
            end
            op_RTS_2: begin     
                `ALU_PASS_MDR        
                PC_operation =  PC_LD;  
                next_state = op_RTS_3;                  
            end
            op_RTS_3: begin     
                PC_operation = PC_INC1;      // PC++            
                next_state = counter_;                   
            end
// pull SR, PC
            op_RTI_: begin                      // pull SR, PC
                `STACK_PULL1
                next_state = op_RTI_1;                  
            end
            op_RTI_1: begin     
                `ALU_PASS_MDR
                SR_operation = SR_LD;      // pull SR
                `STACK_PULL1            // PCL -> MDRL    SP++
                next_state = op_RTI_2;                  
            end
            op_RTI_2: begin     
                `STACK_PULL2       
                next_state = op_RTI_3;                   
            end
            op_RTI_3: begin     
                `ALU_PASS_MDR        
                PC_operation =  PC_LD;        
                next_state = counter_;                  
            end



            counter_ : begin        // 5
                B_flag = 0;
                //next_state = counter_out == 4 ?  counter_1 : counter_;
                next_state = counter_1;
                //next_state = CONTINUE ? counter_1 : counter_;
            end
            counter_1 : begin
                // if(CONTINUE)
                //    next_state = counter_1;
                // else begin
                    if(NMI_restore)
                        next_state = NMI_;
                    else if (IRQ && !(`FLAG_I))
                        next_state = IRQ_;
                    else 
                        next_state = fetch_;
                end
                //next_state = fetch_;
            //end
            default : 
                next_state = fetch_;
        endcase
    end
    
endmodule

`endif


