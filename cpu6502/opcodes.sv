`ifndef _OPCODES_SV 
`define _OPCODES_SV
/***************************************************
 basic opcode structure: aaa | bbb | cc
 regs:
    PC -- 16 bits
    SP -- 8  bits
    A  -- 8  bits
    X  -- 8  bits
    Y  -- 8  bits
    SR -- 8  bits   flags
    
 reference:  http://www.6502.org/tutorials/6502opcodes.html#LSR
             https://www.masswerk.at/6502/6502_instruction_set.html#ASL

 ***************************************************/

package opcodes;
 /************* cc = 01 *********************/
    // aaa| opcode|
    // 000	ORA
    // 001	AND
    // 010	EOR
    // 011	ADC
    // 100	STA
    // 101	LDA
    // 110	CMP
    // 111	SBC
    parameter op_ORA = 8'b00000001;  // A = A | xxx , set N Z
    parameter op_AND = 8'b00100001;  // A = A & xxx , set N Z
    parameter op_EOR = 8'b01000001;  // A = A ^ xxx , set N Z
    parameter op_ADC = 8'b01100001;  // A = A + xxx + C, set N Z C V
    parameter op_STA = 8'b10000001;  // store A to Memory
    parameter op_LDA = 8'b10100001;  // M -> A, set N Z
    parameter op_CMP = 8'b11000001;  // A - xxx, set N Z C
    parameter op_SBC = 8'b11100001;  // A = A - xxx - C, set N Z C V

    package addr_mode_01;
        parameter Index_X     = 3'b000;           // operand 1 byte, xxx = M[M[(operand+X) mod 256]]
        parameter Zero_Page   = 3'b001;           // operand 1 byte, xxx = M[operand]
        parameter Immediate   = 3'b010;           // operand 1 byte, xxx = operand
        parameter Absolute    = 3'b011;           // operand 2 byte, xxx = M[operand]

        parameter Index_Y     = 3'b100;           // operand 1 byte, xxx = M[M[(operand+Y) mod 256]]
        parameter Zero_Page_X = 3'b101;           // operand 1 byte, xxx = M[(operand+X) mod 256]
        parameter Absolute_Y  = 3'b110;           // operand 2 byte, xxx = M[operand+Y]
        parameter Absolute_X  = 3'b111;           // operand 2 byte, xxx = M[operand+X].
    endpackage

 /************* cc = 10 *********************/
    parameter op_ASL = 8'b00000010;             // C-xxx << 1, set N Z C
    parameter op_ROL = 8'b00100010;             // C-xxx rotate left 1 bit, set N Z C
    parameter op_LSR = 8'b01000010;             // xxx-C >> 1, set N Z C
    parameter op_ROR = 8'b01100010;             // xxx-C rotate right 1 bit, set N Z C
    parameter op_STX = 8'b10000010;             // X -> M
    parameter op_LDX = 8'b10100010;             // M -> X, set N Z
    parameter op_DEC = 8'b11000010;             // M = M-1, set N Z
    parameter op_INC = 8'b11100010;              // M = M+1, set N Z 

    package addr_mode_10;
        parameter Immediate   = 3'b000;           // operand 1 byte, xxx = operand
        parameter Zero_Page   = 3'b001;           // operand 1 byte, xxx = M[operand]
        parameter Accumulator = 3'b010;           // operand 0 byte, xxx = A
        parameter Absolute    = 3'b011;           // operand 2 byte, xxx = M[operand]

        parameter Zero_Page_X = 3'b101;           // operand 1 byte, xxx = M[(operand+X) mod 256]
        parameter Absolute_X  = 3'b111;           // operand 2 byte, xxx = M[operand+X].
    endpackage
 /************* cc = 00 *********************/
    parameter op_BIT = 8'b00100000;              // A & M, M7 -> N, M6 -> V, set Z
    parameter op_JMP = 8'b01000000;              // operand 2 byte, jump
    parameter op_JMP_abs = 8'b01100000;
    parameter op_STY = 8'b10000000;              // Y -> M
    parameter op_LDY = 8'b10100000;              // M -> Y, set N Z
    parameter op_CPY = 8'b11000000;              // Y - M, set N Z C
    parameter op_CPX = 8'b11100000;              // X - M, set N Z C

    package addr_mode_10;
        parameter Immediate   = 3'b000,           // operand 1 byte, xxx = operand
        parameter Zero_Page   = 3'b001,           // operand 1 byte, xxx = M[operand]
        parameter Accumulator = 3'b010,           // operand 0 byte, xxx = A
        parameter Absolute    = 3'b011,           // operand 2 byte, xxx = M[operand]

        parameter Zero_Page_X = 3'b101,           // operand 1 byte, xxx = M[(operand+X) mod 256]
        parameter Absolute_X  = 3'b111,           // operand 2 byte, xxx = M[operand+X].
    endpackage
 /************* branch  *********************/
// 7  bit  0
// ---- ----
// NVss DIZC
// |||| ||||
// |||| |||+- Carry
// |||| ||+-- Zero
// |||| |+--- Interrupt Disable
// |||| +---- Decimal
// ||++------ No CPU effect, see: the B flag
// |+-------- Overflow
// +--------- Negative

// xxy10000
// xx	flag
// 00	negative
// 01	overflow
// 10	carry
// 11	zero
// BPL	BMI	BVC	BVS	BCC	BCS	BNE	BEQ
// 10	30	50	70	90	B0	D0	F0
    parameter op_BR = 8'b00010000;
/************* IRQ  *********************/
    parameter op_BRK = 8'b00000000;  // push pc+2, push P, jmp to address in 0xFFFE, 0x
    // RESET: power on, 0xFFFC, 0xFFFD
    // NMI:   VGA frame, 0xFFFA, 0xFFFB
    
    //  push (PC+2),                     N Z C I D V
    //  (PC+1) -> PCL                    - - - - - -
    //  (PC+2) -> PCH
    parameter op_JSR_abs = 8'h20;
    //  pull SR, pull PC                 N Z C I D V
    //                               from stack
    parameter op_RTI = 8'h40;
        //  pull PC, PC+1 -> PC              N Z C I D V
        //                               - - - - - -
    parameter op_RTS = 8'h60;
// stack from 0x1ff to 0x100, SP = 0xff at empty
    parameter op_PHP = 8'h08;
    parameter op_PLP = 8'h28;
    parameter op_PHA = 8'h48;
    parameter op_PLA = 8'h68;
    parameter op_DEY = 8'h88;
    parameter op_TAY = 8'hA8;
    parameter op_INY = 8'hC8;
    parameter op_INX = 8'hE8;
    parameter op_CLC = 8'h18;
    parameter op_SEC = 8'h38;
    parameter op_CLI = 8'h58;
    parameter op_SEI = 8'h78;
    parameter op_TYA = 8'h98;
    parameter op_CLV = 8'hB8;
    parameter op_CLD = 8'hD8;
    parameter op_SED = 8'hF8;
    parameter op_TXA = 8'h8A;
    parameter op_TXS = 8'h9A;
    parameter op_TAX = 8'hAA;
    parameter op_TSX = 8'hBA;
    parameter op_DEX = 8'hCA;
    parameter op_NOP = 8'hEA;
endpackage
`endif 
// At power-up
// P = $34[1] (IRQ disabled)[2]
// A, X, Y = 0
// S = $FD
// $4017 = $00 (frame irq enabled)
// $4015 = $00 (all channels disabled)
// $4000-$400F = $00 (not sure about $4010-$4013)
// All 15 bits of noise channel LFSR = $0000[3]. The first time the LFSR is clocked from the all-0s state, it will shift in a 1.
// Internal memory ($0000-$07FF) has unreliable startup state. Some machines may have consistent RAM contents at power-on, but others do not.
// Emulators often implement a consistent RAM startup state (e.g. all $00 or $FF, or a particular pattern), and flash carts like the PowerPak may partially or fully initialize RAM before starting a program, so an NES programmer must be careful not to rely on the startup contents of RAM.
// After reset
// A, X, Y were not affected
// S was decremented by 3 (but nothing was written to the stack)
// The I (IRQ disable) flag was set to true (status ORed with $04)
// The internal memory was unchanged
// APU mode in $4017 was unchanged
// APU was silenced ($4015 = 0)