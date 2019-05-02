//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------
`ifndef  _NES_PURE_SV
`define  _NES_PURE_SV
`include "cpu6502/cpu6502_top.sv" 
`include "ppu/ppu_top.sv" 

module NES_pure( input            CLOCK_50,
            input        [3:0]   KEY,          //bit 0 is set up as Reset
            input logic [17:0]   SW,
            output logic [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
            output logic [17:0]     LEDR,
            output logic [7:0]      LEDG,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS       //VGA horizontal sync signal
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
	 logic [9:0] DrawX, DrawY;
    
													
    logic NMI;
    logic [7:0]         reg_data_in, reg_data_out;  //ppu
    logic [15:0]        addr;
    logic               ppu_reg_w, ppu_reg_r;
    logic [15:0]        cpu_address_ext;
    logic  [7:0]        cpu_data_ext;
    
    cpu6502_top cpu6502_top0( .*, .RESET(Reset_h),
                              .ppu_reg_data(reg_data_out), 
                              .ALU_data_out(reg_data_in),
                              .address_ext(cpu_address_ext),
                              .mem_data_ext(cpu_data_ext)
    );
    ppu_top ppu_top0(   .*, 
                        .CLK(CLOCK_50), .RESET(Reset_h),
                        .mirroring_type(SW[0]),
                        .r(ppu_reg_r), 
                        .w(ppu_reg_w)
                 );


	 
    // Display keycode on hex display
   // HexDriver hex_inst_0 (keycode[3:0], HEX0);
   // HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule


`endif
