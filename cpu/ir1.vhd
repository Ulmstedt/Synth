--Instruction Register 1 and it's decoder

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity IR1 is
   port(
      input    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
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
      
   signal muxOutput  : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal isJmp      : std_logic;
   signal stalling   : std_logic;
   signal irOut      : std_logic_vector(PMEM_WIDTH - 1 downto 0);
begin
   ir1   : Reg
      generic map(regWidth => PMEM_WIDTH);
      port map(
               doRead => clk,
               input => muxOutput,
               output => irOut,
               rst => rst,
               clk => clk
            );
   
   -- decide pcSel depending on input
   -- Is it a jump? OP code is 10XXX or 01XXX for branches
   isJmp <= irOut(PMEM_WIDTH - 1) xor irOut(PMEM_WIDTH - 2);
   -- Need stall?
   stalling <= '0'; -- check in table
   
   muxOutput <=   irOut when stalling = '1' else
                  (others => '0') when isJmp = '1' else
                  input;
                  
   pcType <= "11" when rst = '1' else
            "10" when stalling = '1' else
            "01" when isJmp = '1' else
            "00";
   
   output <= irOut;
   
end Behaviorial;


