library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoutWaveGen is
   port(
      clk               : in std_logic; -- Clock
      soundwave         : out std_logic_vector(SAMPLE_SIZE-1 downto 0) -- sound out
   );
end SoutWaveGen;


architecture Behavioral of SoutWaveGen is
   
   signal clk_counter   : std_logic_vector(16 downto 0) := (others => '0');
   signal wavepos       : std_logic := '0';
   
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         clk_counter <= std_logic_vector(unsigned(clk_counter)+1);
         if clk_counter = "11000011010100000" then
            if wavepos = '0' then
               wavepos <= '1';
            else
               wavepos <= '0';
            end if;
         end if;
      end if;
   end process;

soundwave <= "1000000000000000" when wavepos = '1' else "0000000000000000";
   
end Behavioral;
