package Constants is
   constant PMEM_WIDTH           : natural := 32;
   constant ADDR_WIDTH           : natural := 11;
   constant PMEM_HEIGHT          : natural := 64;
    
   constant REG_NUM              : natural := 32;
   constant REG_BITS             : natural := 5;
   constant REG_WIDTH            : natural := 16;
    
   constant REG_DEST_OFFSET      : natural := 26;
   constant REG_ALU_OFFSET       : natural := 20;
   constant REG_LOAD_OFFSET      : natural := 15;
   constant REG_STORE_OFFSET     : natural := 9;
   constant CONST_LOAD_OFFSET    : natural := 20;
   constant CONST_BRANCH_OFFSET  : natural := 9;
   constant OP_WIDTH             : natural := 5;
   
   constant ALU_INSTR_OFFSET     : natural := 26;
   constant ALU_INSTR_WIDTH      : natural := 5;
   constant ALU_DEST_REG_OFFSET  : natural := 21;
   constant ALU_SRC_REG_OFFSET   : natural := 5;
   
   constant WITH_OFFSET_OFFSET   : natural := 21;
   constant WITH_OFFSET_WIDTH    : natural := 11;
   
   constant OP_LOAD              : natural := 3;
   constant READ_REG_OFFSET      : natural := 5;
   constant STORE_WOFR_OFFSET    : natural := 9;
   constant LOAD_WRO_OFFSET      : natural := 15;
end Constants;
