library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

-- The PC pointing at the next value to be loaded into IR1 from memory
entity PCReg is
   port(
      nextPCType  : in std_logic_vector(1 downto 0);
      nextPC      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      clk         : in std_logic;
      curPC       : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
   );
end PCReg;

architecture Behavioral of PCReg is
   signal pc     : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
   -- Set the next pc according to what nextPcType says should happen:
   --  00 : incr +1
   --  01 : goto addr nextPc
   --  10 : stall (keep pc)
   --  11 : reset to start addr
   process(clk) is
   begin
      if rising_edge(clk) then
         if nextPCType = "00" then
            pc <= std_logic_vector(unsigned(pc) + 1);
         elsif nextPCType = "01" then
            pc <= nextPC;
         elsif nextPCType = "10" then
            pc <= pc;
         elsif nextPCType = "11" then
            pc <= (others => '0');
         end if;
      end if;
   end process;
   curPC <= pc;
end Behavioral;
