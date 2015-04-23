
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

--A2 and B2 are now in here as regAOut and regBOut
entity RegArea is
   port(
      pmemSel     : in std_logic_vector(REG_BITS - 1 downto 0);
      pmemOut     : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ir2         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      regAOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
      regBOut     : out std_logic_vector(REG_WIDTH - 1 downto 0);
      SRin        : in std_logic_vector(SR_WIDTH - 1 downto 0);
      SRout       : out std_logic_vector(SR_WIDTH - 1 downto 0);
      audioOut    : out std_logic_vector(REG_WIDTH - 1 downto 0);
      regWriteSel : in std_logic_vector(REG_BITS - 1 downto 0);
      regWriteVal : in std_logic_vector(REG_WIDTH - 1 downto 0);
      regWrite    : in std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end RegArea;
   
   
architecture Behavioral of RegArea is
   type regVal_t is array(REG_NUM - 1 downto 0) of std_logic_vector(REG_WIDTH - 1 downto 0);
   constant GREGS_NUM         : natural := 8;
   constant SR_REG_OFFSET     : natural := GREGS_NUM; -- since greg's last ID is one less than the number of gregs

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

   component Timer is
      generic(timer_width : natural := REG_WIDTH);
      port(
         loadValue   : in std_logic_vector(timer_width - 1 downto 0);
         finished    : out std_logic;
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;
   
   signal writeReg   : std_logic_vector(REG_NUM - 1 downto 0);
   signal regVal     : regVal_t;
   
   signal regASel    : std_logic_vector(REG_BITS - 1 downto 0);
   signal regBSel    : std_logic_vector(REG_BITS - 1 downto 0);
   
   signal ir2OP      : std_logic_vector(OP_WIDTH - 1 downto 0);
   --signal t          : std_logic_vector(REG_NUM - 1 downto 0);
   signal SRsig      : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');
   signal SRlast     : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');
   signal resetSR    : std_logic_vector(SR_WIDTH - 1 downto 0);

   signal lt1        : std_logic_vector(2*REG_WIDTH - 1 downto 0);
   signal lt1lsbs    : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal lt1msbs    : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal lt1done    : std_logic;
begin
   -- Generic Registers
   gregs : for I in 0 to GREGS_NUM - 1 generate
      genReg : Reg port map(
         doRead   => writeReg(I),
         input    => regWriteVal,
         output   => regVal(I),
         rst      => rst,
         clk      => clk
      );
   end generate gregs;
   
   -- Status Register
   SR  : Reg 
   generic map(regWidth => SR_WIDTH)
   port map(
      doRead   => '1',
      input    => SRsig,
      output   => regVal(SR_REG_OFFSET)(SR_WIDTH - 1 downto 0),
      rst      => rst,
      clk      => clk
   );
   SRout <= regVal(SR_REG_OFFSET)(SR_WIDTH - 1 downto 0);

   -- Long timer 1 (Register 16 & 17)
   lt1lsbs <= regWriteVal when writeReg(16) = '1' else (others => '0');
   lt1lsb : Reg
   generic map(regWidth => REG_WIDTH)
   port map(
      doRead   => clk,
      input    => lt1lsbs,
      output   => lt1(REG_WIDTH - 1 downto 0),
      rst      => rst,
      clk      => clk
   );
   lt1msbs <= regWriteVal when writeReg(17) = '1' else (others => '0');
   lt1msb : Reg
   generic map(regWidth => REG_WIDTH)
   port map(
      doRead   => clk,
      input    => lt1msbs,
      output   => lt1(2*REG_WIDTH - 1 downto REG_WIDTH),
      rst      => rst,
      clk      => clk
   );
   lt1t : Timer
   generic map(timer_width => 2*REG_WIDTH)
   port map(
         loadValue   => lt1,
         finished    => lt1done,
         rst         => rst,
         clk         => clk
   );

   -- Audio-out reg
   audioReg : Reg port map(
         doRead   => writeReg(31),
         input    => regWriteVal,
         output   => audioOut,
         rst      => rst,
         clk      => clk
      );
   -- fill with registers as appropriate
   
   -- Convenience signal
   ir2OP <= ir2(PMEM_WIDTH - 1 downto PMEM_WIDTH - OP_WIDTH);
   
   -- Set the bit in the map that is currently being written to
   wsel : for I in 0 to REG_NUM - 1 generate
      writeReg(I) <= '1' when to_integer(unsigned(regWriteSel)) = I else '0';
   end generate wsel;
   --t(0) <= regWrite;
   --writeReg <= std_logic_vector(unsigned(t) sll to_integer(unsigned(regWriteSel)));
   
   pmemOut <= regVal(to_integer(unsigned(pmemSel)))(ADDR_WIDTH - 1 downto 0);
   regAOut <= regVal(to_integer(unsigned(regASel)));
   regBOut <= regVal(to_integer(unsigned(regBSel)));

   -- Set the bit that should be reset if the current instruction reads a SR flag.
   rstsr : for I in SR_WIDTH - 1 downto 0 generate
      resetSR(I) <= '1' when ((ir2OP = "10000" OR
                              ir2OP = "10001" OR
                              ir2OP = "10010" OR
                              ir2OP = "10100" OR
                              ir2OP = "10101" OR
                              ir2OP = "10110") AND
                        to_integer(unsigned(ir2(PMEM_WIDTH - OP_WIDTH downto PMEM_WIDTH - OP_WIDTH - REG_BITS + 1))) = I) OR
                              to_integer(unsigned(regASel)) = SR_REG_OFFSET OR
                              to_integer(unsigned(regBSel)) = SR_REG_OFFSET else
                     '0';
                           
   end generate rstsr;

   process (clk) is
   begin
      if rising_edge(clk) then
         for I in SR_WIDTH - 1 downto 0 loop
            if resetSR(I) = '1' then
               SRlast(I) <= '0';
               -- Reset on read
            else
               SRlast(I) <= SRsig(I);
               -- Non-resetting flags need to keep their value once set
            end if;
         end loop;
      end if;
   end process;
   SRsig <= (( SRin(SR_WIDTH - 1 downto 5) &
               lt1done)
            or SRlast(SR_WIDTH - 1 downto 4)) & SRin(3 downto 0);
   
   -- Destination (or value to save to memory)
   regBSel <=  ir2(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1)
                  when  ir2OP = "11100"         -- LOAD.a
                     OR ir2OP = "11101"         -- LOAD.c
                     OR ir2OP = "11110"         -- LOAD.wo
                     OR ir2OP = "11111"         -- LOAD.wro
                     OR ir2OP = "00100" else    -- MOVE
               ir2(REG_BITS - 1 downto 0)
                  when  ir2OP = "11001"         -- STORE.r
                     OR ir2OP = "11010"         -- STORE.wo
                     OR ir2OP = "11011" else    -- STORE.wofr
               ir2(REG_ALU_OFFSET downto REG_ALU_OFFSET - REG_BITS + 1)
                  when  ir2OP = "00101"         -- ALUINST.r
                     OR ir2OP = "00110" else    -- ALUINST.c
               (others => '0');
   -- Source
   regASel <=  ir2(REG_BITS - 1 downto 0)
                  when  ir2OP = "00100"         -- MOVE
                     OR ir2OP = "00101" else    -- ALUINST.r
               ir2(LOAD_WRO_OFFSET downto LOAD_WRO_OFFSET - REG_BITS + 1)
                  when  ir2OP = "11111" else    -- LOAD.wro
               ir2(STORE_WOFR_OFFSET downto STORE_WOFR_OFFSET - REG_BITS + 1) -- wrong offset?
                  when  ir2OP = "11011" else    -- STORE.wofr
               (others => '0');
   
end Behavioral;

