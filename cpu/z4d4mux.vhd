library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity Z4D4Mux is
   port(
      IR4      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      z4       : in std_logic_vector(REG_WIDTH - 1 downto 0);
      d4       : in std_logic_vector(REG_WIDTH - 1 downto 0);
      doWrite  : out std_logic;
      regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
      newValue : out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end Z4D4Mux;

architecture Behavioral of Z4D4Mux is
   signal ir4OP            : std_logic_vector(OP_WIDTH - 1 downto 0);
   signal ir4ALUinstr      : std_logic_vector(ALU_INSTR_WIDTH - 1 downto 0);
   signal ir4ALUsaves      : std_logic;
begin
   -- Convenience signals
   ir4OP <= ir4(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   ir4ALUinstr <= ir4(ALU_INSTR_OFFSET downto ALU_INSTR_OFFSET - ALU_INSTR_WIDTH + 1);

   -- Not all ALU instructions saves back to a register, namely DO_NOTHING and CMP
   ir4ALUsaves <= '0' when ir4ALUinstr = "00000" OR   -- DO_NOTHING
                           ir4ALUinstr = "01100" else -- CMP
                  '1';
   
   doWrite <=  '1' when ir4OP = "11100"                              -- LOAD.a
                     OR ir4OP = "11101"                              -- LOAD.c
                     OR ir4OP = "11110"                              -- LOAD.wo
                     OR ir4OP = "11111"                              -- LOAD.wro
                     OR ir4OP = "00100"                              -- MOVE
                     OR (ir4OP = "00101" and ir4ALUsaves = '1')      -- ALUINST.r
                     OR (ir4OP = "00110" and ir4ALUsaves = '1') else -- ALUINST.c
               '0';
   
   regSel <=  ir4(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1)
                  when  ir4OP = "11100"         -- LOAD.a
                     OR ir4OP = "11101"         -- LOAD.c
                     OR ir4OP = "11110"         -- LOAD.wo
                     OR ir4OP = "11111"         -- LOAD.wro
                     OR ir4OP = "00100" else    -- MOVE
               ir4(REG_ALU_OFFSET downto REG_ALU_OFFSET - REG_BITS + 1)
                  when  ir4OP = "00101"         -- ALUINST.r
                     OR ir4OP = "00110" else    -- ALUINST.c
               (others => '0');
   
   newValue <= z4 when  ir4OP = "11100"         -- LOAD.a
                     OR ir4OP = "11110"         -- LOAD.wo
                     OR ir4OP = "11111" else    -- LOAD.wro
               d4;
end Behavioral; 
