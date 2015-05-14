library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.TouchConstants.all;

entity CoordConverter is
   port(
      voltage  : in std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
      coord    : out std_logic_vector(COORD_WIDTH - 1 downto 0);
      Xaxis    : in std_logic
   );
end CoordConverter;


architecture Behavioural of CoordConverter is
  
   constant Xfactor  : std_logic_vector(15 downto 0) := "0001000000101010"; -- 0,12631 fixed point (480 / 3800)
   constant Yfactor  : std_logic_vector(15 downto 0) := "0000100111110010"; -- 0,07771 fixed point (272 / 3500)

   signal mult       : std_logic_vector(27 downto 0);
   
begin 
   mult <=
      std_logic_vector(to_unsigned((to_integer(unsigned(voltage)) - 150) * to_integer(unsigned(Xfactor)),28)) when Xaxis = '1' else 
      std_logic_vector(to_unsigned((to_integer(unsigned(voltage)) - 300) * to_integer(unsigned(Yfactor)),28));
   coord <= mult(23 downto 15);

 
end Behavioural;
