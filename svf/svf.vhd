-- A State Variable Filter designed after figure 1 in http://ni.com/white-paper/3476/en/#toc2
-- This part does the initial addition and multiplication with q of phase 2 output
-- See the comment of the respective phase to read what they individually do.
-- A brief note on the multiplications:
--    Since the filter is designed with fixed-point the multiplication scraps
--    the lowest 16 bits. This will lead to some noice added since the
--    multiplications are just approximate, but floating point is beyond the 
--    scope of this project (and even float will lead to noice). 
--
-- Ideally this part should be implemented on four DSP slices, but since they
-- are fairly fiddly to set up, at the moment this file is not correctly structured
-- to be used for a DSP slice since three additions (rather subtractions) are
-- done in the same step, the DSP slices on the NEXYS3 is structured with first one
-- pre-addition, then the multiplication and lastly an addition, thus the first step
-- would take up a whole slice. However, the compiler do fix it to use DSPs, albeit 
-- not optimally.
-- 
-- The whole filter works with signed values, since the output to the
-- sound chip is signed.
--
-- Since the output from registers are delayed one CLK the actual delay is 
-- handled by the registers themself.
--
-- Runs at half speed because there was a part in phase3 that couldn't be
-- feasable to do in 100MHz.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FilterConstants.all;

entity SVF is
   port(
      sample      : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay1in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay2in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      output      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay1out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay2out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      q           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      svfType     : in std_logic_vector(1 downto 0);
      loadFilter  : in std_logic;
      saveDelay   : out std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end SVF;

architecture Behavioral of SVF is
   component Filter_Phase_1 is
      port(
         input    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         output   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         hp_out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         f        : in std_logic_vector(AUDIO_WIDTH - 1 downto 0)
      );
   end component;

   component Filter_Phase_2 is
      port(
         input       : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay_in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay_out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         output      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         bp_out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0)
      );
   end component;

   component Filter_Phase_3 is
      port(
         input       : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay_in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay_out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         lp_out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0)
      );
   end component;
   
   signal qmult      : std_logic_vector(2*AUDIO_WIDTH - 1 downto 0);
   signal sub        : std_logic_vector(AUDIO_WIDTH - 1 downto 0);

   signal lp_out     : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal bp_out     : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal hp_out     : std_logic_vector(AUDIO_WIDTH - 1 downto 0);

   signal phase1out  : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal phase2out  : std_logic_vector(AUDIO_WIDTH - 1 downto 0);

   signal loadedVal  : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal savePulse  : std_logic; 
begin
   p1 : Filter_Phase_1 port map(
      input    => sub,
      output   => phase1out,
      hp_out   => hp_out,
      f        => f
   );

   p2 : Filter_Phase_2 port map(
      input       => phase1out,
      delay_in    => delay1in,
      delay_out   => delay1out,
      output      => phase2out,
      bp_out      => bp_out
   );

   p3 : Filter_Phase_3 port map(
      input       => phase2out,
      delay_in    => delay2in,
      delay_out   => delay2out,
      lp_out      => lp_out,
      f           => f
   );

   qmult <= std_logic_vector(signed(q) * signed(phase2out));

   sub   <= std_logic_vector(
               signed(sample) - signed(lp_out) -
               (signed(qmult(AUDIO_WIDTH * 2 - 1 downto AUDIO_WIDTH)))
            );

   -- Send a pulse when we're done computing, slightly depricated at the
   -- moment.
   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            savePulse <= '0';
            loadedVal <= (others => '0');
         else
            if loadFilter = '1' then
               loadedVal <= sample;
               savePulse <= '1';
            end if;
            if savePulse = '1' then
               savePulse <= '0';
            end if;
         end if;
      end if;
   end process;
   
   saveDelay <= savePulse;
   -- Set the output depending on the type
   output <= lp_out when svfType = "00" else
             hp_out when svfType = "01" else
             bp_out when svfType = "10" else
             sample;

end Behavioral;

