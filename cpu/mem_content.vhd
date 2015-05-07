library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;
use work.Constants.all;


package memContent is
   constant memc : mem_t := (
      TILE_MAP_OFFSET =>
         ("0000" & "0001" & "0000" & "0001" ),
      TILE_MAP_OFFSET + 4 =>
         ("0000" & "0001" & "0000" & "0001" ),
      others =>
         ("0000" & "0000" & "0000" & "0000" )
      );
      
end memContent;
