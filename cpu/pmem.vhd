
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;
use work.records.all;

entity Memory is
   port(
      addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      instr    : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      clk      : in std_logic
   );
end Memory;

architecture Behavioral of Memory is
   signal  mem : pmem_t; --:= NÅGOT;
begin
   process(clk) is
   begin
      if rising_edge(clk) then
         instr <= mem(to_integer(unsigned(addr)));
      end if;
   end process;
end Behavioral;
