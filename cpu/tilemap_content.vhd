library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;
use work.Constants.all;


package tilemapContent is
   constant tilemapc : tilemap_t := (
        ("0000" & "0001" & "0000" & "0001" ),
        ("0000" & "0001" & "0000" & "0001" ),
        ("0000" & "0000" & "0000" & "0000" ),
        ("0000" & "0000" & "0000" & "0001" ),
      others =>
         ("0000" & "0000" & "0000" & "0000" )
      );
      
end tilemapContent;
