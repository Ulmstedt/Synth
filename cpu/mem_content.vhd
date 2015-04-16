library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;


package memContent is
   constant memc : mem_t := (
         ("00000" & "000" & "0000" & "1000" ),
      others =>
         ("00000" & "000" & "0000" & "0000" )
      );
      
end memContent;