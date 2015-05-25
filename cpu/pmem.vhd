library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;
use work.records.all;
use work.pmemContent.all;

-- The memory, since it's a static memory (the program memory can't be
-- changed in runtime) it only gets the line the PC points to.
-- Note: since PC is synchronous with CLK, this does not need to be
entity pMemory is
   port(
      addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      instr    : out std_logic_vector(PMEM_WIDTH - 1 downto 0)
   );
end pMemory;

architecture Behavioral of pMemory is
   signal  mem : pmem_t := pmemc;
begin
   instr <= mem(to_integer(unsigned(addr)) mod PMEM_HEIGHT);
end Behavioral;
