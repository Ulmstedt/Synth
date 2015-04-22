library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity Timer is
   generic(timer_width : natural := REG_WIDTH);
   port(
      loadValue   : in std_logic_vector(timer_width - 1 downto 0);
      loadTimer   : in std_logic;
      finished    : out std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end Timer;

architecture Behavioral of Timer is
   signal counter          : std_logic_vector(loadValue'range);
   signal finishedCounting : std_logic;
begin
   process (clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            counter <= std_logic_vector(to_unsigned(0, counter'length));
         end if;
         if finishedCounting = '1' then
            finishedCounting <= '0';
         end if;
         if to_integer(unsigned(loadValue)) /= 0 then
            counter <= loadValue;
         elsif to_integer(unsigned(counter)) > 1 then
            if to_integer(unsigned(counter)) = 1 then
               finishedCounting <= '1';
            end if;
            counter <= std_logic_vector(to_integer(unsigned(counter)) - 1);
         end if;
      end if;
   end process;
   
   finished <= finishedCounting;

end Behavioral;
