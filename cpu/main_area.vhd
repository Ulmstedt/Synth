library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity MainArea is
   port(
      ir1      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      ir2      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      pmemSel  : in std_logic_vector(REG_BITS - 1 downto 0);
      pmemOut  : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic
   );
end MainArea;

architecture Behavioral of MainArea is
   component Reg
      generic(regWidth : natural := REG_WIDTH);
      port(
         doRead      : in std_logic;
         input       : in std_logic_vector(regWidth - 1 downto 0);           
         output      : out std_logic_vector(regWidth - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;

   component RegArea is
      port(
         pmemSel     : in std_logic_vector(REG_BITS - 1 downto 0);
         pmemOut     : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
         regASel     : in std_logic_vector(REG_BITS - 1 downto 0);
         regBSel     : in std_logic_vector(REG_BITS - 1 downto 0);
         regAOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
         regBOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
         regWriteSel : in std_logic_vector(REG_BITS - 1 downto 0);
         regWriteVal : in std_logic_vector(REG_WIDTH - 1 downto 0);
         regWrite    : in std_logic;
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
   component ALUArea is
      port(
         ALUOut  :  out std_logic_vector(REG_WIDTH - 1 downto 0);
         Z3in    :  out std_logic_vector(REG_WIDTH - 1 downto 0);
         sRZ     :  out std_logic;
         sRN     :  out std_logic;
         sRO     :  out std_logic;
         sRC     :  out std_logic;
         D2Out   :  in std_logic_vector(REG_WIDTH - 1 downto 0);
         B2Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
         A2Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
         D3Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
         Z4D4Out :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
         rst     :  in std_logic;
         clk     :  in std_logic;
         IR2     :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR3     :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR4     :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
      );
   end component;
   
   signal Reg2ASig   : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal Reg2BSig   : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal regAOut    : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal regBOut    : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal regASel    : std_logic_vector(REG_BITS - 1 downto 0);
   signal regBSel    : std_logic_vector(REG_BITS - 1 downto 0);
   signal regDOut    : std_logic_vector(REG_WIDTH - 1 downto 0);
   
   signal ALUOut     : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal SR         : std_logic_vector(SR_WIDTH - 1 downto 0);
   signal d3Out      : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal z3In       : std_logic_vector(REG_WIDTH - 1 downto 0);
   
   signal ir3out     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir4out     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   
begin
   alu : ALUArea port map(
         ALUOut  => ALUOut,
         Z3in    => z3In,
         sRZ     => SR(Z_OFFSET),
         sRN     => SR(N_OFFSET),
         sRO     => SR(O_OFFSET),
         sRC     => SR(C_OFFSET),
         D2Out   => regDOut,
         B2Out   => regBOut,
         A2Out   => regAOut,
         D3Out   => d3Out,
         Z4D4Out => ...,
         rst     => rst,
         clk     => clk,
         IR2     => ir2,
         IR3     => ir3out,
         IR4     => ir4out
      );
   end component;

   regs : RegArea port map(
      pmemSel     => pmemSel,
      pmemOut     => pmemOut,
      regASel     => regASel,
      regBSel     => regBSel,
      regAOut     => reg2ASig,
      regBOut     => reg2BSig,
      SRin        => SR,
      regWriteSel => ...,
      regWriteVal => ...,
      regWrite    => ...,
      rst         => rst,
      clk         => clk
   );
   
   regA : Reg port map(
      doRead   => clk,
      input    => Reg2ASig,
      output   => regAOut,
      rst      => rst,
      clk      => clk
   );
   
   regB : Reg port map(
      doRead   => clk,
      input    => Reg2BSig,
      output   => regBOut,
      rst      => rst,
      clk      => clk
   );
   
   ir3   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
         doRead   => clk,
         input    => ir2,
         output   => ir3out,
         rst      => rst,
         clk      => clk
      );
   
   ir4   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
         doRead   => clk,
         input    => ir3out,
         output   => ir4out,
         rst      => rst,
         clk      => clk
      );
   
   d3Reg : Reg port map(
      doRead   => clk,
      input    => ALUOut,
      output   => d3Out,
      rst      => rst,
      clk      => clk
   );
   
   z3Reg : Reg port map(
      doRead   => clk,
      input    => z3In,
      output   => ...,
      rst      => rst,
      clk      => clk
   );
   
end Behavioral;