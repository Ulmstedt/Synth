library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;
use work.records.all;
use work.memContent.all;

entity Memory is
   port(
      addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      output   : out std_logic_vector(REG_WIDTH - 1 downto 0);
      doWrite  : in std_logic;
      newValue : in std_logic_vector(REG_WIDTH - 1 downto 0);
      clk      : in std_logic
   );
end Memory;

architecture Behavioral of Memory is
   signal mem : mem_t := memc;
   
begin
   process(clk) is
   begin
      if rising_edge(clk) then
         output <= mem(to_integer(unsigned(addr)));
         if doWrite = '1' then
            mem(to_integer(unsigned(addr)) mod MEM_HEIGHT) <= newValue;
         end if;
      end if;
   end process;
end Behavioral;

