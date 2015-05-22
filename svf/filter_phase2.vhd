-- Filter Phase 2:
--   - First delay
--   - The addition prior to the delay
--   - Picks out the BP output

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FilterConstants.all;

entity Filter_Phase_2 is
   port(
      -- Since the output from the register will be delayed one CP
      -- the actual delay is handled by the register, not this phase
      input       : in integer;
      delay_in    : in integer;
      delay_out   : out integer;
      output      : out integer;
      bp_out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0)
   );
end Filter_Phase_2;

architecture Behavioral of Filter_Phase_2 is
   signal addition : integer;
begin
   addition    <= input + delay_in;
   delay_out   <= addition;
   bp_out      <= std_logic_vector(to_signed(addition, AUDIO_WIDTH));
   output      <= delay_in;
end Behavioral;
