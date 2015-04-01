-- Jump logic
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity Jmp is
   port(
      pc1   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ir1   : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      pcOut : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      regSel: out std_logic_vector(REG_BITS - 1 downto 0);
      regIn : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      rst   : in std_logic;
      clk   : in std_logic
   );
end Jmp;

architecture Behavioral of Jmp is
   signal isJmp   : std_logic;
   signal jmpAdd  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal pc2     : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
   isJmp <= ir1(PMEM_WIDTH - 1) xor ir1(PMEM_WIDTH - 2);
   regSel <= ir1(REG_BITS - 1 downto 0);
   
   process(clk)
   begin
      if rising_edge(clk) then
         if isJmp = '1' and ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "00" then
            -- XXX00: Absolute address
            pc2 <= std_logic_vector(unsigned(ir1(ADDR_WIDTH - 1 downto 0)));
         elsif isJmp = '1' and ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "01" then
            -- XXX01: Address in register
            pc2 <= std_logic_vector(unsigned(pc1) + unsigned(regIn));
         elsif isJmp = '1' and ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "10" then
            -- XXX10: Offset from current address
            pc2 <= std_logic_vector(unsigned(pc1) + unsigned(ir1(ADDR_WIDTH - 1 downto 0)));
         else
            pc2 <= (others => '0');
         end if;
      end if;
   end process;
   pcOut <= pc2;
end Behavioral;