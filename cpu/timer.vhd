library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

-- A timer that can be initialized where needed, supports different lenghts and
-- continious with generics.
entity Timer is
   generic(
      timer_width : natural   := REG_WIDTH;
      continuous  : boolean   := false
   );
   port(
      loadValue   : in std_logic_vector(timer_width - 1 downto 0);
      finished    : out std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end Timer;

architecture Behavioral of Timer is
   signal counter          : std_logic_vector(loadValue'range) := (others => '0');
   signal startValue       : std_logic_vector(loadValue'range) := (others => '0');
   signal finishedCounting : std_logic := '0';
begin

   -- Do the counting once every CLK, and send a pulse out when it has finished counting
   process (clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            counter     <= (others => '0');
            startValue  <= (others => '0');
         end if;
         if finishedCounting = '1' then -- we only want finished high for one CLK
            finishedCounting <= '0';
         end if;
         if to_integer(unsigned(loadValue(loadValue'high downto loadValue'high - REG_WIDTH + 1))) /= 0 then
            counter <= loadValue;
            startValue <= loadValue;
         elsif to_integer(unsigned(counter)) >= 1 then
            if to_integer(unsigned(counter)) = 1 then -- We're done!
               finishedCounting <= '1';
               if continuous = true then -- set to continous, so load with the start value to restart
                  counter <= startValue;
               else
                  counter <= std_logic_vector(unsigned(counter) - 1);
               end if;
            else -- Continue counting down
               counter <= std_logic_vector(unsigned(counter) - 1);
            end if;
         end if;
      end if;
   end process;
   
   finished <= finishedCounting;

end Behavioral;
