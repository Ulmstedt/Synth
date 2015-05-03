--Counter for y coordinate
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity Y_COUNTER is
   port(
      rst   : in std_logic;
      clk   : in std_logic;
      xcount: in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      count : out std_logic_vector(YCOUNT_BITS - 1 downto 0)
   );
end Y_COUNTER;

architecture ycount of Y_COUNTER is
   signal i_cnt   :  unsigned(YCOUNT_BITS -1 downto 0); --internal cnt signal

begin
   process(rst, clk)
   begin
      if(rst = '1') then
         i_cnt <= (others => '0'); --0
      elsif(rising_edge(clk)) then
         if(to_integer(unsigned(xcount)) = THA + THB -1) then -- if xcount is on 524 we do something
            if (to_integer(i_cnt) = TVA + TVB - 1) then -- if counted 0-287
               i_cnt <= (others => '0'); --0
            else
               i_cnt <= i_cnt + 1;
            end if;
         else
         end if;
      end if;
   end process;
   count <= std_logic_vector(i_cnt);
end ycount;
