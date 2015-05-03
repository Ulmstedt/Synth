library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

   --1 tile = 8x8 pixlar
   --60 tiles i x-led
   --34 tiles i y-led
   --60*34= tiles totalt på skärmen
   --dmem 16 bitar brett
   -- XXXX XXXX XXXX XXXX
   --Behöver 5 bitar för att peka ut rätt tile i tilemem
   -- Varje minnesplats i dmem får hålla reda på 3 tiles
   --1 vit
   --0 svart

package tilememContent is
   type tile_mem_c is array (TILE_DIM - 1 downto 0) of std_logic_vector(TILE_DIM - 1 downto 0);
   type tile_mem_t is array (0 to TILE_MEM_HEIGHT - 1) of tile_mem_c;

   constant tileMemoryContent : tile_mem_t := (

         (("1000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000")),

         (("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010"),
          ("1010" & "1010")),
      others =>
         (("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"),
          ("0000" & "0000"))
      );
      
end tilememContent;
