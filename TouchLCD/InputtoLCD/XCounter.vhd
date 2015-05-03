--Counter for x coordinate
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity X_COUNTER is
   port(
      rst         : in std_logic;
      clk         : in std_logic;
      count       : out std_logic_vector(XCOUNT_BITS - 1 downto 0);
      firstCycle  : out std_logic_vector(5 downto 0)
   );
end X_COUNTER;
--fixa firsttime!!!
architecture xcount of X_COUNTER is
   signal i_cnt : unsigned(XCOUNT_BITS - 1 downto 0) := "1111111111"; --internal count signal
   signal firstTime : unsigned(5 downto 0) := "000000";
begin
   process(clk, rst)
   begin
      if(rst = '1') then
         i_cnt <= (others => '0');  --cnt to 0
         firstTime <= (others => '0');
      elsif(rising_edge(clk)) then
         if (to_integer(unsigned(firstTime)) < THB) then
            firstTime <= firstTime + 1;
         else
            if(to_integer(unsigned(i_cnt)) = THA + THB - 1) then
               i_cnt <= (others => '0'); --counted 0-524 and then start over
            else
               i_cnt <= i_cnt + 1; --normal count up 1
            end if;
         end if;
      end if;
   end process;

   count <= std_logic_vector(i_cnt);

   --firstCycle signal used for delay first DATAENABLE
   firstCycle <= std_logic_vector(firstTime);
end xcount;
