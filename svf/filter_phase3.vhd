-- Filter Phase 3:
--   - Second delay
--   - Second multiplication with f
--   - Addition between the delay and the multiplication

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FilterConstants.all;

entity Filter_Phase_3 is
   port(
      input       : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay_in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay_out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      lp_out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0)
   );
end Filter_Phase_3;

architecture Behavioral of Filter_Phase_3 is
   signal multiplication   : std_logic_vector(2 * AUDIO_WIDTH - 1 downto 0);
   signal addition         : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
begin
   multiplication <= std_logic_vector(signed(input) * signed(f));
   addition <= std_logic_vector(
                  signed(multiplication(2 * AUDIO_WIDTH - 1 downto AUDIO_WIDTH))
                  + signed(delay_in)
               );

   delay_out   <= addition;
   lp_out      <= addition;
end Behavioral;

