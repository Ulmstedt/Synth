--Sends higherbits to tilemap, lowerbits to tilemem

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity GK2 is
   port(
      YCounter       : in std_logic_vector(YCOUNT_BITS - 1 downto 0);
      toTileMap      : out std_logic_vector(HIGHER_BITS - 1 downto 0);
      toTileMem      : out std_logic_vector(LOWER_BITS - 1 downto 0)
   );
end GK2;

architecture GK2_t of GK2 is

begin  
   toTileMap <= YCounter(YCOUNT_BITS - 1 downto YCOUNT_BITS - HIGHER_BITS);
   toTileMem <= YCounter(LOWER_BITS - 1 downto 0);
end GK2_t;
