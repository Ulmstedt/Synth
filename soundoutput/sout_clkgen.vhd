library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoutClkgen is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic -- Master clock
   );
end SoutClkgen;


architecture Behavioral of SoutClkgen is
   
   signal sclkS            : std_logic; -- Serial clock signal
   signal mclkS            : std_logic; -- Master clock signal
   
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sclkS <= '0';
            mclkS <= '0';
         else
            -- Generate clocks
         end if;
      end if;
   end process;

   mclk <= mclkS;
   sclk <= sclkS;
   
end Behavioral;
