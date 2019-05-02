`ifndef _PPU_MEM_SV
`define _PPU_MEM_SV

/*
    https://wiki.nesdev.com/w/index.php/PPU_memory_map
    Address range	Size	Description
    $0000-$0FFF	$1000	Pattern table 0     16byte x 256      8byte: color[0]  8byte: clolor[1]
    $1000-$1FFF	$1000	Pattern table 1     16byte x 256
    $2000-$23FF	$0400	Nametable 0         32 x 30 x 1byte (#tile) + 64byte (attribute) = 960 + 64 = 1024
    $2400-$27FF	$0400	Nametable 1
    $2800-$2BFF	$0400	Nametable 2
    $2C00-$2FFF	$0400	Nametable 3
    $3000-$3EFF	$0F00	Mirrors of $2000-$2EFF
    $3F00-$3F1F	$0020	Palette RAM indexes         32 byte
    $3F20-$3FFF	$00E0	Mirrors of $3F00-$3F1F      32 * 7 byte

 |  $3F20   |  $3FFF   | 调色板镜像。              |（上面的） 
       |          |          |                           |（背景调色板） 
       |          |          | $3F20 - $3F2F：背景调色板 |（精灵调色板） 
       |          |          |                的镜像。   |（的 7 次镜像） 
       |          |          | $3F30 - $3F3F：精灵调色板 |（共 224 字节） 
       |          |          |                的镜像。   | 
       |          |          | $3F40 - $3F4F：背景调色板 |（若连同上面本身的） 
       |          |          |                的镜像。   |（两个调色板） 
       |          |          | $3F50 - $3F5F：精灵调色板 |（共 256 字节） 
       |          |          |                的镜像。   | 

pattern:
       前 8 个字节： 
       每个字节由 8 个二进制位组成，每个位描述一个像素颜色值的 
       第 0 位。一个字节（8个位）恰好描述一行像素颜色值的第 0 
       位。8个字节描述一个 Tile 所有像素的颜色值第 0 位。 
       后 8 个字节： 
       每个字节由 8 个二进制位组成，每个位描述一个像素颜色值的 
       第 1 位。一个字节（8个位）恰好描述一行像素颜色值的第 1 
       位。8个字节描述一个 Tile 所有像素的颜色值第 1 位。 
       由此可见，每个 Tile 所表现的色彩范围是 2 位
Attribute:
       Attribute 表中，每个字节（姑且称为 Attribute 字节）描述 
       了屏幕上 4x4 个 Tile （姑且把这个 4x4 的 Tile 区域称为 
       “描述区”）的高 2 位，具体定义如下： 

       Attribute 字节位                   定义 
       ----------------  ------------------------------------ 
            0 - 1        描述区中左上角 2x2 个 Tile 的高 2 位。 
            2 - 3        描述区中右上角 2x2 个 Tile 的高 2 位。 
            4 - 5        描述区中左下角 2x2 个 Tile 的高 2 位。 
            6 - 7        描述区中右上角 2x2 个 Tile 的高 2 位
        8 x 8 = 64 byte

    https://wiki.nesdev.com/w/index.php/Mirroring

*/
module PPU_ROM(              // data vaild at current circle 
    input logic         CLK,
    input logic         w, mirroring_type,
    input logic [15:0]  address, address_ext, 
    input logic [4:0]   address_palette,
    input logic [7:0]   data,

    output logic [7:0]  out, out_ext, out_palette
);
    logic [7:0] ram [0:14'h3fff];
    logic [7:0] palette_ [0:31];
    logic [13:0] real_address, real_address_ext; 
    VROM_addrmap VROM_addrmap0(.*, .addr_in(address), .addr_out(real_address));
    VROM_addrmap VROM_addrmap1(.*, .addr_in(real_address_ext), .addr_out(real_address_ext));

    initial begin
        $readmemh("F:/fpgaNES/NES/ppu/mali.txt",ram);
    end
    always @(negedge CLK) begin
        if(w)
            ram[real_address] <= data;
        if(address[13:12] == 2'h3 && address[11:8] == 4'hf && w)
            palette_[address[4:0]] <= data;
        out = ram[real_address];
        out_ext = ram[real_address_ext];
        out_palette = palette_[address_palette];
    end

endmodule


`endif

























module VROM_addrmap(
    input logic [15:0]  addr_in,
    input logic         mirroring_type,
    output logic [13:0] addr_out
);
    
always_comb begin
    case({addr_in[13]==1'b0, (addr_in[13:12] == 2'h2) | (addr_in[13:12] == 2'h3 && addr_in[11:8] != 4'hf), addr_in[13:12] == 2'h3 && addr_in[11:8] == 4'hf })
        3'b100:
            addr_out = addr_in[13:0];
        3'b010: begin
            if (mirroring_type)         // horizontal mirroring, which makes a 32x60 tilemap.
                addr_out = {2'b10, addr_in[11], 1'b0, addr_in[7:0]};
            else                    // vertical mirroring, which makes a 64x30 tilemap.
                addr_out = {3'b100, addr_in[10:0]};
        end
        3'b001:
            addr_out = {9'b111111000,addr_in[4:0]}; 
        default: 
            addr_out = addr_in[13:0];
    endcase

end

endmodule