`ifndef _MEMIO_SV
`define _MEMIO_SV
/*
 *      deal with MDR, MAR
        https://wiki.nesdev.com/w/index.php/CPU_memory_map
 *      $2000-$2007	$0008	NES PPU registers
        $2008-$3FFF	$1FF8	Mirrors of $2000-2007 (repeats every 8 bytes)
        https://wiki.nesdev.com/w/index.php/Standard_controller
        $4016/$4017  

        https://wiki.nesdev.com/w/index.php/CPU_memory_map
        Address range	Size	Device
        $0000-$07FF	$0800	2KB internal RAM
        $0800-$0FFF	$0800	Mirrors of $0000-$07FF
        $1000-$17FF	$0800
        $1800-$1FFF	$0800
        $2000-$2007	$0008	NES PPU registers
        $2008-$3FFF	$1FF8	Mirrors of $2000-2007 (repeats every 8 bytes)
        $4000-$4017	$0018	NES APU and I/O registers
        $4018-$401F	$0008	APU and I/O functionality that is normally disabled. See CPU Test Mode.
        $4020-$FFFF	$BFE0	Cartridge space: PRG ROM, PRG RAM, and mapper registers (See Note)
        See Sample RAM map for an example allocation strategy for the 2KB of internal RAM at $0000-$0800.

        Note: Most common boards and iNES mappers address ROM and Save/Work RAM in this format:

        $6000-$7FFF = Battery Backed Save or Work RAM
        $8000-$FFFF = Usual ROM, commonly with Mapper Registers (see MMC1 and UxROM for example)
        The CPU expects interrupt vectors in a fixed place at the end of the cartridge space:

        $FFFA-$FFFB = NMI vector
        $FFFC-$FFFD = Reset vector
        $FFFE-$FFFF = IRQ/BRK vector

 */
module MemIO(             
    input logic CLK, RESET,

    input logic [15:0] addr,
    input logic w,                  // 1 read
                r,                  // 1 write 
                MEM_LDMDRH,         // load data to MDRH
                MEM_LDMDRL,         // load data to MDRL
                MEM_LDMAR,          // load addr to MAR

    output logic [7:0] MDRL, MDRH,
    output logic [15:0] MAR,

    input logic [7:0]  mem_data, gamepad_data, ppu_reg_data,
    output logic mem_w, mem_r, gamepad_w, gamepad_r, ppu_reg_w, ppu_reg_r
);

    logic [7:0] data;
    always_comb begin
        mem_w = 0;
        mem_r = 0;
        gamepad_w = 0; 
        gamepad_r = 0;
        ppu_reg_w = 0; 
        ppu_reg_r = 0;
        if (addr[15:13] == 3'b001) begin
            ppu_reg_w = w;
            ppu_reg_r = r;
            data = ppu_reg_data;
        end
        else if (addr[15:1] == 15'h200b) begin
            gamepad_w = w;
            gamepad_r = r;
            data = gamepad_data;
        end
        else begin
            mem_w = w;
            mem_r = r;
            data = mem_data;
        end
    end
    always_ff @(posedge CLK) begin
        MDRL <= MEM_LDMDRL ? data : MDRL;
        MDRH <= MEM_LDMDRH ? data : MDRH;
        MAR  <= MEM_LDMAR ? addr : MAR;
    end

endmodule


/********************* ADDR_MUX *****************************/
typedef enum logic [3:0] {      // address source
    ADDR_PC,
    ADDR_MDR,
    ADDR_MDRL,
    ADDR_ALU,
    ADDR_ALUL,
    ADDR_SP,
    ADDR_SP1,
    ADDR_MAR,
    ADDR_MAR1,

    ADDR_RESET,    
    ADDR_NMI,
    ADDR_BRK

} ADDR_MUX_t;

module ADDR_MUX_unit(
    input ADDR_MUX_t            ADDR_MUX,            // select address
    input logic [7:0]           MDRL, MDRH, ALUL, ALUH, SP,
    input logic [15:0]          PC, MAR,

    output logic [15:0]         addr
);
    always_comb begin
        addr = PC;
        case(ADDR_MUX)
            ADDR_PC : 
                addr = PC;
            ADDR_MAR : 
                addr = MAR;
            ADDR_MAR1 : 
                addr = 16'(MAR+1);
            ADDR_MDR :
                addr = {MDRH,MDRL};
            ADDR_MDRL :
                addr = {8'b0,MDRL};
            ADDR_ALU : 
                addr = {ALUH, ALUL};
            ADDR_ALUL : 
                addr = {8'b0, ALUL};
            ADDR_SP : 
                addr = {8'b01, SP};
            ADDR_SP1 : 
                addr = {8'b01, 8'(SP+1)};
            ADDR_RESET :
                addr = 16'hFFFC;
            ADDR_NMI :
                addr = 16'hFFFA;
            ADDR_BRK :
                addr = 16'hFFFE;
        endcase
    end
endmodule

`endif

