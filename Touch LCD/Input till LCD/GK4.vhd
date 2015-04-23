library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use use work.LCDConstants.all;

entity GK4 is
   port(
      XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      YCounter      : in std_logic_vector(YCOUNT_BITS - 1 downto 0);
      toLCD_DE      : out std_logic;
   );

architecture GK4_t of GK4 is

begin  
   --Only data enabled when 45<=Xcounter<525 and 16<=Ycounter<496
   toLCD_DE <= '1' when to_integer(to_unsigned(XCounter)) >= tHB and to_integer(to_unsigned(XCounter)) <= tHA+tHB-1 and
                        to_integer(to_unsigned(YCounter)) >= tVB and to_integer(to_unsigned(YCounter)) <= tVA+tVB-1 else
               '0';
end GK4_t;
