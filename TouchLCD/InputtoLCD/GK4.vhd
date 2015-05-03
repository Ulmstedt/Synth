library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity GK4 is
   port(
      XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
      YCounter      : in std_logic_vector(YCOUNT_BITS - 1 downto 0);
      toLCD_DE      : out std_logic;
      firstXdelay   : in std_logic_vector(5 downto 0)
   );
end GK4;

architecture GK4_t of GK4 is

begin  
   --Only data enabled when Xcounter<480 and Ycounter<272
   toLCD_DE <= '1' when to_integer(unsigned(XCounter)) < THA and to_integer(unsigned(YCounter)) < TVA and to_integer(unsigned(firstXdelay)) >= THB else
               '0';
end GK4_t;
