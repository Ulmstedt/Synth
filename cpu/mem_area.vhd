library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity MemArea is
   port(
      ir4      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      z3       : in std_logic_vector(REG_WIDTH - 1 downto 0);
      d3       : in std_logic_vector(REG_WIDTH - 1 downto 0);
      z4d4     : out std_logic_vector(REG_WIDTH - 1 downto 0);
      regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
      doWrite  : out std_logic;
      rst      : in std_logic;
      clk      : in std_logic
   );
end MemArea;

architecture Behavioral of MemArea is
   component Memory is
      port(
         addr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         output   : out std_logic_vector(REG_WIDTH - 1 downto 0);
         doWrite  : in std_logic;
         newValue : in std_logic_vector(REG_WIDTH - 1 downto 0);
         clk      : in std_logic
      );
   end component;
   
   component Z4D4Mux is
      port(
         IR4      : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         z4       : in std_logic_vector(REG_WIDTH - 1 downto 0);
         d4       : in std_logic_vector(REG_WIDTH - 1 downto 0);
         doWrite  : out std_logic;
         regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
         newValue : out std_logic_vector(REG_WIDTH - 1 downto 0)
      );
   end component;
   
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
   
   signal memOut     : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal z4out      : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal d4out      : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal memWrite   : std_logic;
   signal ir4OP      : std_logic_vector(OP_WIDTH - 1 downto 0);
begin
   -- Z4
   z4 : Reg port map(
      doRead   => clk,
      input    => memOut,
      output   => z4out,
      rst      => rst,
      clk      => clk
   );
   -- D4
   d4 : Reg port map(
      doRead   => clk,
      input    => d3,
      output   => d4out,
      rst      => rst,
      clk      => clk
   );
   -- Memory
   mem : Memory port map(
      addr     => d3(ADDR_WIDTH - 1 downto 0),
      output   => memOut,
      doWrite  => memWrite,
      newValue => z3,
      clk      => clk
   );
   
   d4z4mux : Z4D4Mux port map(
      IR4      => ir4,
      z4       => z4out,
      d4       => d4out,
      doWrite  => doWrite,
      regSel   => regSel,
      newValue => z4d4
   );
   
   -- Convenience signal
   ir4OP <= ir4(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
   memWrite <= '1' when ir4OP = "11000" OR ir4OP = "11001" 
                     OR ir4OP = "11010" OR ir4OP = "11011" else
               '0';
end Behavioral;