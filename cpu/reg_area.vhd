
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

architecture RegArea is
   port(
      pmemSel     : in std_logic_vector(REG_BITS - 1 downto 0);
      pmemOut     : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ir1         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      regAOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
      regBOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
      SRin        : in std_logic_vector(SR_WIDTH - 1 downto 0);
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
   
   signal regASel    : in std_logic_vector(REG_BITS - 1 downto 0);
   signal regBSel    : in std_logic_vector(REG_BITS - 1 downto 0);
   -- Convenience signal
   ir1OP <= irOut(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
begin
   -- Generic Register 0
   genReg0  : Reg port map(
      doRead   => writeReg(0),
      input    => regWriteVal,
      output   => regVal(0),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 1
   genReg1  : Reg port map(
      doRead   => writeReg(1),
      input    => regWriteVal,
      output   => regVal(1),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 2
   genReg2  : Reg port map(
      doRead   => writeReg(2),
      input    => regWriteVal,
      output   => regVal(2),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 3
   genReg3  : Reg port map(
      doRead   => writeReg(3),
      input    => regWriteVal,
      output   => regVal(3),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 4
   genReg4  : Reg port map(
      doRead   => writeReg(4),
      input    => regWriteVal,
      output   => regVal(4),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 5
   genReg5  : Reg port map(
      doRead   => writeReg(5),
      input    => regWriteVal,
      output   => regVal(5),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 6
   genReg6  : Reg port map(
      doRead   => writeReg(6),
      input    => regWriteVal,
      output   => regVal(6),
      rst      => rst,
      clk      => clk
   );
   -- Generic Register 7
   genReg7  : Reg port map(
      doRead   => writeReg(7),
      input    => regWriteVal,
      output   => regVal(7),
      rst      => rst,
      clk      => clk
   );
   -- Status Register
   SR  : Reg 
   generic map(regWidth => SR_WIDTH)
   port map(
      doRead   => writeReg(7),
      input    => regWriteVal,
      output   => regVal(7),
      rst      => rst,
      clk      => clk
   );
   
   -- fill with registers as appropriate
   
   -- Set the bit in the map that is currently being written to
   writeReg <= (others => '0') OR regWrite sll to_integer(unsigned(regWriteSel));
   
   pmemOut <= regVal(pmemSel);
   regAOut <= regVal(regASel);
   regBOut <= regVal(regBSel);
   
   -- Destination
   regBSel <=  ir1(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1)
                  when  ir1OP = "11100"         -- LOAD.a
                     OR ir1OP = "11101"         -- LOAD.c
                     OR ir1OP = "11110"         -- LOAD.wo
                     OR ir1OP = "11111"         -- LOAD.wro
                     OR ir1OP = "00100" else    -- MOVE
               ir1(REG_ALU_OFFSET downto REG_ALU_OFFSET - REG_BITS + 1)
                  when  ir1OP = "00101"         -- ALUINST.r
                     OR ir1OP = "00110" else    -- ALUINST.c
               ir1(REG_STORE_OFFSET downto REG_STORE_OFFSET - REG_BITS + 1)
                  when  ir1OP = "11011" else    -- STORE.wofr
               (others => '0');
   -- Source
   regASel <=  ir1(REG_WIDTH - 1 downto 0)
                  when  ir1OP = "11001"         -- STORE.r
                     OR ir1OP = "11010"         -- STORE.wo
                     OR ir1OP = "11011"         -- STORE.wofr
                     OR ir1OP = "00100"         -- MOVE
                     OR ir1OP = "00101" else    -- ALUINST.r
               ir1(REG_LOAD_OFFSET downto REG_LOAD_OFFSET - REG_BITS + 1)
                  when  ir1OP = "11111" else    -- LOAD.wro
               (others => '0');
   
end Behavioral;