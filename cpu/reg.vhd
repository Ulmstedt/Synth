library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

-- A generic register that can be used elsewhere. The register length
-- can be set with a generic, regWidth.
entity Reg is
   generic (regWidth : natural := REG_WIDTH);
   port(
      doRead      : in std_logic;
      input       : in std_logic_vector(regWidth - 1 downto 0);           
      output      : out std_logic_vector(regWidth - 1 downto 0);
      rst         : in std_logic;
      clk         : in std_logic
   );
end Reg;

architecture Behavioral of Reg is
   signal reg : std_logic_vector(input'range) := (others => '0');
begin

   -- Reset and load with new value if the input is set to high
   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            reg <= (reg'range => '0');
         elsif doRead = '1' then
            reg <= input;
         end if;
      end if;
   end process;
   output <= reg;
end Behavioral;
