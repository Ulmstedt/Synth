library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoundOutput is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      mclk              : out std_logic; -- Master clock
      sclk              : out std_logic; -- Serial clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic; -- Serial data output
   );
end SoundOutput;


architecture Behavioral of SoundOutput is

   signal bitCounter       : std_logic_vector(SAMPLE_SIZE_WIDTH - 1 downto 0) := (others => '0'); -- Counts the number of bits that has been output
   signal sample           : std_logic_vector(SAMPLE_SIZE - 1 downto 0) := (others => '0'); -- Current sample

   signal sending          : std_logic; -- Boolean for if we are in the middle of a transfer
   signal rightOutput      : std_logic; -- Are we sending left/right output?
   
   type states is (start_l,send_l,start_r,send_r); -- State enum left/right
   signal state : states;

begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sample <= (others => '0');
         else
            if rightOutput = '1'
               lrck <= '0'; -- Send to left output
               sdout <= sample(SAMPLE_SIZE-1 - to_integer(unsigned(bitCounter)));
               bitCounter <= std_logic_vector(unsigned(bitCounter)+1); -- Increment bitCounter
               state <= send_l;
            end if;
         end if;
      end if;
   end process;

end Behavioral;