library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;


package pmemContent is

   constant pmemc : pmem_t := (
         ("11101" & "11111" & "000" & "0000" & "0000" & "000" & "0000" & "1111"), -- LOAD.c R16,15

      others =>
         ("00000" & "000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000")
      );
      
end pmemContent;
