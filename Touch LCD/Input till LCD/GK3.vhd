library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use use work.LCDConstants.all;

entity GK3 is
   port(
      XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      fromTileMem   : in std_logic_vector(something downto 0);
      toLCD         : out std_logic_vector(something downto 0);
   );

architecture GK3_t of GK3 is

begin  
   toLCD <= fromTileMem when to_integer(to_unsigned(XCounter))>= thB and to_integer(to_unsigned(XCounter)) <= tHA+tHB-1 else --only send data when X-count 
                                                                                                                             --is between 45-524
         <= (others => '0');
end GK3_t;
