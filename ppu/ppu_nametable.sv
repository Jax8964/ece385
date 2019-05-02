`ifndef _PPU_NAMETABLE_SV
`define _PPU_NAMETABLE_SV
`include "ppu_counter.sv"
/* our vga screen: x--> 640     y |             640 width x 480 height
                                  v 480
http://wiki.nesdev.com/w/index.php/PPU_rendering
PPU clock speed	21.477272 MHz ÷ 4           we use 50 MHz ÷ 9 (9 period)   then cpu 50 MHz ÷ 27
PPU dots per CPU cycle	3                   CPU cycles per scanline	341 × 4÷12 =113 2⁄3
The PPU renders 262 (0~261) scanlines       scanline lasts for 341 PPU clock cycles
Height of picture	240 scanlines           Length of vertical blanking after NMI	20 scanlines

Pre-render scanline             #261        fill the shift registers (no output)
Visible scanlines               (0-239)
|   Cycles 1-256
|       The data for each tile is fetched during this phase. Each memory access takes 2 PPU cycles to complete, and 4 must be performed per tile:
|   Cycles 257-320
|       The tile data for the sprites on the next scanline are fetched here. Again, each memory access takes 2 PPU cycles to complete, and 4 are performed for each of the 8 sprites:
|   Cycles 321-336
|       This is where the first two tiles for the next scanline are fetched, and loaded into the shift registers.
|   Cycles 337-340
|       Two bytes are fetched, but the purpose for this is unknown
Post-render scanline            (240)
    The PPU just idles during this scanline. Even though accessing PPU memory from the program would be safe here, the VBlank flag isn't set until after this scanline.
Vertical blanking lines         (241-260)
    The VBlank flag of the PPU is set at tick 1 (the second tick) of scanline 241, where the VBlank NMI also occurs
*/

module render_screen(
       input logic          CLK, RESET,
       input logic [8:0]    scroll_x_in, scroll_y_in,  // 0~511,  | 0~479, 

       output logic [15:0]  address_ext,         // rom
       input logic  [7:0]   rom_ext,
       input logic          pattern_select,

       output logic [4:0]   palette_addr,        // palette
       input  logic [7:0]   palette_out,

       output logic [15:0]  buff_addr,           // buffer
       output logic [7:0]   buff_data,
       output logic         buff_w,

       output logic         clear_status, set_vertical_blank

);

       logic  counter_halt;
       logic [11:0]  counter;
       logic [8:0]   counter_up, counter_max;
       ppu_counter1 ppu_counter11(.*, .reset(RESET), .halt(counter_halt), .max(counter_max) );
       always_comb begin
              counter_halt = '0;
              counter_up = counter[11:3]; 
       end
       logic [8:0]   n_scanlines, n_scanlines_prev;         // 0 ~ 260
       logic n_scanlines_reset;
       logic counter_end;
       always_ff @(posedge CLK) begin
              counter_max <= 9'd339;
              n_scanlines <= n_scanlines;
              n_scanlines_prev <= n_scanlines;
              n_scanlines_reset <= (n_scanlines == 9'd261);
              counter_end <= counter == {9'd300,3'b0};
              if(RESET) begin
                     n_scanlines <= '0;
              end
              else if (counter_end)
                     n_scanlines <=  n_scanlines_reset ? '0 : n_scanlines_prev + 9'd1 ;
       end

       logic         prepare;
       assign        prepare = (counter == '0 && n_scanlines < 9'd240 );
       always_comb begin
              clear_status = n_scanlines == 0 && counter == '0;
              set_vertical_blank = n_scanlines ==240 && counter == '0;
       end 
       rendering_scanline rendering_scanline0(.*, .dy_line(n_scanlines[7:0]) );  
  
       
endmodule



typedef enum logic  [3:0]    { 

              line_prepare_, 
              line_start_, 
              line_write_, line_write_1,
              line_finish_ 

} line_state_t;

module rendering_scanline(
       input logic          CLK, RESET,
       input logic [8:0]    scroll_x_in, scroll_y_in,  // 0~511,  | 0~479, 
       input logic [7:0]    dy_line,              // in camera, 0 ~ 240
       input logic          prepare, 

       output logic [15:0]  address_ext,         // rom
       input logic  [7:0]   rom_ext,
       input logic          pattern_select,

       output logic [4:0]   palette_addr,
       input  logic [7:0]   palette_out,

       output logic [15:0]  buff_addr,           // buffer
       output logic [7:0]   buff_data,
       output logic         buff_w

);

       logic  [8:0]         scroll_x, scroll_y, scroll_y_next;
       assign               scroll_y_next = scroll_y_in + 9'(dy_line);
       
       logic [4:0]          dx;           // 0 ~ 31
       logic                dx_inc;       // tiles in oneline

       line_state_t state, state_next;

       always_ff @(posedge CLK) begin
              if(RESET)
                     state <=   line_finish_;
              else 
                     state <=   state_next;

              scroll_x <= prepare ? scroll_x_in : scroll_x;
              scroll_y <= prepare ? scroll_y_next : scroll_y;
              dx       <= prepare ? '0 : dx + 5'(dx_inc);
       end

       logic [5:0]    rough_scroll_x, rough_scroll_y;
       logic [2:0]   fine_scroll_x, fine_scroll_y;
       assign rough_scroll_x = scroll_x[8:3] + {1'b0,dx};      // unit: tile        whole map
       assign rough_scroll_y = scroll_y[8:3] ;                        // whole map
       assign fine_scroll_x  = scroll_x[2:0] ;          // offset inside one tile 
       assign fine_scroll_y  = scroll_y[2:0] ;

       logic render_8pixel;
       logic [7:0]   color0, color1, color2, color3;
       rendering_get_8pixel rendering_get_8pixel0(.*, .start(render_8pixel));              // get 8 pixcel


       logic  counter_reset, counter_halt;
       logic [11:0]  counter;
       ppu_counter1 ppu_counter111(.*, .reset(counter_reset), .halt(counter_halt), .max('1) );
        
       assign render_8pixel = counter[5:3] == 3'd0;     // every eight ticks
       

       logic [15:0] color0_buf, color1_buf, color2_buf, color3_buf;
       logic [2:0] ticks;
       assign ticks = counter[5:3];

       always_ff @(posedge counter[2]) begin            // shift or load every tick
              color0_buf = ticks == 3'd7 ? {color0_buf[14:7], color0} : {color0_buf[14:0], 1'b0};
              color1_buf = ticks == 3'd7 ? {color1_buf[14:7], color1} : {color1_buf[14:0], 1'b0};
              color2_buf = ticks == 3'd7 ? {color2_buf[14:7], color2} : {color2_buf[14:0], 1'b0};
              color3_buf = ticks == 3'd7 ? {color3_buf[14:7], color3} : {color3_buf[14:0], 1'b0};
       end

       always_comb begin
              palette_addr = {1'b0,  color3_buf[15], color2_buf[15], color1_buf[15], color0_buf[15]};
              buff_data = palette_out;
              buff_addr = {scroll_y[7:0], dx - 5'd2, ticks};
              buff_w = '0;
              counter_reset = 0;
              counter_halt = 0;
              dx_inc = 0;
              state_next = line_finish_;
              case(state)
                     line_prepare_: 
                     begin
                            if(counter[5:0] == 6'b111110) // tick = 7.75
                            begin
                                   dx_inc = '1;
                                   state_next = line_start_;
                            end
                            else 
                                   state_next = line_prepare_;
                     end
                     line_start_: 
                     begin
                            if(counter[5:0] == 6'b111110)      // tick = 7.75
                            begin
                                   dx_inc = '1;
                                   state_next = line_write_;
                            end
                            else 
                                   state_next = line_start_;
                     end
                     line_write_: 
                     begin
                            if(ticks == fine_scroll_x) 
                            begin
                                   state_next = line_write_1;
                            end
                            else 
                                   state_next = line_write_;
                     end
                     line_write_1: 
                     begin
                            dx_inc = counter[5:0] == 6'b111101;       // tick = 7.75
                            buff_w = counter[2:0] == 3'b010;
                            if(counter == {(9'(fine_scroll_x) + 255 + 16), 3'b011} ) 
                            begin
                                   state_next = line_finish_;
                            end
                            else 
                                   state_next = line_write_1;
                     end
                     line_finish_: begin
                            counter_reset = 1;
                            state_next = prepare ? line_prepare_ : line_finish_;
                     end
                     default : ;
              endcase
       end


endmodule


typedef enum logic  [3:0]    { 

       render8_start_, render8_start_1, render8_start_2,
       render8_attri_, render8_attri_1,
       render8_pattern_, render8_pattern_1, render8_pattern_2, render8_pattern_3,
       render8_done

} pixel_state_t;

module rendering_get_8pixel(
       input logic          CLK, RESET,
       input logic [5:0]    rough_scroll_x, rough_scroll_y,   // 0 ~ 64
       input logic [2:0]    fine_scroll_y,

       input logic          start,

       output logic [15:0]  address_ext,         //
       input logic  [7:0]   rom_ext,
       input logic          pattern_select,

       output logic [7:0]   color0, color1, color2, color3
);

       logic [15:0]  nametable_addr, attribute_addr;
       logic [2:0]   attribute_byte_offset;
       nametable_info nametable_info0(.*);

       pixel_state_t state, state_next;

       logic [7:0]   color0_next, color1_next, color2_next, color3_next;
       logic [7:0]   n_pattern, n_pattern_next;
       logic [15:0]   color0_addr, color1_addr;

       pattern_adressing pattern_adressing0(.*);

       logic         attr_temp[7:0];
       always_comb begin
              attr_temp[0] = rom_ext[0];
              attr_temp[1] = rom_ext[1];
              attr_temp[2] = rom_ext[2];
              attr_temp[3] = rom_ext[3];
              attr_temp[4] = rom_ext[4];
              attr_temp[5] = rom_ext[5];
              attr_temp[6] = rom_ext[6];
              attr_temp[7] = rom_ext[7];
       end
       logic         attr2, attr3;
       assign        attr2 = attr_temp[attribute_byte_offset];
       assign        attr3 = attr_temp[attribute_byte_offset+1];


       always_ff @(posedge CLK) begin
              state <= start ? render8_start_ : state_next;
              n_pattern <= n_pattern_next;
              color0 <= color0_next;
              color1 <= color1_next;
              color2 <= color2_next;
              color3 <= color3_next;
       end
       always_comb begin
              state_next = render8_done;
              color0_next = color0;
              color1_next = color1;
              color2_next = color2;
              color3_next = color3;
              n_pattern_next = n_pattern;
              address_ext = '0;
              case (state)
                     render8_start_ : begin
                            address_ext = nametable_addr;
                            state_next = render8_start_1;
                     end
                     render8_start_1 : begin
                            address_ext = nametable_addr;
                            n_pattern_next = rom_ext;
                            state_next = render8_start_2;
                     end  
                     render8_start_2 : begin
                            address_ext = nametable_addr;
                            n_pattern_next = rom_ext;
                            state_next = render8_attri_;
                     end    
                     render8_attri_ : begin
                            address_ext = attribute_addr;
                            color2_next = {8{attr2}};
                            color3_next = {8{attr3}};
                            state_next = render8_attri_1;
                     end      
                     render8_attri_1 : begin
                            address_ext = attribute_addr;
                            color2_next = {8{attr2}};
                            color3_next = {8{attr3}};
                            state_next = render8_pattern_;
                     end      
                     render8_pattern_ : begin
                            address_ext = color0_addr;
                            color0_next = rom_ext;
                            state_next = render8_pattern_1;
                     end    
                     render8_pattern_1 : begin
                            address_ext = color0_addr;
                            color0_next = rom_ext;
                            state_next = render8_pattern_2;
                     end
                     render8_pattern_2 : begin
                            address_ext = color1_addr;
                            color1_next = rom_ext;
                            state_next = render8_pattern_3;
                     end    
                     render8_pattern_3 : begin
                            address_ext = color1_addr;
                            color1_next = rom_ext;
                            state_next = render8_done;
                     end         
                     default : ;
              endcase
       end

endmodule



// https://wiki.nesdev.com/w/index.php/PPU_attribute_tables
module pattern_adressing(
       input logic [7:0]     n_pattern,       // 0 ~ 255
       input logic           pattern_select,
       input logic [2:0]     fine_scroll_y,

       output logic [15:0]    color0_addr, color1_addr
);
       logic [11:0]  base_addr;
       always_comb begin
              base_addr = {3'b0, pattern_select, n_pattern};
              color0_addr = {base_addr, 1'b0, fine_scroll_y};
              color1_addr = {base_addr, 1'b1, fine_scroll_y};
       end


       
endmodule




module nametable_info(             // keep input, wait for 2 circle
       input logic          CLK, RESET,
       input logic [5:0]    rough_scroll_x, rough_scroll_y,   // 0 ~ 64

       output logic [15:0]  nametable_addr, attribute_addr,    // 
       output logic [2:0]   attribute_byte_offset              // get color info
);

       logic [4:0]     tile_x, tile_y;                          // 0 ~ 32
       logic [1:0]     cout;
       mod32 mod32_(.*, .x_all(rough_scroll_x), .cout(cout[0]), .x_out(tile_x) );
       mod30 mod30_(.*, .y_all(rough_scroll_y), .cout(cout[1]), .y_out(tile_y) );

       logic [15:0] base_addr;
       logic [9:0]  n_tile;            // 0 ~ 960
       logic [5:0]  n_attribute;          // 0 ~ 63
       always_comb begin
              case(cout)
                     2'b00: base_addr = 16'h2000;
                     2'b01: base_addr = 16'h2400;
                     2'b10: base_addr = 16'h2800;
                     2'b11: base_addr = 16'h2c00;
              endcase
              n_tile = {tile_y, tile_x}; // y x 32 + x
              n_attribute = {tile_y[4:2], tile_x[4:2]};
       end
       always_ff @(posedge CLK) begin
              nametable_addr <= 16'(n_tile) + base_addr;// n_tile + base 
              attribute_addr <= 16'(n_attribute) + base_addr + 16'd960;
              attribute_byte_offset <= {tile_y[1], tile_x[1], 1'b0};
       end

endmodule










module mod32(
       input logic CLK,
       input logic [5:0] x_all,
       output logic cout,
       output logic [4:0] x_out                  // < 32
);
       assign  cout = x_all[5];
       always_ff @(posedge CLK) begin
              x_out <= x_all[4:0];
       end  
endmodule


module mod30(
       input logic CLK,
       input logic [5:0] y_all,
       output logic cout,
       output logic [4:0] y_out                  // < 30
);
       logic [5:0] y_dec, y_temp;
       logic cout_next, below30, below60;
       always_comb begin
              below30 = y_all < 30;
              below60 = y_all >= 30 && y_all < 60;
              case({below30,below60})
                     2'b10: begin
                            y_dec = 0;
                            cout_next = 0;
                     end
                     2'b01: begin
                            y_dec = 30;
                            cout_next = 1;
                     end
                     default: begin
                            y_dec = 60;
                            cout_next = 0;
                     end
              endcase
              y_temp = 6'(y_all - y_dec);
       end
       always_ff @(posedge CLK) begin
              y_out <= y_temp[4:0];
              cout <= cout_next;
       end
endmodule




`endif