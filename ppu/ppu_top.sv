`ifndef _PPU_TOP_SV
`define _PPU_TOP_SV
`include "ppu_mem.sv"
`include "vga_palette.sv"
`include "vga_buffer.sv"
`include "ppu_nametable.sv"

module ppu_top(
    input logic             CLK, RESET,
                            mirroring_type,      // support horizontal mirroring and vertical mirroring of name table

    input logic [7:0]       reg_data_in,
    input logic [15:0]      addr,           // cpu addr
    input logic             r,w,
    output logic [7:0]      reg_data_out,

    output logic            NMI ,            // v blank
    output logic [15:0]     cpu_address_ext,
    input logic  [7:0]      cpu_data_ext,
    
    input        [9:0]      DrawX, DrawY,       // Current pixel coordinates
    output logic [7:0]      VGA_R, VGA_G, VGA_B // VGA RGB output

);
/*
https://wiki.nesdev.com/w/index.php/PPU_registers
7  bit  0
reg_status
VSO. ....
|||| ||||
|||+-++++- Least significant bits previously written into a PPU register
|||        (due to register not being updated for this address)
||+------- Sprite overflow. The intent was for this flag to be set
||         whenever more than eight sprites appear on a scanline, but a
||         hardware bug causes the actual behavior to be more complicated
||         and generate false positives as well as false negatives; see
||         PPU sprite evaluation. This flag is set during sprite
||         evaluation and cleared at dot 1 (the second dot) of the
||         pre-render line.
|+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
|          a nonzero background pixel; cleared at dot 1 of the pre-render
|          line.  Used for raster timing.
+--------- Vertical blank has started (0: not in vblank; 1: in vblank).
           Set at dot 1 of line 241 (the line *after* the post-render
           line); cleared after reading $2002 and at dot 1 of the
           pre-render line.
*/
            // 0x2000 w       2001 w     2002 r       2003 w    2004 rw      2005 w2    2006 w2    2007 rw   4014 w
    reg [7:0] reg_control, reg_mask, reg_status, 
              reg_OAMaddr, reg_OAMdata,   // may not used
              scroll_x, scroll_y, 
              PPUaddrL, PPUaddrH, PPUaddrL_next, PPUaddrH_next,
              reg_data,             // TODO: PPU rom r/w
              reg_OAMDMA;           // TODO: OAM r/w

    logic       set_sprite_hit;         // TODO: top level  rendering
    logic       sprite_hit_next;         // TODO: top level  rendering
    logic       set_vertical_blank;    // TODO: top level  rendering        NMI
    logic       vertical_blank_next;    // TODO: top level  rendering
    logic       clear_status;    // TODO: top level  rendering
/******************** PPU rom operation *************************/
    logic       PPUdata_r, PPUdata_r_prev,
                PPUdata_w, PPUdata_w_prev, 
                PPUaddr_inc;

    always_ff @(posedge CLK) begin
        PPUdata_r_prev <= PPUdata_r;
        PPUdata_w_prev <= PPUdata_w;
    end
    always_comb begin
        PPUdata_r = (addr==16'h2007 && r);
        PPUdata_w = (addr==16'h2007 && w);
        PPUaddr_inc = (PPUdata_r == 0 && PPUdata_r_prev == 1) | (PPUdata_w == 0 && PPUdata_w_prev == 1);
    end

    logic [7:0]  PPU_rom_data, rom_ext;      
    logic [15:0] address_ext;
    logic [15:0] buff_addr;        // buffer
    logic [7:0]  buff_data;
    logic        buff_w;
    logic [7:0]  PPU_color;
    logic [7:0]  VGA_palette_n;
    
    PPU_ROM PPU_ROM0( .w(PPUdata_w_prev), .address( {PPUaddrH, PPUaddrL} ), 
                        .data(reg_data), .out(PPU_rom_data), .out_ext(rom_ext), 
                         .address_palette(PPU_color[3:0]), .out_palette(VGA_palette_n), .*);

    vga_buffer vga_buffer0( 
        .w(buff_w), .address(buff_addr), .address_ext( {DrawY[7:0],DrawX[7:0] } ),
        .data(buff_data), .out_ext(PPU_color),
        .*  );  // TODO

    vga_palette vga_palette0(.n_color(VGA_palette_n[5:0]), .red(VGA_R), .blue(VGA_B), .green(VGA_G));

    // synthesis translate_off

    initial begin
        buff_store = $fopen("F:/fpgaNES/NES/ppu/ppu_buff.txt","w");
    end
    always  @(posedge buff_w)begin
            $fwrite(buff_store,"%4X\t%2d\n", buff_addr, buff_data );
    end
    // synthesis translate_on

/**************************** regs *******************************/
    always_ff @(posedge CLK) 
    begin
        if(RESET) 
        begin
            reg_control <= '0;
            reg_mask    <= '0;
            reg_status <= '0;
            reg_OAMaddr <= '0;
            reg_OAMdata <= '0;
            scroll_x <= '0;
            scroll_y <= '0;
            PPUaddrL <= '0;
            PPUaddrH <= '0;
            reg_data <= '0;
            reg_OAMDMA <= '0;
        end
        else 
        begin
            reg_control <= (addr==16'h2000 && w) ? reg_data_in : reg_control;
            reg_mask <= (addr==16'h2001 && w) ? reg_data_in : reg_mask;
            reg_status <= clear_status ? '0 : {vertical_blank_next,sprite_hit_next,6'b0};
            reg_OAMaddr <= (addr==16'h2003 && w) ? reg_data_in : reg_OAMaddr;
            reg_OAMdata <= (addr==16'h2004 && w) ? reg_data_in : reg_OAMdata;
            scroll_y <= (addr==16'h2005 && w) ? reg_data_in : scroll_y;
            scroll_x <= (addr==16'h2005 && w) ? scroll_y : scroll_x;
            PPUaddrL <= (addr==16'h2006 && w) ? reg_data_in : PPUaddrL_next;
            PPUaddrH <= (addr==16'h2006 && w) ? PPUaddrL : PPUaddrH_next;
            reg_data <= reg_data_in;
            reg_OAMDMA <= (addr==16'h4014 && w) ? reg_data_in : reg_OAMDMA;
        end
    end
    always_comb 
    begin
        case(addr) 
            16'h2000 : reg_data_out = reg_control;
            16'h2001 : reg_data_out = reg_mask;
            16'h2002 : reg_data_out = reg_status;
            16'h2007 : reg_data_out = PPU_rom_data;
            default :  reg_data_out = '0; 
        endcase

        if (set_vertical_blank)
            vertical_blank_next = 1;
        else if (r)
            vertical_blank_next = 0;
        else
            vertical_blank_next = reg_status[7];

        if (set_sprite_hit)
            sprite_hit_next = 1;
        else 
            sprite_hit_next = reg_status[6];
    end
    /*
    7  bit  0
---- ----
.... ..YX
       ||
       |+- 1: Add 256 to the X scroll position
       +-- 1: Add 240 to the Y scroll position
    */
    logic [1:0]     base_nametable;
    logic           VRAM_addr_increment;    //VRAM address increment per CPU read/write of PPUDATA 0:+1 1:+32
    logic           sprite_pattern_table;   // 0: $0000; 1: $1000; ignored in 8x16 mode
    logic           background_pattern_table;   //  0: $0000; 1: $1000
    logic           sprite_size;   //  (0: 8x8 pixels; 1: 8x16 pixels)
    logic           NMI_enable;   //  Generate an NMI at the start of the vertical blanking interval (0: off; 1: on)
    
    logic           background_mask;    // 1: Show background in leftmost 8 pixels of screen, 0: Hide
    logic           sprites_mask;       // 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
    logic           background_show;    // 1: Show background
    logic           sprites_show;       // 1: Show sprites

    
    always_comb begin
        base_nametable = reg_control[1:0];      // TODO: background rendering  
        VRAM_addr_increment = reg_control[2];   // 
        sprite_pattern_table = reg_control[3];  // TODO: sprite rendering
        background_pattern_table = reg_control[4]; // TODO: background rendering  
        sprite_size = reg_control[5];           // TODO: sprite rendering
        NMI_enable = reg_control[7];            // TODO: top level  rendering

        background_mask = reg_mask[1];          // TODO: top level  rendering
        sprites_mask = reg_mask[2];             // TODO: top level  rendering
        background_show = reg_mask[3];          // TODO: top level  rendering
        sprites_show = reg_mask[4];             // TODO: top level  rendering

        {PPUaddrH_next, PPUaddrL_next} = {PPUaddrH_next, PPUaddrL_next} + (PPUaddr_inc ? (VRAM_addr_increment ? 16'd32 : 16'b0):'0);
    end

    logic [8:0]    scroll_x_in, scroll_y_in;
    assign scroll_x_in = reg_control[0] ? 9'(scroll_x) + 9'd256 : 9'(scroll_x);
    assign scroll_y_in = reg_control[1] ? 9'(scroll_y) + 9'd240 : 9'(scroll_y);

    render_screen render_screen0(
        .*, 
        .pattern_select(background_pattern_table) );

    assign NMI = set_vertical_blank & NMI_enable;

endmodule



`endif
