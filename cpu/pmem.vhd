
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;
use work.records.all;
use work.pmemContent.all;

entity pMemory is
   port(
      addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      instr    : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      clk      : in std_logic
   );
end pMemory;

architecture Behavioral of pMemory is
   signal  mem : pmem_t := pmemc;
begin
   process(clk) is
   begin
      if rising_edge(clk) then
         instr <= mem(to_integer(unsigned(addr)) mod PMEM_HEIGHT);
      end if;
   end process;
end Behavioral;
