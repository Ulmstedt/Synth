package Constants is
   constant PMEM_WIDTH           : natural := 32;
   constant ADDR_WIDTH           : natural := 11;
   constant PMEM_HEIGHT          : natural := 64;

   constant MIDI_WIDTH           : natural := 8;
   constant AUDIO_WIDTH          : natural := 16;
   
   constant MEM_HEIGHT           : natural := 4096; --currently 2^12(255 slots in memory for the tilemap)
   constant TILE_MAP_OFFSET      : natural :=  3840; --where tile map memory starts 4096-255
    
   constant REG_NUM              : natural := 32;
   constant REG_BITS             : natural := 5;
   constant REG_WIDTH            : natural := 16;
    
   constant REG_DEST_OFFSET      : natural := 26;
   constant REG_ALU_OFFSET       : natural := 21;
   constant REG_LOAD_OFFSET      : natural := 15;
   constant REG_STORE_OFFSET     : natural := 9;
   constant ADDR_OFFSET          : natural := 26;
   constant CONST_BRANCH_OFFSET  : natural := 9;
   constant OP_WIDTH             : natural := 5;
   
   constant ALU_INSTR_OFFSET     : natural := 26;
   constant ALU_INSTR_WIDTH      : natural := 5;
   constant ALU_DEST_REG_OFFSET  : natural := 21;
   constant ALU_SRC_REG_OFFSET   : natural := 4;
   
   constant WITH_OS_LOAD_OFFSET  : natural := 21;
   constant WITH_OS_STORE_OFFSET : natural := 15;
   constant WITH_OFFSET_WIDTH    : natural := 11;
   
   constant OP_LOAD              : natural := 3;
   constant READ_REG_OFFSET      : natural := 4;
   constant STORE_WOFR_OFFSET    : natural := 15;
   constant LOAD_WRO_OFFSET      : natural := 21;
   
   constant CONST_STORE_OFFSET   : natural := 15;

   constant LOAD_ADRESS_OFFSET   : natural := 10;
   
   constant SR_BITS              : natural := 4;
   constant SR_WIDTH             : natural := 16;
   constant Z_OFFSET             : natural := 0;
   constant N_OFFSET             : natural := 1;
   constant C_OFFSET             : natural := 2;
   constant O_OFFSET             : natural := 3;
   constant T1_OFFSET            : natural := 4;

   constant LT1_OFFSET           : natural := 4;
   constant ST1_OFFSET           : natural := 5;
   constant ST2_OFFSET           : natural := 6;
   constant MIDI_OFFSET          : natural := 7;
   constant TOUCH_OFFSET         : natural := 8;

      --LCD CONSTANTS
   constant TILE_DIM             : natural := 16;
   constant TILE_MEM_HEIGHT      : natural := 32;
   constant TILE_MEM_ADRESS_BITS : natural := 5;

   constant RGB_BITS             : natural := 24;  
   
   constant XCOUNT_BITS          : natural := 10;
   constant YCOUNT_BITS          : natural := 10;

   constant HIGHER_BITS          : natural := 6;
   constant LOWER_BITS           : natural := 4;

   constant THA                  : natural := 480;
   constant THB                  : natural := 45;
   
   constant TVA                  : natural := 272;
   constant TVB                  : natural := 16;

end Constants;
