`ifndef _CONTROL_SV
`define _CONTROL_SV
`include "MemIO.sv"
`include "MUXs.sv"
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
    output A_operation_t        A_operation,
    output X_operation_t        X_operation,
    output Y_operation_t        Y_operation,
    output SP_operation_t       SP_operation,
    output logic                B_flag, setN, setV, setZ, setC,
    output SR_operation_t       SR_operation,

    output MEM_opreation_t      MEM_opreation,
    output ST_MUX_t             ST_MUX,
    output ADDR_MUX_t           ADDR_MUX,
    output logic                MEM_LDMAR,

    output ALU_MUX_t            ALU_MUX,
    output ALU_operation_t      ALU_operation
);
    /************************* state  *****************************/
    state_t state, next_state, addr_state, exe_state, exe_state_next;
    logic [7:0] decode_info, decode_info_next;
    logic LD_decode_info;
    always_ff @(posedge CLK) begin
        state <= RESET ? reset_0 : next_state;
        exe_state <= LD_decode_info ? exe_state_next : exe_state;
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
    logic page_cross_en, mem_read_en, mem_write_en;
    always_comb begin
        page_cross_en = decode_info[0];
        mem_read_en = decode_info[1];
        mem_write_en = decode_info[2];
        addr_state = state_t'(addr_temp);
        exe_state_next = state_t'(exe_temp);
    end
    /**************************************************************/
    always_comb begin
        Counter_operation = counter_run;

        LD_decode_info = '0;
        next_state = fetch_;
        

        MEM_opreation = MEM_KEEP;       // keep MDR
        ST_MUX = ST_ALUL;
        ADDR_MUX = ADDR_PC;
        MEM_LDMAR = '0;

        ALU_MUX = ALU_DECM;
        ALU_operation = ALU_PASS0;      // default: ALUL = MDRL, ALUH = MDRH
        // regs
        PC_operation = PC_KEEP;         // keep PC
        A_operation = A_KEEP;
        X_operation = X_KEEP;
        Y_operation = Y_KEEP;
        SP_operation = SP_KEEP;
        SR_operation = SR_KEEP;
        B_flag = '0;
        setN = '0;
        setV = '0;
        setZ = '0;
        setC = '0;

        case(state)
            reset_0: begin          
                ADDR_MUX = ADDR_RESET;     // read M[16'hFFFC]
                MEM_opreation = MEM_READ1;
                next_state = reset_1;
            end
            reset_1: begin          
                ADDR_MUX = ADDR_RESET;   
                MEM_opreation = MEM_READ2;
                next_state = reset_2;
            end
            reset_2: begin          
                PC_operation = PC_LD_MDR;   // load PC
                next_state = fetch_;        // start first instruction
            end
// M[PC] -> MDR, PC + 1 -> PC
            fetch_: begin       
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
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
                MEM_opreation = MEM_READ1;  // read operand
                PC_operation = PC_INC2;     // PC+2 -> PC
                next_state = addr_abs1;
            end      
            addr_abs1: begin        // load operand
                MEM_opreation = MEM_READ2;
                next_state = addr_abs2;
            end   
            addr_abs2: begin       
                MEM_LDMAR = '1;         // store addr
                ADDR_MUX = ADDR_MDR;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP; // load data (1 byte)
                next_state = exe_state;
            end   
// operand[1:0] + unsigned X  is addr 
            addr_absX: begin       
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC2;
                next_state = addr_absX1;
            end      
            addr_absX1: begin        // load operand
                MEM_opreation = MEM_READ2;
                next_state = addr_absX2;
            end   
            addr_absX2: begin       // load data (1 byte)
                MEM_LDMAR = '1;
                ADDR_MUX = ADDR_ALU;
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end    
// operand[1:0] + unsigned Y  is addr 
            addr_absY: begin       
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC2;
                next_state = addr_absY1;
            end      
            addr_absY1: begin        // load operand
                MEM_opreation = MEM_READ2;
                next_state = addr_absY2;
            end   
            addr_absY2: begin       // load data (1 byte)
                MEM_LDMAR = '1;
                ADDR_MUX = ADDR_ALU;
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end        
// operand 1 byte is signed offset of PC
            addr_relative: begin     // don't increase PC here,  for branch only
                MEM_opreation = MEM_READ1;
                next_state = exe_state;
            end     
// operand 1 byte is data
            addr_immed: begin     
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = exe_state;
            end
// operand 2 bytes is addr of addr
            addr_indir: begin          
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC2;
                next_state = addr_indir1;
            end
            addr_indir1: begin          
                MEM_opreation = MEM_READ2;
                next_state = addr_indir2;
            end
            addr_indir2: begin          
                MEM_LDMAR = '1;
                ADDR_MUX = ADDR_MDR;
                MEM_opreation = MEM_READ1;
                next_state = addr_indir3;
            end
            addr_indir3: begin          
                MEM_LDMAR = '0;
                ADDR_MUX = ADDR_MAR;
                MEM_opreation = MEM_READ2;
                next_state = addr_indir4;
            end
            addr_indir4: begin       // load data (1 byte)
                MEM_LDMAR = '1;
                ADDR_MUX = ADDR_MDR;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end  
// 1 byte, (X+operand) mod 256 is addr of addr
            addr_indexX: begin       // PC+1 -> PC
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = addr_indexX1;
            end      
            addr_indexX1: begin        // (X+operand) mod 256
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                MEM_LDMAR = '1;
                MEM_opreation = MEM_READ1;
                next_state = addr_indir3;
            end   
//1, M[operand] + Y mod 256 is addr
            addr_indexY: begin       // PC+1 -> PC
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = addr_indexY1;
            end      
            addr_indexY1: begin        // M[operand]
                ADDR_MUX = ADDR_MDRL;
                MEM_opreation = MEM_READ1;
                next_state = addr_indexY2;
            end   
            addr_indexY2: begin        // M[operand] + Y mod 256
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                MEM_LDMAR = '1;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end   
//1 byte operand is addr
            addr_zero: begin       // PC+1 -> PC
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = addr_zero1;
            end 
            addr_zero1: begin       // PC+1 -> PC
                MEM_LDMAR = '1;
                ADDR_MUX = ADDR_MDRL;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end 
//1 byte operand + X is addr
            addr_zeroX: begin       // PC+1 -> PC
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = addr_zeroX1;
            end 
            addr_zeroX1: begin       // (X+operand) mod 256
                ALU_MUX =  ALU_XM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                MEM_LDMAR = '1;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end 
//1 byte operand + Y is addr
            addr_zeroY: begin       // PC+1 -> PC
                MEM_opreation = MEM_READ1;
                PC_operation = PC_INC1;
                next_state = addr_zeroY1;
            end 
            addr_zeroY1: begin       // (Y+operand) mod 256
                ALU_MUX =  ALU_YM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_ALUL;
                MEM_LDMAR = '1;
                MEM_opreation = mem_read_en ? MEM_READ1 : MEM_KEEP;
                next_state = exe_state;
            end 
//////////////////////////////////////////////////////////////////
// opcode set 01, mainly about A
// A or M -> A
            op_ORA_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_OR;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A & M -> A            set NZ
            op_AND_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_AND;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A XOR M -> A
            op_EOR_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_XOR;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A + M + C -> A, C            set NZCV
            op_ADC_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_ADC;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                setC = 1;
                setV = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_STA_: begin
                ST_MUX =  ST_A;
                ADDR_MUX = ADDR_MAR;
                MEM_opreation = MEM_WRITE;
                next_state = counter_;
            end
// M -> A               NZ
            op_LDA_: begin
                A_operation = A_LD_MDRL;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A - M,           NZC
            op_CMP_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_SUB;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_SBC_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_SUBC;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                setC = 1;
                setV = 1;
                next_state = counter_;
            end
////////////////////////////////////////////////////
// M shift left, add 0            NZC
            op_ASL_: begin
                ALU_operation = ALU_SHL;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_ROL_: begin
                ALU_operation = ALU_ROL;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;  
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;     
                next_state = counter_;
            end     
// M shift reght, add 0            ZC
            op_LSR_: begin
                ALU_operation = ALU_SHR;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;   
                setN = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end         
            op_ROR_: begin
                ALU_operation = ALU_ROR;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;   
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A shift left         NZC
            op_ASLA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_SHL;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_ROLA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_ROL;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// A shift reght, add 0            ZC
            op_LSRA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_SHL;
                A_operation = A_LD_ALU;  
                setN = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_RORA_: begin
                ALU_MUX = ALU_AM;       // A -> ALUL0
                ALU_operation = ALU_ROR;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
            op_STX_: begin
                ST_MUX =  ST_X;
                ADDR_MUX = ADDR_MAR;
                MEM_opreation = MEM_WRITE;
                next_state = counter_;
            end
// M -> X ,    NZ
            op_LDX_: begin
                X_operation = X_LD_MDRL;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// M --
            op_DEC_: begin
                ALU_MUX = ALU_DECM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;   
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end  
// M ++ 
            op_INC_: begin
                ALU_MUX = ALU_INCM;
                ALU_operation = ALU_ADD16;
                ADDR_MUX = ADDR_MAR;
                ST_MUX = ST_ALUL;
                MEM_opreation = MEM_WRITE;   
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end   

            op_STY_: begin
                ST_MUX =  ST_Y;
                ADDR_MUX = ADDR_MAR;
                MEM_opreation = MEM_WRITE;
                next_state = counter_;
            end
            op_LDY_: begin
                Y_operation = Y_LD_MDRL;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// M7 -> N, M6 -> V, A & M   set Z
            op_BIT_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_AND;
                SR_operation = SR_BIT;
                next_state = counter_;
            end
// Y - M
            op_CPY_: begin      // Y-M
                ALU_MUX = ALU_YM;
                ALU_operation = ALU_SUB;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end
// X - M        NZC
            op_CPX_: begin      // X-M
                ALU_MUX = ALU_XM;
                ALU_operation = ALU_SUB;
                setN = 1;
                setZ = 1;
                setC = 1;
                SR_operation = SR_SET;
                next_state = counter_;
            end

            branch_: begin      // always branch
                PC_operation = PC_LD_ALU;
                ALU_MUX = ALU_PCM;
                ALU_operation = ALU_ADD16;
                next_state = counter_;
            end
// TODO: push PCH, PCL, SR
            op_BRK_: begin     // push SR
                SR_operation = SR_SEI;
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_SR;
                B_flag = 1;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = IRQ_1;
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
// 2 byte operand -> PC
            op_JMP_: begin
                ADDR_MUX = ADDR_MAR;
                MEM_opreation = MEM_READ2;      // read PCH
                next_state = op_JMP_1;
            end
            op_JMP_1: begin
                PC_operation = PC_LD_MDR;       // load PC
                next_state = counter_;
            end
// push PC+2, jmp
            op_JSR_: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCH;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = op_JSR_1;
            end
            op_JSR_1: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCL;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = op_JMP_;
            end
// pull PC, PC = PC + 1
            op_RTS_: begin     // pull PC, PC++, from branch
                SP_operation = SP_INC1;       // now M[SP] = PCL        
                next_state = op_RTS_1;                  
            end 
            op_RTS_1: begin     
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ1;      // load to MDRL
                next_state = op_RTS_2;                  
            end
            op_RTS_2: begin     
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ2;      // load to MDRH
                SP_operation = SP_INC1;            
                next_state = op_RTS_3;                  
            end
            op_RTS_3: begin     
                PC_operation = PC_LD_MDR;                  
                next_state = op_RTS_4;                  
            end
            op_RTS_4: begin     
                PC_operation = PC_INC1;      // PC++            
                next_state = counter_;                  
            end
// pull SR, PC
            op_RTI_: begin                      // pull SR, PC
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ2;      // load M[SP+1] to MDRH
                SP_operation = SP_INC1; 
                next_state = op_RTI_1;                  
            end
            op_RTI_1: begin     
                SR_operation = SR_LD_MDRH;      // pull SR
                SP_operation = SP_INC1;         // M[SP] = PCL
                next_state = op_RTI_2;                  
            end
            op_RTI_2: begin     
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ1;      // load PCL to MDRL
                next_state = op_RTI_3;                  
            end
            op_RTI_3: begin     
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ2;      // load to MDRH
                SP_operation = SP_INC1;            
                next_state = op_RTI_4;                  
            end
            op_RTI_4: begin     
                PC_operation = PC_LD_MDR;                  
                next_state = op_RTS_4;                  
            end

// stack operation
            op_PHP_: begin          // push SR
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_SR;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = counter_;                
            end
            op_PLP_: begin          // pull SR
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ2;      // load to MDRH
                SR_operation = SR_LD_MDRH;
                SP_operation = SP_INC1;
                next_state = counter_;                  
            end
            op_PHA_: begin
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_A;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = counter_;                  
            end
            op_PLA_: begin
                ADDR_MUX = ADDR_SP;
                MEM_opreation = MEM_READ2;      // load to MDRH
                A_operation = A_LD_MDRH;
                SP_operation = SP_INC1;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                
            end
////////////////////////////// X Y SR operation
            op_DEY_: begin                      // Y-1 -> Y
                ALU_MUX = ALU_DECY;
                ALU_operation = ALU_ADD16;
                Y_operation = Y_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                
            end
            op_TAY_: begin                  // A -> Y
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_PASS0;
                Y_operation = Y_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                
            end
            op_INY_: begin
                ALU_MUX = ALU_INCY;
                ALU_operation = ALU_ADD16;
                Y_operation = Y_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                   
            end
            op_INX_: begin
                ALU_MUX = ALU_INCX;
                ALU_operation = ALU_ADD16;
                X_operation = X_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;  
            end
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
            op_TYA_: begin
                ALU_MUX = ALU_INCY;
                ALU_operation = ALU_PASS0;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
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
            op_TXA_: begin      // X -> A
                ALU_MUX = ALU_INCX;
                ALU_operation = ALU_PASS0;
                A_operation = A_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;  
            end
            op_TXS_: begin
                ALU_MUX = ALU_INCX;
                ALU_operation = ALU_PASS0;
                SP_operation = SP_LD_ALU;
                next_state = counter_;                 
            end
// A -> X
            op_TAX_: begin
                ALU_MUX = ALU_AM;
                ALU_operation = ALU_PASS0;
                X_operation = X_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                 
            end
            op_TSX_: begin      // SP -> X
                ALU_MUX = ALU_PASSSP;
                ALU_operation = ALU_PASS0;
                X_operation = X_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                  
            end
// X --
            op_DEX_: begin
                ALU_MUX = ALU_DECX;
                ALU_operation = ALU_ADD16;
                X_operation = X_LD_ALU;
                setN = 1;
                setZ = 1;
                SR_operation = SR_SET;
                next_state = counter_;                  
            end
            op_NOP_: begin
                next_state = counter_;                  
            end





            counter_ : begin        // 5
                next_state = fetch_;//CONTINUE ? counter_1 : counter_;
            //     if(counter == 0) begin
            //         next_state = NMI ? NMI_0 : fetch_;
            //     end
            //     else
            //         next_state = counter_;
            end
            counter_1 : begin
                if(CONTINUE)
                    next_state = counter_1;
                else begin
                    if(NMI)
                        next_state = NMI_;
                    else if (IRQ && !(`FLAG_I))
                        next_state = IRQ_;
                    else 
                        next_state = fetch_;
                end
            end
            NMI_: begin     // push SR
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_SR;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = NMI_1;
            end
            NMI_1: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCH;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = NMI_2;
            end
            NMI_2: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCL;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = NMI_3;
            end
            NMI_3: begin          
                ADDR_MUX = ADDR_NMI;     // read M[16'hFFFC]
                MEM_opreation = MEM_READ1;
                next_state = NMI_4;
            end
            NMI_4: begin          
                ADDR_MUX = ADDR_NMI;   
                MEM_opreation = MEM_READ2;
                next_state = NMI_5;
            end
            NMI_5: begin          
                PC_operation = PC_LD_MDR; // load PC
                next_state = counter_;   // start first instruction
            end
            IRQ_: begin     // push SR
                SR_operation = SR_SEI;
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_SR;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = IRQ_1;
            end
            IRQ_1: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCH;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = IRQ_2;
            end
            IRQ_2: begin     // push PC
                ADDR_MUX = ADDR_SP;
                ST_MUX = ST_PCL;
                MEM_opreation = MEM_WRITE;
                SP_operation = SP_DEC1;
                next_state = IRQ_3;
            end
            IRQ_3: begin          
                ADDR_MUX = ADDR_BRK;     // read M[16'hFFFC]
                MEM_opreation = MEM_READ1;
                next_state = IRQ_4;
            end
            IRQ_4: begin          
                ADDR_MUX = ADDR_BRK;   
                MEM_opreation = MEM_READ2;
                next_state = IRQ_5;
            end
            IRQ_5: begin          
                PC_operation = PC_LD_MDR; // load PC
                next_state = counter_;   // start first instruction
            end
        endcase
    end
    
endmodule

`endif


