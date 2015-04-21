library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.records.all;


package pmemContent is

   constant pmemc : pmem_t := (
         ("00110" & "00001" & "00001" & "0" & "0000" & "0000" & "0000" & "0011"), -- ADD uns R1, 3
         ("00000" & "000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000"), -- NOP
         ("00101" & "00001" & "00001" & "0000" & "0000" & "0000" & "00001"),      -- ADD uns R1, R1
        

      others =>
         ("00000" & "000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000")
      );
      
end pmemContent;
