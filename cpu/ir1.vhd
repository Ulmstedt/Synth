--Instruction Register 1 and it's decoder

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity IR1 is
   port(
      input    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      ir2in    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      output   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      pcType   : out std_logic_vector(1 downto 0);
      stall    : out std_logic_vector(1 downto 0); 
      rst      : in std_logic;
      clk      : in std_logic
   );
end IR1;


architecture Behaviorial of IR1 is
   component Reg
      generic(regWidth : natural);
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
      
   signal muxOutput        : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir2isLoad        : std_logic;
   signal ir1reg           : std_logic_vector(REG_BITS - 1 downto 0);
   signal ir1reg2          : std_logic_vector(REG_BITS - 1 downto 0);
   signal ir2reg           : std_logic_vector(REG_BITS - 1 downto 0);
   signal sameReg          : std_logic;
   signal isJmp            : std_logic;
   signal stalling         : std_logic;
   signal irOut            : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir1stallCausing  : std_logic;
   signal ir1OP            : std_logic_vector(OP_WIDTH - 1 downto 0);
   
begin
   ir1   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
               doRead   => clk,
               input    => muxOutput,
               output   => irOut,
               rst      => rst,
               clk      => clk
            );
   
   -- Convenience signal
   ir1OP <= irOut(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
   -- decide pcSel depending on input
   -- Is it a jump? OP code is 10XXX or 01XXX for branches
   isJmp       <= irOut(PMEM_WIDTH - 1) xor irOut(PMEM_WIDTH - 2);
   -- Note that a NOP is not inserted yet, thus a command can be ran after a JMP
   
   -- Stall needed calculations
   ir2isLoad   <= '1' when ir2in(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) = "11100"
                  else '0';
   ir2reg      <= ir2in(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1);
   
   -- Bit of a clusterfuck, but picks out the register used depending on the OP code
   ir1reg      <= irOut(REG_ALU_OFFSET downto REG_ALU_OFFSET - REG_BITS + 1) --ALUINSTR
                     when ir1OP = "00101" OR ir1OP = "00110"
                  else irOut(REG_LOAD_OFFSET downto REG_LOAD_OFFSET - REG_BITS + 1) --LOAD.wro
                     when ir1OP = "11111"
                  else irOut(REG_BITS - 1 downto 0);
   
   -- Retrieves the second register, if two are used by the command
   ir1reg2     <= irOut(REG_BITS - 1 downto 0) 
                     when ir1OP = "00101"
                  else irOut(REG_STORE_OFFSET downto REG_STORE_OFFSET - REG_BITS + 1)
                     when ir1OP = "11011"   
                  else ir1reg;
   
   -- Check if IR1 is doing something with the reg IR2 loads to
   -- ALUINSTR.r has two 
   sameReg     <= '1' when ir1reg = ir2reg OR ir1reg2 = ir2reg else '0';
   
   -- Check if the ir1 is an instruction that might need to stall
   with ir1OP select ir1stallCausing <=
         '1' when "11001", -- STORE.r
         '1' when "11010", -- STORE.wo
         '1' when "11011", -- STORE.wofr
         '1' when "11111", -- LOAD.wro
         '1' when "00100", -- MOVE
         '1' when "01001", -- BRANCH.r
         '1' when "10001", -- BCC.r
         '1' when "10101", -- BNCC.r
         '1' when "00101", -- ALUINSTR.r
         '1' when "00110", -- ALUINSTR.c
         '0' when others;
   
   
   -- Need stall?
   stalling <= '1' when ir2isLoad = '1' and ir1stallCausing = '1' and sameReg = '1'
               else '0';
   -- Set the stall counter to 0, 1 or two depending on if we need to stall or not,
   -- and what type of instruction it is (ie. if branch, stall twice)
   stall <= "10" when stalling = '1' and (ir1OP = "01001" OR ir1OP = "10001" OR ir1OP = "10101") else
            "01" when stalling = '1' else
            "00";
   
   muxOutput <=   irOut when stalling = '1' else
                  (others => '0') when isJmp = '1' else
                  input;
                  
   pcType <= "11" when rst = '1' else
            "10" when stalling = '1' else
            "01" when isJmp = '1' else
            "00";
   
   output <= irOut;
   
end Behaviorial;


