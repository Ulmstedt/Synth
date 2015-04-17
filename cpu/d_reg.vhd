library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity DReg is
   port(
      ir1in    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      output   : out std_logic_vector(REG_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic
   );
end DReg;

architecture Behavioral of DReg is
   component Reg
      generic(regWidth : natural := REG_WIDTH);
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
   signal loadValue  : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal ir1op      : std_logic_vector(OP_WIDTH - 1 downto 0);
begin
   d2   : Reg
      port map(
               doRead   => clk,
               input    => loadValue,
               output   => output,
               rst      => rst,
               clk      => clk
            );
   -- Convenience signal
   ir1op <= IR1in(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
   -- Get the value from the instruction to put in to the register
   loadValue <=   ir1in(REG_WIDTH - 1 downto 0) when ir1op = "11101" OR ir1op = "00110" else -- LOAD.c, ALUINSTR.c
                  (REG_WIDTH - 1 downto ADDR_WIDTH => '0') & ir1in(ADDR_OFFSET downto ADDR_OFFSET - ADDR_WIDTH + 1)
                     when ir1op = "11110" OR ir1op = "11110" OR ir1op = "11000" else -- LOAD.wo, STORE.c, STORE.wo
                     "00000" & ir1in(LOAD_ADRESS_OFFSET downto 0) when ir1op = "11100" else -- LOAD.a
                  (others => '0');
end Behavioral;
