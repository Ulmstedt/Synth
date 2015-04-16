library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity DReg is
   port(
      ir2in    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      output   : out std_logic_vector(REG_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic
   );
<<<<<<< HEAD
end DReg

architecture Behavioral of DReg is
   component Reg
      generic(regWidth : natural);
=======
end DReg;

architecture Behavioral of DReg is
   component Reg
      generic(regWidth : natural := REG_WIDTH);
>>>>>>> 1f04ef8d6d73ceecfcff45cd608513bab054b369
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
<<<<<<< HEAD
   signal loadValue  : in std_logic_vector(REG_WIDTH - 1 downto 0);
   signal ir2op      : in std_logic_vector(OP_WIDTH - 1 downto 0);
begin
   d2   : Reg
      generic map(regWidth => REG_WIDTH)
=======
   signal loadValue  : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal ir2op      : std_logic_vector(OP_WIDTH - 1 downto 0);
begin
   d2   : Reg
>>>>>>> 1f04ef8d6d73ceecfcff45cd608513bab054b369
      port map(
               doRead   => clk,
               input    => loadValue,
               output   => output,
               rst      => rst,
               clk      => clk
            );
   -- Convenience signal
   ir2op <= IR2in(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
<<<<<<< HEAD
   loadValue <=   ir2in(REG_WIDTH - 1 downto 0) when ir2op = "11000" else -- STORE.c
                  ir2in(REG_WIDTH - 1 downto 0) when ir2op = "11101" else -- LOAD.c
                  ir2in(REG_WIDTH - 1 downto 0) when ir2op = "00110" else -- ALUINSTR.c
                  (10 downto 0 => ir2in(CONST_LOAD_OFFSET downto ADDR_WIDTH), others => '0')
                     when ir2op = "11110" else -- LOAD.wo
                  (10 downto 0 => ir2in(REG_WIDTH downto ADDR_WIDTH), others => '0')
                     when ir2op = "11110" else -- STORE.wo
                  (CONST_BRANCH_OFFSET downto 0 => ir2in(CONST_BRANCH_OFFSET downto 0), others => '0')
                     when ir2op = "01010" OR ir2op = "10010" OR ir2op = "10110" -- BRANCH.wo
=======
   -- Get the value from the instruction to put in to the register
   loadValue <=   ir2in(REG_WIDTH - 1 downto 0) when ir2op = "11101" OR ir2op = "00110" else -- LOAD.c, ALUINSTR.c
                  (REG_WIDTH - 1 downto ADDR_WIDTH => '0') & ir2in(ADDR_OFFSET downto ADDR_OFFSET - ADDR_WIDTH + 1)
                     when ir2op = "11110" OR ir2op = "11110" OR ir2op = "11000" else -- LOAD.wo, STORE.c, STORE.wo
                  (others => '0');
>>>>>>> 1f04ef8d6d73ceecfcff45cd608513bab054b369
end Behavioral;