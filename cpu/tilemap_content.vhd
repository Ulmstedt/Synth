--Actual tilemap

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;
use work.Constants.all;


package tilemapContent is
   constant tilemapc : tilemap_t := (
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         ("00011110" & "00011110" ),   -- 768+15=783
         ("00011100" & "00001010" ),   -- WA
         ("00011011" & "00001110" ),   -- VE
         ("00011111" & "00011110" ),   -- :
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),   -- Value here
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         ("00011110" & "00011110" ),   -- 813
         ("00001111" & "00010001" ),   -- FI
         ("00010010" & "00011001" ),   -- LT
         ("00011111" & "00011110" ),   -- :
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),   -- Value here
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         ("00011110" & "00011110" ),   -- 843
         ("00001111" & "00010111" ),   -- FR
         ("00001110" & "00010110" ),   -- EQ
         ("00011111" & "00011110" ),   -- :
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),   -- Value here
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

         ("00011110" & "00011110" ),   -- 873
         ("00010111" & "00001110" ),   -- RE
         ("00011000" & "00010100" ),   -- SO
         ("00011111" & "00011110" ),   -- :
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),   -- Value here
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),
         ("00011110" & "00011110" ),

      others =>
         ("00011110" & "00011110" )
      );
      
end tilemapContent;
