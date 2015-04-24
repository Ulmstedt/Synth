-- Filter Phase 1:
--  - Multipliation with f
--  - Picks out the HP output

library IEEE;
use IEEE.std_logic_1164.all;
use.numeric_std.all;

use work.FilterConstants.all;

entity Filter_Phase_1 is
   port(
      input    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      output   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      hp_out   : out std_logic_vector(AUDIO_WIDTH);
      f        : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   );
end Filter_Phase_1;

architecture Behavioral of Filter_Phase_1 i
   signal o    : std_logic_vector(2*AUDIO_WIDTH - 1 downto 0);
begins
   o <= std_logic_vector(unsigned(input) * unsigned(f));
   hp_out <= input;
   output <= o(2*AUDIO_WIDTH - 1 downto AUDIO_WIDTH);
end Behavioral;
