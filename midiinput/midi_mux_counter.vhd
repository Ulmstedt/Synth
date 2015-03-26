library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity MuxCounter is
   port(
      clk      : in std_logic; -- Clock
      rst      : in std_logic; -- Reset
      validMsg : in std_logic; -- 1 when the message in tmpReg is valid
      msgReady : in std_logic; -- 1 when a message is ready in tmpReg
      muxCtr   : out std_logic_vector(1 downto 0); -- MUX counter
      outReady : out std_logic -- 1 when the message is ready to be transfered from tmpReg to mreg#
   );
end MuxCounter;

architecture Behavioral of MuxCounter is

signal count      : std_logic_vector(1 downto 0) := "00";
signal outReadyS  : std_logic := '0';

begin

process(clk) is
   if rising_edge(clk) rst = '0' then
      if validMsg = '1' and msgReady = '1' then
         case count is
            when "00" =>
                        count <= "01";
                        outReadyS <= '1';
            when "01" =>
                        count <= "10";
                        outReadyS <= '1';
            when "10" =>
                        count <= "00";
                        outReadyS <= '1';
            when others => null;
         end case;
      elsif validMsg = '0' then
         count <= "00";
      end if;                 
   end if;
end process;

muxCtr <= count;

-- Out ready should only be 1 for 1 clk
process(clk) is
   if rising_edge(clk) and outReadyS = '1' then
      outReadyS <= '0';
   end if;
end process;

outReady <= outReadyS;

-- Reset
process(clk) is
   if rising_edge(clk) and rst = '1' then
      count <= "00";
   end if;
end process;

end Behavioral;