library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

-- The D register to save constant data from IR1 to use in the ALU
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
               doRead   => '1',
               input    => loadValue,
               output   => output,
               rst      => rst,
               clk      => clk
            );
   -- Convenience signal
   ir1op <= ir1in(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
   -- Get the value from the instruction to put in to the register
   loadValue <=   ir1in(REG_WIDTH - 1 downto 0) when ir1op = "11101" OR ir1op = "00110" else -- LOAD.c, ALUINSTR.c
                  (REG_WIDTH - 1 downto ADDR_WIDTH => '0') & ir1in(ADDR_OFFSET downto ADDR_OFFSET - ADDR_WIDTH + 1)
                     when  ir1op = "11000" OR   -- STORE.c
                           ir1op = "11001" OR   -- STORE.r
                           ir1op = "11010" OR   -- STORE.wo
                           ir1op = "11011" else -- STORE.wofr
                  "00000" & ir1in(LOAD_ADRESS_OFFSET downto 0) 
                     when  ir1op = "11100" OR   -- LOAD.a
                           ir1op = "11110" OR   -- LOAD.wo
                           ir1op = "11111" else -- LOAD.wofr
                  (others => '0');

end Behavioral;
