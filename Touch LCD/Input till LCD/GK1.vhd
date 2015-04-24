library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use use work.LCDConstants.all;

entity GK1 is
   port(
      XCounter       : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      toTileMap      : out std_logic_vector(5 downto 0);
      toTileMem      : out std_logic_vector(2 downto 0);
   );

architecture GK1_t of GK1 is

begin  
   toTileMap <= XCounter(8 downto 3);
   toTileMem <= XCounter(2 downto 0);
end xcount;
