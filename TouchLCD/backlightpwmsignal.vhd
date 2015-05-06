--transform clk signal to pwm signal
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity blacklightpwmsignal is
   port(
      rst   : in std_logic;
      clk   : in std_logic;
      F     : out std_logic; --desired frequency 50 kHz
      clkStop  : in std_logic  
   );
end blacklightpwmsignal;

architecture freq of updatefreq is
   signal temp   :  std_logic;
   signal counter: integer range 0 to 999 := 0; --(100 000 000 / 50 000)/2

begin
   process(rst, clk)
   begin
      if(rst = '1') then
         temp <= '0'; --0
         counter <= 0;
      elsif(rising_edge(clk) and clkStop = '0') then
         if(counter = 999) then
            temp <= not(temp);
            counter <= 0;
         else
            counter <= counter + 1;
         end if;
      end if;
   end process;

   F <= temp;
end freq;
