typedef enum logic [7:0] {
    reset_0, reset_1, reset_2,
    fetch_, 
    decode_, 
    counter_,   counter_1,
	branch_,

	addr_none,
    addr_abs, addr_abs1, addr_abs2,  // M[]    2
	addr_absX,addr_absX1, addr_absX2,	//  M[]+X   unsigned	2
	addr_absY, addr_absY1, addr_absY2,	//  M[]+Y   unsigned	2
	addr_relative,
	addr_immed,	// immediate	1
	addr_indir, addr_indir1, addr_indir2, addr_indir3, addr_indir4,
	addr_indexX, addr_indexX1, addr_indexX2,
	addr_indexY, addr_indexY1, addr_indexY2, addr_indexY3,
	addr_zero, addr_zero1,
	addr_zeroX, addr_zeroX1,
	addr_zeroY, addr_zeroY1,
	// first set, cc = 01
	op_ORA_,
	op_AND_,
	op_EOR_,
	op_ADC_,
	op_STA_,
	op_LDA_,
	op_CMP_,
	op_SBC_,
	// second set, cc = 10
	op_ASL_,
	op_ROL_,
	op_LSR_,
	op_ROR_,
	op_ASLA_,
	op_ROLA_,
	op_LSRA_,
	op_RORA_,
	op_STX_,
	op_LDX_,
	op_DEC_,
	op_INC_,
	//
	op_STY_,
	op_LDY_,
	op_BIT_,
	op_CPY_,
	op_CPX_,
	// branch
	op_BRK_, op_BRK_1, op_BRK_2,
	op_BCC_,
	op_BCS_,
	op_BEQ_,
	op_BMI_,
	op_BNE_,
	op_BPL_,
	op_BVC_,
	op_BVS_,

	op_JMP_, 
	op_JSR_, op_JSR_1,	op_JSR_2,
	op_RTS_, op_RTS_1, op_RTS_2, op_RTS_3,
	op_RTI_, op_RTI_1, op_RTI_2, op_RTI_3, 
// operation on X Y SR
	op_PHP_,
	op_PLP_, op_PLP_1,
	op_PHA_,
	op_PLA_, op_PLA_1,
	op_DEY_,
	op_TAY_,
	op_INY_,
	op_INX_,
	op_CLC_,
	op_SEC_,
	op_CLI_,
	op_SEI_,
	op_TYA_,
	op_CLV_,
	op_CLD_,
	op_SED_,
	op_TXA_,
	op_TXS_,
	op_TAX_,
	op_TSX_,
	op_DEX_,
	op_NOP_, 
	
	NMI_, NMI_1, NMI_2, NMI_3, NMI_4, NMI_5, 
	IRQ_, IRQ_1, IRQ_2, IRQ_3, IRQ_4, IRQ_5
} state_t;


/*
 * addressing mode if need memory operation
 *
 *
 */
module opcode_addr_state (
	input  logic CLK,
	input  logic [7:0] in,
	output logic [7:0] out
);

// This module will be synthesized into a RAM
always_ff @ (negedge CLK)
case (in)
8'h00: out<=addr_none;        8'h01: out<=addr_indexX;      8'h02: out<=fetch_;           8'h03: out<=fetch_;           
8'h04: out<=fetch_;           8'h05: out<=addr_zero;        8'h06: out<=addr_zero;        8'h07: out<=fetch_;           
8'h08: out<=addr_none;        8'h09: out<=addr_immed;       8'h0a: out<=addr_none;        8'h0b: out<=fetch_;           
8'h0c: out<=fetch_;           8'h0d: out<=addr_abs;         8'h0e: out<=addr_abs;         8'h0f: out<=fetch_;           
8'h10: out<=addr_relative;    8'h11: out<=addr_indexY;      8'h12: out<=fetch_;           8'h13: out<=fetch_;           
8'h14: out<=fetch_;           8'h15: out<=addr_zeroX;       8'h16: out<=addr_zeroX;       8'h17: out<=fetch_;           
8'h18: out<=addr_none;        8'h19: out<=addr_absY;        8'h1a: out<=fetch_;           8'h1b: out<=fetch_;           
8'h1c: out<=fetch_;           8'h1d: out<=addr_absX;        8'h1e: out<=addr_absX;        8'h1f: out<=fetch_;           
8'h20: out<=addr_abs;         8'h21: out<=addr_indexX;      8'h22: out<=fetch_;           8'h23: out<=fetch_;           
8'h24: out<=addr_zero;        8'h25: out<=addr_zero;        8'h26: out<=addr_zero;        8'h27: out<=fetch_;           
8'h28: out<=addr_none;        8'h29: out<=addr_immed;       8'h2a: out<=addr_none;        8'h2b: out<=fetch_;           
8'h2c: out<=addr_abs;         8'h2d: out<=addr_abs;         8'h2e: out<=addr_abs;         8'h2f: out<=fetch_;           
8'h30: out<=addr_relative;    8'h31: out<=addr_indexY;      8'h32: out<=fetch_;           8'h33: out<=fetch_;           
8'h34: out<=fetch_;           8'h35: out<=addr_zeroX;       8'h36: out<=addr_zeroX;       8'h37: out<=fetch_;           
8'h38: out<=addr_none;        8'h39: out<=addr_absY;        8'h3a: out<=fetch_;           8'h3b: out<=fetch_;           
8'h3c: out<=fetch_;           8'h3d: out<=addr_absX;        8'h3e: out<=addr_absX;        8'h3f: out<=fetch_;           
8'h40: out<=addr_none;        8'h41: out<=addr_indexX;      8'h42: out<=fetch_;           8'h43: out<=fetch_;           
8'h44: out<=fetch_;           8'h45: out<=addr_zero;        8'h46: out<=addr_zero;        8'h47: out<=fetch_;           
8'h48: out<=addr_none;        8'h49: out<=addr_immed;       8'h4a: out<=addr_none;        8'h4b: out<=fetch_;           
8'h4c: out<=addr_abs;         8'h4d: out<=addr_abs;         8'h4e: out<=addr_abs;         8'h4f: out<=fetch_;           
8'h50: out<=addr_relative;    8'h51: out<=addr_indexY;      8'h52: out<=fetch_;           8'h53: out<=fetch_;           
8'h54: out<=fetch_;           8'h55: out<=addr_zeroX;       8'h56: out<=addr_zeroX;       8'h57: out<=fetch_;           
8'h58: out<=addr_none;        8'h59: out<=addr_absY;        8'h5a: out<=fetch_;           8'h5b: out<=fetch_;           
8'h5c: out<=fetch_;           8'h5d: out<=addr_absX;        8'h5e: out<=addr_absX;        8'h5f: out<=fetch_;           
8'h60: out<=addr_none;        8'h61: out<=addr_indexX;      8'h62: out<=fetch_;           8'h63: out<=fetch_;           
8'h64: out<=fetch_;           8'h65: out<=addr_zero;        8'h66: out<=addr_zero;        8'h67: out<=fetch_;           
8'h68: out<=addr_none;        8'h69: out<=addr_immed;       8'h6a: out<=addr_none;        8'h6b: out<=fetch_;           
8'h6c: out<=addr_indir;       8'h6d: out<=addr_abs;         8'h6e: out<=addr_abs;         8'h6f: out<=fetch_;           
8'h70: out<=addr_relative;    8'h71: out<=addr_indexY;      8'h72: out<=fetch_;           8'h73: out<=fetch_;           
8'h74: out<=fetch_;           8'h75: out<=addr_zeroX;       8'h76: out<=addr_zeroX;       8'h77: out<=fetch_;           
8'h78: out<=addr_none;        8'h79: out<=addr_absY;        8'h7a: out<=fetch_;           8'h7b: out<=fetch_;           
8'h7c: out<=fetch_;           8'h7d: out<=addr_absX;        8'h7e: out<=addr_absX;        8'h7f: out<=fetch_;           
8'h80: out<=fetch_;           8'h81: out<=addr_indexX;      8'h82: out<=fetch_;           8'h83: out<=fetch_;           
8'h84: out<=addr_zero;        8'h85: out<=addr_zero;        8'h86: out<=addr_zero;        8'h87: out<=fetch_;           
8'h88: out<=addr_none;        8'h89: out<=fetch_;           8'h8a: out<=addr_none;        8'h8b: out<=fetch_;           
8'h8c: out<=addr_abs;         8'h8d: out<=addr_abs;         8'h8e: out<=addr_abs;         8'h8f: out<=fetch_;           
8'h90: out<=addr_relative;    8'h91: out<=addr_indexY;      8'h92: out<=fetch_;           8'h93: out<=fetch_;           
8'h94: out<=addr_zeroX;       8'h95: out<=addr_zeroX;       8'h96: out<=addr_zeroY;       8'h97: out<=fetch_;           
8'h98: out<=addr_none;        8'h99: out<=addr_absY;        8'h9a: out<=addr_none;        8'h9b: out<=fetch_;           
8'h9c: out<=fetch_;           8'h9d: out<=addr_absX;        8'h9e: out<=fetch_;           8'h9f: out<=fetch_;           
8'ha0: out<=addr_immed;       8'ha1: out<=addr_indexX;      8'ha2: out<=addr_immed;       8'ha3: out<=fetch_;           
8'ha4: out<=addr_zero;        8'ha5: out<=addr_zero;        8'ha6: out<=addr_zero;        8'ha7: out<=fetch_;           
8'ha8: out<=addr_none;        8'ha9: out<=addr_immed;       8'haa: out<=addr_none;        8'hab: out<=fetch_;           
8'hac: out<=addr_abs;         8'had: out<=addr_abs;         8'hae: out<=addr_abs;         8'haf: out<=fetch_;           
8'hb0: out<=addr_relative;    8'hb1: out<=addr_indexY;      8'hb2: out<=fetch_;           8'hb3: out<=fetch_;           
8'hb4: out<=addr_zeroX;       8'hb5: out<=addr_zeroX;       8'hb6: out<=addr_zeroY;       8'hb7: out<=fetch_;           
8'hb8: out<=addr_none;        8'hb9: out<=addr_absY;        8'hba: out<=addr_none;        8'hbb: out<=fetch_;           
8'hbc: out<=addr_absX;        8'hbd: out<=addr_absX;        8'hbe: out<=addr_absY;        8'hbf: out<=fetch_;           
8'hc0: out<=addr_immed;       8'hc1: out<=addr_indexX;      8'hc2: out<=fetch_;           8'hc3: out<=fetch_;           
8'hc4: out<=addr_zero;        8'hc5: out<=addr_zero;        8'hc6: out<=addr_zero;        8'hc7: out<=fetch_;           
8'hc8: out<=addr_none;        8'hc9: out<=addr_immed;       8'hca: out<=addr_none;        8'hcb: out<=fetch_;           
8'hcc: out<=addr_abs;         8'hcd: out<=addr_abs;         8'hce: out<=addr_abs;         8'hcf: out<=fetch_;           
8'hd0: out<=addr_relative;    8'hd1: out<=addr_indexY;      8'hd2: out<=fetch_;           8'hd3: out<=fetch_;           
8'hd4: out<=fetch_;           8'hd5: out<=addr_zeroX;       8'hd6: out<=addr_zeroX;       8'hd7: out<=fetch_;           
8'hd8: out<=addr_none;        8'hd9: out<=addr_absY;        8'hda: out<=fetch_;           8'hdb: out<=fetch_;           
8'hdc: out<=fetch_;           8'hdd: out<=addr_absX;        8'hde: out<=addr_absX;        8'hdf: out<=fetch_;           
8'he0: out<=addr_immed;       8'he1: out<=addr_indexX;      8'he2: out<=fetch_;           8'he3: out<=fetch_;           
8'he4: out<=addr_zero;        8'he5: out<=addr_zero;        8'he6: out<=addr_zero;        8'he7: out<=fetch_;           
8'he8: out<=addr_none;        8'he9: out<=addr_immed;       8'hea: out<=addr_none;        8'heb: out<=fetch_;           
8'hec: out<=addr_abs;         8'hed: out<=addr_abs;         8'hee: out<=addr_abs;         8'hef: out<=fetch_;           
8'hf0: out<=addr_relative;    8'hf1: out<=addr_indexY;      8'hf2: out<=fetch_;           8'hf3: out<=fetch_;           
8'hf4: out<=fetch_;           8'hf5: out<=addr_zeroX;       8'hf6: out<=addr_zeroX;       8'hf7: out<=fetch_;           
8'hf8: out<=addr_none;        8'hf9: out<=addr_absY;        8'hfa: out<=fetch_;           8'hfb: out<=fetch_;           
8'hfc: out<=fetch_;           8'hfd: out<=addr_absX;        8'hfe: out<=addr_absX;        8'hff: out<=fetch_;    
endcase
endmodule

module opcode_exe_state (
	input  logic CLK,
	input  logic [7:0] in,
	output logic [7:0] out
);

// This module will be synthesized into a RAM
always_ff @ (negedge CLK)
case (in)
8'h00: out<=op_BRK_;          8'h01: out<=op_ORA_;          8'h02: out<=fetch_;           8'h03: out<=fetch_;           
8'h04: out<=fetch_;           8'h05: out<=op_ORA_;          8'h06: out<=op_ASL_;          8'h07: out<=fetch_;           
8'h08: out<=op_PHP_;          8'h09: out<=op_ORA_;          8'h0a: out<=op_ASLA_;         8'h0b: out<=fetch_;           
8'h0c: out<=fetch_;           8'h0d: out<=op_ORA_;          8'h0e: out<=op_ASL_;          8'h0f: out<=fetch_;           
8'h10: out<=op_BPL_;          8'h11: out<=op_ORA_;          8'h12: out<=fetch_;           8'h13: out<=fetch_;           
8'h14: out<=fetch_;           8'h15: out<=op_ORA_;          8'h16: out<=op_ASL_;          8'h17: out<=fetch_;           
8'h18: out<=op_CLC_;          8'h19: out<=op_ORA_;          8'h1a: out<=fetch_;           8'h1b: out<=fetch_;           
8'h1c: out<=fetch_;           8'h1d: out<=op_ORA_;          8'h1e: out<=op_ASL_;          8'h1f: out<=fetch_;           
8'h20: out<=op_JSR_;          8'h21: out<=op_AND_;          8'h22: out<=fetch_;           8'h23: out<=fetch_;           
8'h24: out<=op_BIT_;          8'h25: out<=op_AND_;          8'h26: out<=op_ROL_;          8'h27: out<=fetch_;           
8'h28: out<=op_PLP_;          8'h29: out<=op_AND_;          8'h2a: out<=op_ROLA_;         8'h2b: out<=fetch_;           
8'h2c: out<=op_BIT_;          8'h2d: out<=op_AND_;          8'h2e: out<=op_ROL_;          8'h2f: out<=fetch_;           
8'h30: out<=op_BMI_;          8'h31: out<=op_AND_;          8'h32: out<=fetch_;           8'h33: out<=fetch_;           
8'h34: out<=fetch_;           8'h35: out<=op_AND_;          8'h36: out<=op_ROL_;          8'h37: out<=fetch_;           
8'h38: out<=op_SEC_;          8'h39: out<=op_AND_;          8'h3a: out<=fetch_;           8'h3b: out<=fetch_;           
8'h3c: out<=fetch_;           8'h3d: out<=op_AND_;          8'h3e: out<=op_ROL_;          8'h3f: out<=fetch_;           
8'h40: out<=op_RTI_;          8'h41: out<=op_EOR_;          8'h42: out<=fetch_;           8'h43: out<=fetch_;           
8'h44: out<=fetch_;           8'h45: out<=op_EOR_;          8'h46: out<=op_LSR_;          8'h47: out<=fetch_;           
8'h48: out<=op_PHA_;          8'h49: out<=op_EOR_;          8'h4a: out<=op_LSRA_;         8'h4b: out<=fetch_;           
8'h4c: out<=op_JMP_;          8'h4d: out<=op_EOR_;          8'h4e: out<=op_LSR_;          8'h4f: out<=fetch_;           
8'h50: out<=op_BVC_;          8'h51: out<=op_EOR_;          8'h52: out<=fetch_;           8'h53: out<=fetch_;           
8'h54: out<=fetch_;           8'h55: out<=op_EOR_;          8'h56: out<=op_LSR_;          8'h57: out<=fetch_;           
8'h58: out<=op_CLI_;          8'h59: out<=op_EOR_;          8'h5a: out<=fetch_;           8'h5b: out<=fetch_;           
8'h5c: out<=fetch_;           8'h5d: out<=op_EOR_;          8'h5e: out<=op_LSR_;          8'h5f: out<=fetch_;           
8'h60: out<=op_RTS_;          8'h61: out<=op_ADC_;          8'h62: out<=fetch_;           8'h63: out<=fetch_;           
8'h64: out<=fetch_;           8'h65: out<=op_ADC_;          8'h66: out<=op_ROR_;          8'h67: out<=fetch_;           
8'h68: out<=op_PLA_;          8'h69: out<=op_ADC_;          8'h6a: out<=op_RORA_;         8'h6b: out<=fetch_;           
8'h6c: out<=op_JMP_;          8'h6d: out<=op_ADC_;          8'h6e: out<=op_ROR_;          8'h6f: out<=fetch_;           
8'h70: out<=op_BVS_;          8'h71: out<=op_ADC_;          8'h72: out<=fetch_;           8'h73: out<=fetch_;           
8'h74: out<=fetch_;           8'h75: out<=op_ADC_;          8'h76: out<=op_ROR_;          8'h77: out<=fetch_;           
8'h78: out<=op_SEI_;          8'h79: out<=op_ADC_;          8'h7a: out<=fetch_;           8'h7b: out<=fetch_;           
8'h7c: out<=fetch_;           8'h7d: out<=op_ADC_;          8'h7e: out<=op_ROR_;          8'h7f: out<=fetch_;           
8'h80: out<=fetch_;           8'h81: out<=op_STA_;          8'h82: out<=fetch_;           8'h83: out<=fetch_;           
8'h84: out<=op_STY_;          8'h85: out<=op_STA_;          8'h86: out<=op_STX_;          8'h87: out<=fetch_;           
8'h88: out<=op_DEY_;          8'h89: out<=fetch_;           8'h8a: out<=op_TXA_;          8'h8b: out<=fetch_;           
8'h8c: out<=op_STY_;          8'h8d: out<=op_STA_;          8'h8e: out<=op_STX_;          8'h8f: out<=fetch_;           
8'h90: out<=op_BCC_;          8'h91: out<=op_STA_;          8'h92: out<=fetch_;           8'h93: out<=fetch_;           
8'h94: out<=op_STY_;          8'h95: out<=op_STA_;          8'h96: out<=op_STX_;          8'h97: out<=fetch_;           
8'h98: out<=op_TYA_;          8'h99: out<=op_STA_;          8'h9a: out<=op_TXS_;          8'h9b: out<=fetch_;           
8'h9c: out<=fetch_;           8'h9d: out<=op_STA_;          8'h9e: out<=fetch_;           8'h9f: out<=fetch_;           
8'ha0: out<=op_LDY_;          8'ha1: out<=op_LDA_;          8'ha2: out<=op_LDX_;          8'ha3: out<=fetch_;           
8'ha4: out<=op_LDY_;          8'ha5: out<=op_LDA_;          8'ha6: out<=op_LDX_;          8'ha7: out<=fetch_;           
8'ha8: out<=op_TAY_;          8'ha9: out<=op_LDA_;          8'haa: out<=op_TAX_;          8'hab: out<=fetch_;           
8'hac: out<=op_LDY_;          8'had: out<=op_LDA_;          8'hae: out<=op_LDX_;          8'haf: out<=fetch_;           
8'hb0: out<=op_BCS_;          8'hb1: out<=op_LDA_;          8'hb2: out<=fetch_;           8'hb3: out<=fetch_;           
8'hb4: out<=op_LDY_;          8'hb5: out<=op_LDA_;          8'hb6: out<=op_LDX_;          8'hb7: out<=fetch_;           
8'hb8: out<=op_CLV_;          8'hb9: out<=op_LDA_;          8'hba: out<=op_TSX_;          8'hbb: out<=fetch_;           
8'hbc: out<=op_LDY_;          8'hbd: out<=op_LDA_;          8'hbe: out<=op_LDX_;          8'hbf: out<=fetch_;           
8'hc0: out<=op_CPY_;          8'hc1: out<=op_CMP_;          8'hc2: out<=fetch_;           8'hc3: out<=fetch_;           
8'hc4: out<=op_CPY_;          8'hc5: out<=op_CMP_;          8'hc6: out<=op_DEC_;          8'hc7: out<=fetch_;           
8'hc8: out<=op_INY_;          8'hc9: out<=op_CMP_;          8'hca: out<=op_DEX_;          8'hcb: out<=fetch_;           
8'hcc: out<=op_CPY_;          8'hcd: out<=op_CMP_;          8'hce: out<=op_DEC_;          8'hcf: out<=fetch_;           
8'hd0: out<=op_BNE_;          8'hd1: out<=op_CMP_;          8'hd2: out<=fetch_;           8'hd3: out<=fetch_;           
8'hd4: out<=fetch_;           8'hd5: out<=op_CMP_;          8'hd6: out<=op_DEC_;          8'hd7: out<=fetch_;           
8'hd8: out<=op_CLD_;          8'hd9: out<=op_CMP_;          8'hda: out<=fetch_;           8'hdb: out<=fetch_;           
8'hdc: out<=fetch_;           8'hdd: out<=op_CMP_;          8'hde: out<=op_DEC_;          8'hdf: out<=fetch_;           
8'he0: out<=op_CPX_;          8'he1: out<=op_SBC_;          8'he2: out<=fetch_;           8'he3: out<=fetch_;           
8'he4: out<=op_CPX_;          8'he5: out<=op_SBC_;          8'he6: out<=op_INC_;          8'he7: out<=fetch_;           
8'he8: out<=op_INX_;          8'he9: out<=op_SBC_;          8'hea: out<=op_NOP_;          8'heb: out<=fetch_;           
8'hec: out<=op_CPX_;          8'hed: out<=op_SBC_;          8'hee: out<=op_INC_;          8'hef: out<=fetch_;           
8'hf0: out<=op_BEQ_;          8'hf1: out<=op_SBC_;          8'hf2: out<=fetch_;           8'hf3: out<=fetch_;           
8'hf4: out<=fetch_;           8'hf5: out<=op_SBC_;          8'hf6: out<=op_INC_;          8'hf7: out<=fetch_;           
8'hf8: out<=op_SED_;          8'hf9: out<=op_SBC_;          8'hfa: out<=fetch_;           8'hfb: out<=fetch_;           
8'hfc: out<=fetch_;           8'hfd: out<=op_SBC_;          8'hfe: out<=op_INC_;          8'hff: out<=fetch_;           

endcase
endmodule



/*
 * bit[0] : affected by page-crossing 
 * bit[1] : need memory read 
 */
module opcode_info (
	input  logic CLK,
	input  logic [7:0] in,
	output logic [7:0] out
);

// This module will be synthesized into a RAM
always_ff @ (negedge CLK)
case (in)
8'h00: out<=0;                8'h01: out<=2;                8'h02: out<=0;                8'h03: out<=0;                
8'h04: out<=0;                8'h05: out<=2;                8'h06: out<=2;                8'h07: out<=0;                
8'h08: out<=0;                8'h09: out<=2;                8'h0a: out<=0;                8'h0b: out<=0;                
8'h0c: out<=0;                8'h0d: out<=2;                8'h0e: out<=2;                8'h0f: out<=0;                
8'h10: out<=3;                8'h11: out<=3;                8'h12: out<=0;                8'h13: out<=0;                
8'h14: out<=0;                8'h15: out<=2;                8'h16: out<=2;                8'h17: out<=0;                
8'h18: out<=0;                8'h19: out<=3;                8'h1a: out<=0;                8'h1b: out<=0;                
8'h1c: out<=0;                8'h1d: out<=3;                8'h1e: out<=2;                8'h1f: out<=0;                
8'h20: out<=0;                8'h21: out<=2;                8'h22: out<=0;                8'h23: out<=0;                
8'h24: out<=2;                8'h25: out<=2;                8'h26: out<=2;                8'h27: out<=0;                
8'h28: out<=0;                8'h29: out<=2;                8'h2a: out<=0;                8'h2b: out<=0;                
8'h2c: out<=2;                8'h2d: out<=2;                8'h2e: out<=2;                8'h2f: out<=0;                
8'h30: out<=3;                8'h31: out<=3;                8'h32: out<=0;                8'h33: out<=0;                
8'h34: out<=0;                8'h35: out<=2;                8'h36: out<=2;                8'h37: out<=0;                
8'h38: out<=0;                8'h39: out<=3;                8'h3a: out<=0;                8'h3b: out<=0;                
8'h3c: out<=0;                8'h3d: out<=3;                8'h3e: out<=2;                8'h3f: out<=0;                
8'h40: out<=0;                8'h41: out<=2;                8'h42: out<=0;                8'h43: out<=0;                
8'h44: out<=0;                8'h45: out<=2;                8'h46: out<=2;                8'h47: out<=0;                
8'h48: out<=0;                8'h49: out<=2;                8'h4a: out<=0;                8'h4b: out<=0;                
8'h4c: out<=0;                8'h4d: out<=2;                8'h4e: out<=2;                8'h4f: out<=0;                
8'h50: out<=3;                8'h51: out<=3;                8'h52: out<=0;                8'h53: out<=0;                
8'h54: out<=0;                8'h55: out<=2;                8'h56: out<=2;                8'h57: out<=0;                
8'h58: out<=0;                8'h59: out<=3;                8'h5a: out<=0;                8'h5b: out<=0;                
8'h5c: out<=0;                8'h5d: out<=3;                8'h5e: out<=2;                8'h5f: out<=0;                
8'h60: out<=0;                8'h61: out<=2;                8'h62: out<=0;                8'h63: out<=0;                
8'h64: out<=0;                8'h65: out<=2;                8'h66: out<=2;                8'h67: out<=0;                
8'h68: out<=0;                8'h69: out<=2;                8'h6a: out<=0;                8'h6b: out<=0;                
8'h6c: out<=0;                8'h6d: out<=2;                8'h6e: out<=2;                8'h6f: out<=0;                
8'h70: out<=3;                8'h71: out<=3;                8'h72: out<=0;                8'h73: out<=0;                
8'h74: out<=0;                8'h75: out<=2;                8'h76: out<=2;                8'h77: out<=0;                
8'h78: out<=0;                8'h79: out<=3;                8'h7a: out<=0;                8'h7b: out<=0;                
8'h7c: out<=0;                8'h7d: out<=3;                8'h7e: out<=2;                8'h7f: out<=0;                
8'h80: out<=0;                8'h81: out<=0;                8'h82: out<=0;                8'h83: out<=0;                
8'h84: out<=0;                8'h85: out<=0;                8'h86: out<=0;                8'h87: out<=0;                
8'h88: out<=0;                8'h89: out<=0;                8'h8a: out<=0;                8'h8b: out<=0;                
8'h8c: out<=0;                8'h8d: out<=0;                8'h8e: out<=0;                8'h8f: out<=0;                
8'h90: out<=3;                8'h91: out<=0;                8'h92: out<=0;                8'h93: out<=0;                
8'h94: out<=0;                8'h95: out<=0;                8'h96: out<=0;                8'h97: out<=0;                
8'h98: out<=0;                8'h99: out<=0;                8'h9a: out<=0;                8'h9b: out<=0;                
8'h9c: out<=0;                8'h9d: out<=0;                8'h9e: out<=0;                8'h9f: out<=0;                
8'ha0: out<=2;                8'ha1: out<=2;                8'ha2: out<=2;                8'ha3: out<=0;                
8'ha4: out<=2;                8'ha5: out<=2;                8'ha6: out<=2;                8'ha7: out<=0;                
8'ha8: out<=0;                8'ha9: out<=2;                8'haa: out<=0;                8'hab: out<=0;                
8'hac: out<=2;                8'had: out<=2;                8'hae: out<=2;                8'haf: out<=0;                
8'hb0: out<=3;                8'hb1: out<=3;                8'hb2: out<=0;                8'hb3: out<=0;                
8'hb4: out<=2;                8'hb5: out<=2;                8'hb6: out<=2;                8'hb7: out<=0;                
8'hb8: out<=0;                8'hb9: out<=3;                8'hba: out<=0;                8'hbb: out<=0;                
8'hbc: out<=3;                8'hbd: out<=3;                8'hbe: out<=3;                8'hbf: out<=0;                
8'hc0: out<=2;                8'hc1: out<=2;                8'hc2: out<=0;                8'hc3: out<=0;                
8'hc4: out<=2;                8'hc5: out<=2;                8'hc6: out<=2;                8'hc7: out<=0;                
8'hc8: out<=0;                8'hc9: out<=2;                8'hca: out<=0;                8'hcb: out<=0;                
8'hcc: out<=2;                8'hcd: out<=2;                8'hce: out<=2;                8'hcf: out<=0;                
8'hd0: out<=3;                8'hd1: out<=3;                8'hd2: out<=0;                8'hd3: out<=0;                
8'hd4: out<=0;                8'hd5: out<=2;                8'hd6: out<=2;                8'hd7: out<=0;                
8'hd8: out<=0;                8'hd9: out<=3;                8'hda: out<=0;                8'hdb: out<=0;                
8'hdc: out<=0;                8'hdd: out<=3;                8'hde: out<=2;                8'hdf: out<=0;                
8'he0: out<=2;                8'he1: out<=2;                8'he2: out<=0;                8'he3: out<=0;                
8'he4: out<=2;                8'he5: out<=2;                8'he6: out<=2;                8'he7: out<=0;                
8'he8: out<=0;                8'he9: out<=2;                8'hea: out<=0;                8'heb: out<=0;                
8'hec: out<=2;                8'hed: out<=2;                8'hee: out<=2;                8'hef: out<=0;                
8'hf0: out<=3;                8'hf1: out<=3;                8'hf2: out<=0;                8'hf3: out<=0;                
8'hf4: out<=0;                8'hf5: out<=2;                8'hf6: out<=2;                8'hf7: out<=0;                
8'hf8: out<=0;                8'hf9: out<=3;                8'hfa: out<=0;                8'hfb: out<=0;                
8'hfc: out<=0;                8'hfd: out<=3;                8'hfe: out<=2;                8'hff: out<=0;                

endcase
endmodule



module opcode_timing (
	input  logic CLK,
	input  logic [7:0] in,
	output logic [7:0] out
);

// This module will be synthesized into a RAM
always_ff @ (negedge CLK)
case (in)
8'h00: out<=15;		8'h01: out<=15;		8'h02: out<=15;		8'h03: out<=15;		
8'h04: out<=15;		8'h05: out<=15;		8'h06: out<=15;		8'h07: out<=15;		
8'h08: out<=15;		8'h09: out<=15;		8'h0a: out<=15;		8'h0b: out<=15;		
8'h0c: out<=15;		8'h0d: out<=15;		8'h0e: out<=15;		8'h0f: out<=15;		
8'h10: out<=15;		8'h11: out<=15;		8'h12: out<=15;		8'h13: out<=15;		
8'h14: out<=15;		8'h15: out<=15;		8'h16: out<=15;		8'h17: out<=15;		
8'h18: out<=15;		8'h19: out<=15;		8'h1a: out<=15;		8'h1b: out<=15;		
8'h1c: out<=15;		8'h1d: out<=15;		8'h1e: out<=15;		8'h1f: out<=15;		
8'h20: out<=15;		8'h21: out<=15;		8'h22: out<=15;		8'h23: out<=15;		
8'h24: out<=15;		8'h25: out<=15;		8'h26: out<=15;		8'h27: out<=15;		
8'h28: out<=15;		8'h29: out<=15;		8'h2a: out<=15;		8'h2b: out<=15;		
8'h2c: out<=15;		8'h2d: out<=15;		8'h2e: out<=15;		8'h2f: out<=15;		
8'h30: out<=15;		8'h31: out<=15;		8'h32: out<=15;		8'h33: out<=15;		
8'h34: out<=15;		8'h35: out<=15;		8'h36: out<=15;		8'h37: out<=15;		
8'h38: out<=15;		8'h39: out<=15;		8'h3a: out<=15;		8'h3b: out<=15;		
8'h3c: out<=15;		8'h3d: out<=15;		8'h3e: out<=15;		8'h3f: out<=15;		
8'h40: out<=15;		8'h41: out<=15;		8'h42: out<=15;		8'h43: out<=15;		
8'h44: out<=15;		8'h45: out<=15;		8'h46: out<=15;		8'h47: out<=15;		
8'h48: out<=15;		8'h49: out<=15;		8'h4a: out<=15;		8'h4b: out<=15;		
8'h4c: out<=15;		8'h4d: out<=15;		8'h4e: out<=15;		8'h4f: out<=15;		
8'h50: out<=15;		8'h51: out<=15;		8'h52: out<=15;		8'h53: out<=15;		
8'h54: out<=15;		8'h55: out<=15;		8'h56: out<=15;		8'h57: out<=15;		
8'h58: out<=15;		8'h59: out<=15;		8'h5a: out<=15;		8'h5b: out<=15;		
8'h5c: out<=15;		8'h5d: out<=15;		8'h5e: out<=15;		8'h5f: out<=15;		
8'h60: out<=15;		8'h61: out<=15;		8'h62: out<=15;		8'h63: out<=15;		
8'h64: out<=15;		8'h65: out<=15;		8'h66: out<=15;		8'h67: out<=15;		
8'h68: out<=15;		8'h69: out<=15;		8'h6a: out<=15;		8'h6b: out<=15;		
8'h6c: out<=15;		8'h6d: out<=15;		8'h6e: out<=15;		8'h6f: out<=15;		
8'h70: out<=15;		8'h71: out<=15;		8'h72: out<=15;		8'h73: out<=15;		
8'h74: out<=15;		8'h75: out<=15;		8'h76: out<=15;		8'h77: out<=15;		
8'h78: out<=15;		8'h79: out<=15;		8'h7a: out<=15;		8'h7b: out<=15;		
8'h7c: out<=15;		8'h7d: out<=15;		8'h7e: out<=15;		8'h7f: out<=15;		
8'h80: out<=15;		8'h81: out<=15;		8'h82: out<=15;		8'h83: out<=15;		
8'h84: out<=15;		8'h85: out<=15;		8'h86: out<=15;		8'h87: out<=15;		
8'h88: out<=15;		8'h89: out<=15;		8'h8a: out<=15;		8'h8b: out<=15;		
8'h8c: out<=15;		8'h8d: out<=15;		8'h8e: out<=15;		8'h8f: out<=15;		
8'h90: out<=15;		8'h91: out<=15;		8'h92: out<=15;		8'h93: out<=15;		
8'h94: out<=15;		8'h95: out<=15;		8'h96: out<=15;		8'h97: out<=15;		
8'h98: out<=15;		8'h99: out<=15;		8'h9a: out<=15;		8'h9b: out<=15;		
8'h9c: out<=15;		8'h9d: out<=15;		8'h9e: out<=15;		8'h9f: out<=15;		
8'ha0: out<=15;		8'ha1: out<=15;		8'ha2: out<=15;		8'ha3: out<=15;		
8'ha4: out<=15;		8'ha5: out<=15;		8'ha6: out<=15;		8'ha7: out<=15;		
8'ha8: out<=15;		8'ha9: out<=15;		8'haa: out<=15;		8'hab: out<=15;		
8'hac: out<=15;		8'had: out<=15;		8'hae: out<=15;		8'haf: out<=15;		
8'hb0: out<=15;		8'hb1: out<=15;		8'hb2: out<=15;		8'hb3: out<=15;		
8'hb4: out<=15;		8'hb5: out<=15;		8'hb6: out<=15;		8'hb7: out<=15;		
8'hb8: out<=15;		8'hb9: out<=15;		8'hba: out<=15;		8'hbb: out<=15;		
8'hbc: out<=15;		8'hbd: out<=15;		8'hbe: out<=15;		8'hbf: out<=15;		
8'hc0: out<=15;		8'hc1: out<=15;		8'hc2: out<=15;		8'hc3: out<=15;		
8'hc4: out<=15;		8'hc5: out<=15;		8'hc6: out<=15;		8'hc7: out<=15;		
8'hc8: out<=15;		8'hc9: out<=15;		8'hca: out<=15;		8'hcb: out<=15;		
8'hcc: out<=15;		8'hcd: out<=15;		8'hce: out<=15;		8'hcf: out<=15;		
8'hd0: out<=15;		8'hd1: out<=15;		8'hd2: out<=15;		8'hd3: out<=15;		
8'hd4: out<=15;		8'hd5: out<=15;		8'hd6: out<=15;		8'hd7: out<=15;		
8'hd8: out<=15;		8'hd9: out<=15;		8'hda: out<=15;		8'hdb: out<=15;		
8'hdc: out<=15;		8'hdd: out<=15;		8'hde: out<=15;		8'hdf: out<=15;		
8'he0: out<=15;		8'he1: out<=15;		8'he2: out<=15;		8'he3: out<=15;		
8'he4: out<=15;		8'he5: out<=15;		8'he6: out<=15;		8'he7: out<=15;		
8'he8: out<=15;		8'he9: out<=15;		8'hea: out<=15;		8'heb: out<=15;		
8'hec: out<=15;		8'hed: out<=15;		8'hee: out<=15;		8'hef: out<=15;		
8'hf0: out<=15;		8'hf1: out<=15;		8'hf2: out<=15;		8'hf3: out<=15;		
8'hf4: out<=15;		8'hf5: out<=15;		8'hf6: out<=15;		8'hf7: out<=15;		
8'hf8: out<=15;		8'hf9: out<=15;		8'hfa: out<=15;		8'hfb: out<=15;		
8'hfc: out<=15;		8'hfd: out<=15;		8'hfe: out<=15;		8'hff: out<=15;	
endcase
endmodule
