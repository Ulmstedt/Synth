--tilemem data only sent if X counter is between 0-479

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity GK3 is
   port(
      XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      fromTileMem   : in std_logic_vector(RGB_BITS - 1 downto 0);
      toLCD         : out std_logic_vector(RGB_BITS - 1 downto 0)
   );
end GK3;

architecture GK3_t of GK3 is

begin  
   toLCD <= fromTileMem when to_integer(unsigned(XCounter)) <= THA+THB-1 else --only send data when X-count is between 0-479
            (others => '0');
end GK3_t;
