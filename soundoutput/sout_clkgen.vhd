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
   signal clk_counter      : std_logic_vector(11 downto 0) := (others => '0'); -- Clk counter
   
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sclkS <= '0';
            mclkS <= '0';
            clk_counter <= (others => '0');
         else
            -- Generate clocks

            clk_counter <= std_logic_vector(unsigned(clk_counter)+1);
            if clk_counter = std_logic_vector(to_unsigned(70,12)) then -- 2267?

               -- "Shift" clock
               sclkS <= '1';
               clk_counter <= (others => '0');

               -- Master clock 
               if mclkS = '0' then
                  mclkS <= '1';
               else
                  mclkS <= '0';
               end if;

            end if;
         end if;

         if sclkS = '1' then
            sclkS <= '0';
         end if;

      end if;
   end process;

   mclk <= mclkS;
   sclk <= sclkS;
   
end Behavioral;
