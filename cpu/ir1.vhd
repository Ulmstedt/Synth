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
      stall    : out std_logic; 
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
   
   -- decide pcSel depending on input
   -- Is it a jump? OP code is 10XXX or 01XXX for branches
   isJmp       <= irOut(PMEM_WIDTH - 1) xor irOut(PMEM_WIDTH - 2);
   -- Note that a NOP is not inserted yet, thus a command can be ran after a JMP
   
   -- Stall needed calculations
   ir2isLoad   <= '1' when ir2in(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) = "11100"
                  else '0';
   ir2reg      <= ir2in(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1);
   
   ir1reg      <= input(REG_ALU_OFFSET downto REG_ALU_OFFSET - REG_BITS + 1)
                     when  input(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) = "00101" OR
                           input(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) = "00110"
                     else input(REG_BITS - 1 downto 0);
                     
   ir1reg2     <= input(REG_BITS - 1 downto 0) 
                     when input(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) = "00101"
                     else ir1reg;
   
   -- Check if IR1 is doing something with the reg IR2 loads to
   -- ALUINSTR.r has two 
   sameReg     <= '1' when ir1reg = ir2reg OR ir1reg2 = ir2reg else '0';
   
   -- Check if the ir1 is an instruction that might need to stall
   with irOut(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH) select ir1stallCausing <=
         '1' when "11001", -- STORE.r
         '1' when "11010", -- STORE.wo
         '1' when "11011", -- STORE.wofr
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
   
   muxOutput <=   irOut when stalling = '1' else
                  (others => '0') when isJmp = '1' else
                  input;
                  
   pcType <= "11" when rst = '1' else
            "10" when stalling = '1' else
            "01" when isJmp = '1' else
            "00";
   
   output <= irOut;
   
end Behaviorial;


