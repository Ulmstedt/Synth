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
   signal pc2     : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
   isJmp <= ir1(PMEM_WIDTH - 1) xor ir1(PMEM_WIDTH - 2);
   regSel <= ir1(REG_BITS - 1 downto 0);
   
   -- Calculate the new PC2 value depending on what type of jump it is
   -- 00: absolute address
   -- 01: address from a register
   -- 10: offset from current address
   process(clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            pc2 <= (others => '0');
         else
            if isJmp = '1' then
               -- The branch test doesn't fail or it's a regular jump, do the jump
               if ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "00" then
                  -- XXX00: Absolute address
                  pc2 <= std_logic_vector(unsigned(ir1(ADDR_WIDTH - 1 downto 0)));
               elsif ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "01" then
                  -- XXX01: Address in register
                  pc2 <= std_logic_vector(unsigned(pc1) + unsigned(regIn));
               elsif ir1(PMEM_WIDTH - 4 downto PMEM_WIDTH - 5) = "10" then
                  -- XXX10: Offset from current address
                  pc2 <= std_logic_vector(unsigned(pc1) + unsigned(ir1(ADDR_WIDTH - 1 downto 0)));
               end if;
            else
               pc2 <= (others => '0');
            end if;
         end if;
      end if;
   end process;
   pcOut <= pc2;
end Behavioral;
