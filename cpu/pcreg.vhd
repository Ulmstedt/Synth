library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 
-- nextPCType
--  00 : incr
--  01 : goto addr
--  10 : 
--  11 : reset to start addr

entity PCReg is
   port(
      nextPCType  : in std_logic_vector(1 downto 0);
      nextPC      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
   );
end PCReg;