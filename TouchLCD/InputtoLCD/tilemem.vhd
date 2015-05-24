--controlling reads from tilemem

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;
use work.tilememcontent.all;


entity TileMemory is
   port(
      tileAddr : in std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);
      YCoord   : in std_logic_vector(LOWER_BITS - 1 downto 0);
      XCoord   : in std_logic_vector(LOWER_BITS - 1 downto 0);
      output   : out std_logic_vector(RGB_BITS - 1 downto 0)
   );
end TileMemory;

architecture Behavioral of TileMemory is
   signal tile_mem : tile_mem_t := tileMemoryContent;
   
begin
   --välj ut rätt pixel i tilen
   output <= (others => tile_mem(to_integer(unsigned(tileAddr)))(to_integer(unsigned(YCoord)))(to_integer(unsigned(XCoord))));
end Behavioral;
