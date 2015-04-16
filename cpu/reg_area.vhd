
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

architecture RegArea is
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
end RegArea;
   
   
entity Behavioral of RegArea is
   type regId_t is array (REG_BITS - 1 downto 0) of std_logic;
   type regVal_t is array(REG_BITS - 1 downto 0) of std_logic_vector(REG_WIDTH - 1 downto 0);

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
   
   signal writeReg   : regId_t;
   signal regVal     : regVal_t;
begin
   -- Generic Register 0
   genReg0  : Reg port map(
      doRead   <= writeReg(0),
      input    <= regWriteVal,
      output   <= regVal(0),
      rst      <= rst,
      clk      <= clk
   );
   -- Generic Register 1
   genReg1  : Reg port map(
      doRead   <= writeReg(1),
      input    <= regWriteVal,
      output   <= regVal(1),
      rst      <= rst,
      clk      <= clk
   );
   -- Generic Register 2
   genReg2  : Reg port map(
      doRead   <= writeReg(2),
      input    <= regWriteVal,
      output   <= regVal(2),
      rst      <= rst,
      clk      <= clk
   );
   -- fill with registers as appropriate
   
   -- Set the bit in the map that is currently being written to
   writeReg <= (others => '0') OR regWrite sll to_integer(unsigned(regWriteSel));
   
   pmemOut <= regVal(pmemSel);
   regAOut <= regVal(regASel);
   regBOut <= regVal(regBSel);
   
end Behavioral;