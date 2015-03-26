
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.types.all;
use work.constants.all;

entity ALU is
   port(
      left_In  : in std_logic_vector(REG_WIDTH-1 downto 0);
      right_In : in std_logic_vector(REG_WIDTH-1 downto 0);
      alu_Out  : out std_logic_vector(REG_WIDTH-1 down to 0);
      
      clk      : in std_logic;
      
      sr_z     : out std_logic;
      sr_n     : out std_logic;
      sr_o     : out std_logic;
      sr_c     : out std_logic;
   );
end ALU;

architecture Behavioural of ALU is
   
begin   