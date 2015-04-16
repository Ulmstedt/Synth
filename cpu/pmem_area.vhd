library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity PMemArea is
   port(
      ir1out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      ir2out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
      regIn    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      sr       : in std_logic_vector(SR_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic
   );
end PMemArea;

architecture Behaviorial of PMemArea is

   component PCReg is
      port(
         nextPCType  : in std_logic_vector(1 downto 0);
         nextPC      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         clk         : in std_logic;
         curPC       : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
      );
   end component;
   
   component pMemory is
      port(
         addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         instr    : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         clk      : in std_logic
      );
   end component;
   
   component IR2 is
      port(
         input    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         output   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         pcType   : out std_logic_vector(1 downto 0);
         stall    : in std_logic;
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   component Reg is
      generic (regWidth : natural);
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
   component IR1 is
      port(
         input    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir2in    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         output   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         stall    : out std_logic_vector(1 downto 0); 
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   component Jmp is
      port(
         pc1   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         ir1   : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         pcOut : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
         regSel: out std_logic_vector(REG_BITS - 1 downto 0);
         regIn : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         sr    : in std_logic_vector(SR_WIDTH - 1 downto 0);
         rst   : in std_logic;
         clk   : in std_logic
      );
   end component;
   
   signal memOut     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal nextPCType : std_logic_vector(1 downto 0);
   signal nextPC     : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal pcAddr     : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal pc1out     : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal ir1sig     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir2sig     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal stall      : std_logic;
   signal stallInit  : std_logic_vector(1 downto 0);
   signal stallCount : std_logic_vector(1 downto 0);
   
begin
   pc : PCReg port map (
      nextPCType  => nextPCType,
      nextPC      => nextPC,
      clk         => clk,
      curPC       => pcAddr
   );
   
   pc1 : Reg
      generic map(regWidth => ADDR_WIDTH)
      port map(
               doRead   => clk,
               input    => pcAddr,
               output   => pc1out,
               rst      => rst,
               clk      => clk
            );
            
   ir1c : IR1 port map (
      input    => memOut,
      ir2in    => ir2sig,
      output   => ir1sig,
      stall    => stallInit,
      rst      => rst,
      clk      => clk
   );
   
   ir2c : IR2 port map (
      input    => ir1sig,
      output   => ir2sig,
      pcType   => nextPCType,
      stall    => stall,
      rst      => rst,
      clk      => clk
   );
   
   jmpc : Jmp port map (
      pc1      => pc1out,
      ir1      => ir1sig,
      pcOut    => nextPC,
      regSel   => regSel,
      regIn    => regIn,
      sr       => sr,
      rst      => rst,
      clk      => clk
   );

   mem : pMemory port map (
      addr        => pcAddr,
      instr       => memOut,
      clk         => clk
   );
   
   ir1out <= ir1sig;
   ir2out <= ir2sig;
   
   -- Stall counter, branches need to stall twice to ensure correct data
   process (clk) is
   begin
      if rising_edge(clk) then
         if rst='1' then
            stallCount <= "00";
         elsif stallInit /= "00" then
            stallCount <= stallInit;
         elsif stallCount /= "00" then
            stallCount <= std_logic_vector(unsigned(stallCount) - 1);
         end if;
      end if;
   end process;
   stall <= '1' when stallCount /= "00" else '0';
end Behaviorial;
