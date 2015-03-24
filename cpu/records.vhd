library IEEE;
use IEEE.std_logic_1164.all;


package Records is
   type SR_r is
   record
      z        : std_logic; -- zero
      n        : std_logic; -- negative
      o        : std_logic; -- overflow
      c        : std_logic; -- carry
      unused   : std_logic_vector(0 to 4);
	end record;
	
   type Instr_r is
   record
      op_code  : std_logic_vector(4 downto 0);
      content  : std_logic_vector(26 downto 0);
   end record;
	
   type pmem_t is array (0 to PMEM_HEIGHT - 1) of std_logic_vector(PMEM_WIDTH - 1 downto 0);
end Records;

