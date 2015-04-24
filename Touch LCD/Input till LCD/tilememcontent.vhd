library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.LCDConstants.all;



package tilememContent is
   type tile_mem_t is array (0 to something - 1) of std_logic_vector(REG_WIDTH - 1 downto 0);

   constant tile_memc : tile_mem_t := (
         ("00000" & "000" & "0000" & "1000" ),
         ("11111" & "111" & "1111" & "1111" ),
         ("10101" & "010" & "1010" & "1010" ),
      others =>
         ("00000" & "000" & "0000" & "0000" )
      );
      
end memContent;
