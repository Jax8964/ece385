/*  input: opcodes
 *  output: 0 if invaild, # clock circles if vaild (151 vaild opcodes)
 *
 */
module opcode_timing (
	input  logic CLK,
	input  logic [7:0] in,
	output logic [7:0] out
);

// This module will be synthesized into a RAM
always_ff @ (negedge CLK)
	case (in)
	8'h00: out <= 8'd00;    8'h01: out <= 8'd00;    8'h02: out <= 8'd00;    8'h03: out <= 8'd00;
	8'h04: out <= 8'd00;    8'h05: out <= 8'd00;    8'h06: out <= 8'd00;    8'h07: out <= 8'd00;
	8'h08: out <= 8'd00;    8'h09: out <= 8'd00;    8'h0a: out <= 8'd00;    8'h0b: out <= 8'd00;
	8'h0c: out <= 8'd00;    8'h0d: out <= 8'd00;    8'h0e: out <= 8'd00;    8'h0f: out <= 8'd00;
	8'h10: out <= 8'd00;    8'h11: out <= 8'd00;    8'h12: out <= 8'd00;    8'h13: out <= 8'd00;
	8'h14: out <= 8'd00;    8'h15: out <= 8'd00;    8'h16: out <= 8'd00;    8'h17: out <= 8'd00;
	8'h18: out <= 8'd00;    8'h19: out <= 8'd00;    8'h1a: out <= 8'd00;    8'h1b: out <= 8'd00;
	8'h1c: out <= 8'd00;    8'h1d: out <= 8'd00;    8'h1e: out <= 8'd00;    8'h1f: out <= 8'd00;
	8'h20: out <= 8'd00;    8'h21: out <= 8'd00;    8'h22: out <= 8'd00;    8'h23: out <= 8'd00;
	8'h24: out <= 8'd00;    8'h25: out <= 8'd00;    8'h26: out <= 8'd00;    8'h27: out <= 8'd00;
	8'h28: out <= 8'd00;    8'h29: out <= 8'd00;    8'h2a: out <= 8'd00;    8'h2b: out <= 8'd00;
	8'h2c: out <= 8'd00;    8'h2d: out <= 8'd00;    8'h2e: out <= 8'd00;    8'h2f: out <= 8'd00;
	8'h30: out <= 8'd00;    8'h31: out <= 8'd00;    8'h32: out <= 8'd00;    8'h33: out <= 8'd00;
	8'h34: out <= 8'd00;    8'h35: out <= 8'd00;    8'h36: out <= 8'd00;    8'h37: out <= 8'd00;
	8'h38: out <= 8'd00;    8'h39: out <= 8'd00;    8'h3a: out <= 8'd00;    8'h3b: out <= 8'd00;
	8'h3c: out <= 8'd00;    8'h3d: out <= 8'd00;    8'h3e: out <= 8'd00;    8'h3f: out <= 8'd00;
	8'h40: out <= 8'd00;    8'h41: out <= 8'd00;    8'h42: out <= 8'd00;    8'h43: out <= 8'd00;
	8'h44: out <= 8'd00;    8'h45: out <= 8'd00;    8'h46: out <= 8'd00;    8'h47: out <= 8'd00;
	8'h48: out <= 8'd00;    8'h49: out <= 8'd00;    8'h4a: out <= 8'd00;    8'h4b: out <= 8'd00;
	8'h4c: out <= 8'd10;    8'h4d: out <= 8'd00;    8'h4e: out <= 8'd00;    8'h4f: out <= 8'd00;
	8'h50: out <= 8'd00;    8'h51: out <= 8'd00;    8'h52: out <= 8'd00;    8'h53: out <= 8'd00;
	8'h54: out <= 8'd00;    8'h55: out <= 8'd00;    8'h56: out <= 8'd00;    8'h57: out <= 8'd00;
	8'h58: out <= 8'd00;    8'h59: out <= 8'd00;    8'h5a: out <= 8'd00;    8'h5b: out <= 8'd00;
	8'h5c: out <= 8'd00;    8'h5d: out <= 8'd00;    8'h5e: out <= 8'd00;    8'h5f: out <= 8'd00;
	8'h60: out <= 8'd00;    8'h61: out <= 8'd00;    8'h62: out <= 8'd00;    8'h63: out <= 8'd00;
	8'h64: out <= 8'd00;    8'h65: out <= 8'd00;    8'h66: out <= 8'd00;    8'h67: out <= 8'd00;
	8'h68: out <= 8'd00;    8'h69: out <= 8'd00;    8'h6a: out <= 8'd00;    8'h6b: out <= 8'd00;
	8'h6c: out <= 8'd10;    8'h6d: out <= 8'd00;    8'h6e: out <= 8'd00;    8'h6f: out <= 8'd00;
	8'h70: out <= 8'd00;    8'h71: out <= 8'd00;    8'h72: out <= 8'd00;    8'h73: out <= 8'd00;
	8'h74: out <= 8'd00;    8'h75: out <= 8'd00;    8'h76: out <= 8'd00;    8'h77: out <= 8'd00;
	8'h78: out <= 8'd00;    8'h79: out <= 8'd00;    8'h7a: out <= 8'd00;    8'h7b: out <= 8'd00;
	8'h7c: out <= 8'd00;    8'h7d: out <= 8'd00;    8'h7e: out <= 8'd00;    8'h7f: out <= 8'd00;
	8'h80: out <= 8'd00;    8'h81: out <= 8'd00;    8'h82: out <= 8'd00;    8'h83: out <= 8'd00;
	8'h84: out <= 8'd00;    8'h85: out <= 8'd00;    8'h86: out <= 8'd00;    8'h87: out <= 8'd00;
	8'h88: out <= 8'd00;    8'h89: out <= 8'd00;    8'h8a: out <= 8'd00;    8'h8b: out <= 8'd00;
	8'h8c: out <= 8'd00;    8'h8d: out <= 8'd00;    8'h8e: out <= 8'd00;    8'h8f: out <= 8'd00;
	8'h90: out <= 8'd00;    8'h91: out <= 8'd00;    8'h92: out <= 8'd00;    8'h93: out <= 8'd00;
	8'h94: out <= 8'd00;    8'h95: out <= 8'd00;    8'h96: out <= 8'd00;    8'h97: out <= 8'd00;
	8'h98: out <= 8'd00;    8'h99: out <= 8'd00;    8'h9a: out <= 8'd00;    8'h9b: out <= 8'd00;
	8'h9c: out <= 8'd00;    8'h9d: out <= 8'd00;    8'h9e: out <= 8'd00;    8'h9f: out <= 8'd00;
	8'ha0: out <= 8'd00;    8'ha1: out <= 8'd00;    8'ha2: out <= 8'd00;    8'ha3: out <= 8'd00;
	8'ha4: out <= 8'd00;    8'ha5: out <= 8'd00;    8'ha6: out <= 8'd00;    8'ha7: out <= 8'd00;
	8'ha8: out <= 8'd00;    8'ha9: out <= 8'd00;    8'haa: out <= 8'd00;    8'hab: out <= 8'd00;
	8'hac: out <= 8'd00;    8'had: out <= 8'd00;    8'hae: out <= 8'd00;    8'haf: out <= 8'd00;
	8'hb0: out <= 8'd00;    8'hb1: out <= 8'd00;    8'hb2: out <= 8'd00;    8'hb3: out <= 8'd00;
	8'hb4: out <= 8'd00;    8'hb5: out <= 8'd00;    8'hb6: out <= 8'd00;    8'hb7: out <= 8'd00;
	8'hb8: out <= 8'd00;    8'hb9: out <= 8'd00;    8'hba: out <= 8'd00;    8'hbb: out <= 8'd00;
	8'hbc: out <= 8'd00;    8'hbd: out <= 8'd00;    8'hbe: out <= 8'd00;    8'hbf: out <= 8'd00;
	8'hc0: out <= 8'd00;    8'hc1: out <= 8'd00;    8'hc2: out <= 8'd00;    8'hc3: out <= 8'd00;
	8'hc4: out <= 8'd00;    8'hc5: out <= 8'd00;    8'hc6: out <= 8'd00;    8'hc7: out <= 8'd00;
	8'hc8: out <= 8'd00;    8'hc9: out <= 8'd00;    8'hca: out <= 8'd00;    8'hcb: out <= 8'd00;
	8'hcc: out <= 8'd00;    8'hcd: out <= 8'd00;    8'hce: out <= 8'd00;    8'hcf: out <= 8'd00;
	8'hd0: out <= 8'd00;    8'hd1: out <= 8'd00;    8'hd2: out <= 8'd00;    8'hd3: out <= 8'd00;
	8'hd4: out <= 8'd00;    8'hd5: out <= 8'd00;    8'hd6: out <= 8'd00;    8'hd7: out <= 8'd00;
	8'hd8: out <= 8'd00;    8'hd9: out <= 8'd00;    8'hda: out <= 8'd00;    8'hdb: out <= 8'd00;
	8'hdc: out <= 8'd00;    8'hdd: out <= 8'd00;    8'hde: out <= 8'd00;    8'hdf: out <= 8'd00;
	8'he0: out <= 8'd00;    8'he1: out <= 8'd00;    8'he2: out <= 8'd00;    8'he3: out <= 8'd00;
	8'he4: out <= 8'd00;    8'he5: out <= 8'd00;    8'he6: out <= 8'd00;    8'he7: out <= 8'd00;
	8'he8: out <= 8'd00;    8'he9: out <= 8'd00;    8'hea: out <= 8'd00;    8'heb: out <= 8'd00;
	8'hec: out <= 8'd00;    8'hed: out <= 8'd00;    8'hee: out <= 8'd00;    8'hef: out <= 8'd00;
	8'hf0: out <= 8'd00;    8'hf1: out <= 8'd00;    8'hf2: out <= 8'd00;    8'hf3: out <= 8'd00;
	8'hf4: out <= 8'd00;    8'hf5: out <= 8'd00;    8'hf6: out <= 8'd00;    8'hf7: out <= 8'd00;
	8'hf8: out <= 8'd00;    8'hf9: out <= 8'd00;    8'hfa: out <= 8'd00;    8'hfb: out <= 8'd00;
	8'hfc: out <= 8'd00;    8'hfd: out <= 8'd00;    8'hfe: out <= 8'd00;    8'hff: out <= 8'd00;
	endcase
endmodule