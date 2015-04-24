--Counter for x coordinate
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entitiy X_COUNTER is
   port(
      rst   : in std_logic;
      clk   : in std_logic;
      count : out std_logic_vector(XCOUNT_BITS - 1 downto 0)

   );
end X_COUNTER;

architecture xcount of X_COUNTER is
   signal i_cnt : unsigned(XCOUNT_BITS downto 0); --internal count signal
begin
   process(clk, rst)
   begin
      if(rst = '1') then
         t_cnt <= (others => '0');  --cnt to 0
      elsif(rising_edge(clk)) then
         if(to_integer(i_cnt) = tHA + tHB - 1 then
            i_cnt <= (others => '0'); --counted 0-524 and then start over
         else
            i_cnt <= i_cnt + 1; --normal count up 1
         end if;
      end if;
   end process;
   count <= std_logic_vector(i_cnt);
end xcount;
