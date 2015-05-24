--Sends higherbits to tilemap, lowerbits to tilemem

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity GK1 is
   port(
      XCounter       : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      toTileMap      : out std_logic_vector(HIGHER_BITS - 1 downto 0);
      toTileMem      : out std_logic_vector(LOWER_BITS - 1 downto 0)
   );
end GK1;

architecture GK1_t of GK1 is

begin  
   toTileMap <= XCounter(XCOUNT_BITS - 1 downto XCOUNT_BITS - HIGHER_BITS);
   toTileMem <= XCounter(LOWER_BITS - 1 downto 0);
end GK1_t;
