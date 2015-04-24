library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use use work.LCDConstants.all;

entity GK2 is
   port(
      YCounter       : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      toTileMap      : out std_logic_vector(5 downto 0);
      toTileMem      : out std_logic_vector(2 downto 0);
   );

architecture GK2_t of GK2 is

begin  
   toTileMap <= YCounter(8 downto 3);
   toTileMem <= YCounter(2 downto 0);
end GK2_t;
