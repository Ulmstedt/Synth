library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

-- The IR2 register, simply the value from IR1
entity IR2 is
   port(
      input    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      output   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      pcType   : out std_logic_vector(1 downto 0);
      sr       : in std_logic_vector(SR_WIDTH - 1 downto 0);
      stall    : in std_logic;
      rst      : in std_logic;
      clk      : in std_logic
   );
end IR2;

architecture Behavioral of IR2 is
   component Reg
      generic(regWidth : natural);
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
   signal muxVal     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal isJmp      : std_logic;
   signal ir2out     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal condJmp    : std_logic_vector(SR_BITS - 1 downto 0);
   
begin
   ir2   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
               doRead   => '1',
               input    => muxVal,
               output   => ir2out,
               rst      => rst,
               clk      => clk
            );

   condJmp <= ir2out(REG_DEST_OFFSET downto REG_DEST_OFFSET - SR_BITS + 1);

   muxVal <=   (others => '0') when stall = '1' else
               input;
   -- Is it a jump? OP code is 10XXX or 01XXX for branches
   isJmp       <= ir2out(PMEM_WIDTH - 1) xor ir2out(PMEM_WIDTH - 2);

   -- Select next pc depending on the type of instruction is in ir2
   pcType <= "11" when rst = '1' else
            "10" when stall = '1' else
            "01" when isJmp = '1' and ir2out(PMEM_WIDTH - 1 downto PMEM_WIDTH - 3) = "100"      -- BCC
                     and sr(to_integer(unsigned(condJmp))) = '1' else
            "01" when isJmp = '1' and ir2out(PMEM_WIDTH - 1 downto PMEM_WIDTH - 3) = "101"      -- BCC
                     and sr(to_integer(unsigned(condJmp))) = '0' else
            "01" when isJmp = '1' and ir2out(PMEM_WIDTH - 1 downto PMEM_WIDTH - 3) = "010" else -- BRA
            "00";

   output <= ir2out;

end Behavioral;
