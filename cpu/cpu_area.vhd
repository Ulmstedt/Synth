library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity CPUArea is
   port(
      rst   : in std_logic;
      clk   : in std_logic
   );
end CPUArea;

architecture Behavioral of CPUArea is
   component MainArea is
      port(
         ir1      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir2      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         pmemSel  : in std_logic_vector(REG_BITS - 1 downto 0);
         pmemOut  : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   component PMemArea is
      port(
         ir1out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir2out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
         regIn    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   signal ir1     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir2     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal regSel  : std_logic_vector(REG_BITS - 1 downto 0);
   signal regVal  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   
begin
   main : MainArea port map(
      ir1         => ir1,
      ir2         => ir2,
      pmemSel     => regSel,
      pmemOut     => regVal,
      rst         => rst,
      clk         => clk
   );
   
   pmem : PMemArea port map(
      ir1out      => ir1,
      ir2out      => ir2,
      regSel      => regSel,
      regIn       => regVal,
      rst         => rst,
      clk         => clk
   );
end Behavioral;