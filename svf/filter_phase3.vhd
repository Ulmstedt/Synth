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
      -- Since the output from the register will be delayed one CP
      -- the actual delay is handled by the register, not this phase
      input       : in integer;
      delay_in    : in integer;
      delay_out   : out integer;
      lp_out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0)
   );
end Filter_Phase_3;

architecture Behavioral of Filter_Phase_3 is
   signal multiplication   : std_logic_vector(2 * AUDIO_WIDTH - 1 downto 0);
   signal addition         : integer;
begin
   multiplication <= std_logic_vector(to_signed(input * to_integer(unsigned(f)), AUDIO_WIDTH * 2));
   addition <= to_integer(signed(multiplication(7 * AUDIO_WIDTH / 4 - 1 downto 3* AUDIO_WIDTH / 4))) +  delay_in;

   delay_out   <= addition;
   lp_out      <= std_logic_vector(to_signed(addition, AUDIO_WIDTH));
end Behavioral;
