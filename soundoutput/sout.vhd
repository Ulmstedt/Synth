library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoundOutput is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      i2s               : in std_logic; -- Output to I2S
   );
end SoundOutput;


architecture Behavioral of SoundOutput is

signal clkCounter       : std_logic_vector(SOUT_CLK_FREQ_WIDTH - 1 downto 0) := (others => '0');
signal bitsOutput       : std_logic_vector(SAMPLE_SIZE_WIDTH - 1 downto 0) := (others => '0');

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            -- Reset stuff here
         else
            clkCounter <= std_logic_vector(unsigned(clkCounter)+1);
            
            -- Check if its time to send sample bit (16 bits per SOUT_CLK_FREQ)
            if clkCounter = std_logic_vector(to_unsigned(UART_CLK_PERIOD,UART_CLK_PERIOD_WIDTH)) then
               
            end if;
         end if;
      end if;
   end process;

end Behavioral;