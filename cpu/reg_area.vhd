
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

--A2 and B2 are now in here as regAOut and regBOut
entity RegArea is
   port(
      pmemSel           : in std_logic_vector(REG_BITS - 1 downto 0);
      pmemOut           : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      ir2               : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      regAOut           : out std_logic_vector(REG_WIDTH - 1 downto 0);
      regBOut           : out std_logic_vector(REG_WIDTH - 1 downto 0);

      SRin              : in std_logic_vector(SR_WIDTH - 1 downto 0);
      SRout             : out std_logic_vector(SR_WIDTH - 1 downto 0);
      audioOut          : out std_logic_vector(REG_WIDTH - 1 downto 0);

      regWriteSel       : in std_logic_vector(REG_BITS - 1 downto 0);
      regWriteVal       : in std_logic_vector(REG_WIDTH - 1 downto 0);
      regWrite          : in std_logic;

      mreg1             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      midiRdy           : in std_logic;
      
      SVFwriteDelay     : in std_logic;
      SVFcur            : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFdelay1in       : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFdelay1out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFdelay2in       : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFdelay2out      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFoutput         : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFf              : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFq              : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      SVFrun            : out std_logic;
      SVFType           : out std_logic_vector(1 downto 0);

      writeX            : in std_logic;
      writeY            : in std_logic;
      coordIn           : in std_logic_vector(8 downto 0);
      coordReady        : in std_logic;

      rst               : in std_logic;
      clk               : in std_logic
   );
end RegArea;
   
   
architecture Behavioral of RegArea is
   type regVal_t is array(REG_NUM - 1 downto 0) of std_logic_vector(REG_WIDTH - 1 downto 0);
   constant GREGS_NUM         : natural := 14;
   constant SR_REG_OFFSET     : natural := GREGS_NUM; 
   -- since greg's last ID is one less than the number of gregs

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
   signal t          : std_logic_vector(REG_NUM - 1 downto 0) := (others => '0');
   signal SRsig      : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');
   signal SRlast     : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');
   signal resetSR    : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');

   -- Long timer signals
   signal lt1        : std_logic_vector(2*REG_WIDTH - 1 downto 0);
   signal lt1lsbs    : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
   signal lt1msbs    : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
   signal lt1done    : std_logic;

   -- Short timer signals
   signal st1        : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal st1s       : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
   signal st1done    : std_logic;

   signal st2        : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal st2s       : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
   signal st2done    : std_logic;

   -- Midi signals
   signal mreg12S    : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal mreg3S     : std_logic_vector(REG_WIDTH - 1 downto 0);

   signal delay1in   : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay2in   : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay1read : std_logic;
   signal delay2read : std_logic;

   -- Filter signals
   signal runNow     : std_logic;
   signal runLast    : std_logic;


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
      doRead   => '1',
      input    => lt1lsbs,
      output   => lt1(REG_WIDTH - 1 downto 0),
      rst      => rst,
      clk      => clk
   );
   lt1msbs <= regWriteVal when writeReg(17) = '1' else (others => '0');
   lt1msb : Reg
   generic map(regWidth => REG_WIDTH)
   port map(
      doRead   => '1',
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

   -- Short timer 1 (Register 18)
   st1s <= regWriteVal when writeReg(18) = '1' else (others => '0');
   st1r : Reg
   generic map(regWidth => REG_WIDTH)
   port map(
      doRead   => '1',
      input    => st1s,
      output   => st1,
      rst      => rst,
      clk      => clk
   );
   st1t : Timer
   generic map(timer_width => REG_WIDTH)
   port map(
      loadValue   => st1,
      finished    => st1done,
      rst         => rst,
      clk         => clk
   );

   -- Short timer 2 (Register 19)
   st2s <= regWriteVal when writeReg(19) = '1' else (others => '0');
   st2r : Reg
   generic map(regWidth => REG_WIDTH)
   port map(
      doRead   => '1',
      input    => st2s,
      output   => st2,
      rst      => rst,
      clk      => clk
   );
   st2t : Timer
   generic map(timer_width => REG_WIDTH)
   port map(
      loadValue   => st2,
      finished    => st2done,
      rst         => rst,
      clk         => clk
   );

   -- Touch coord regs (20-21)
   touchX : Reg port map(
      doRead            => writeX,
      input(15 downto 9)=> (others => '0'),
      input(8 downto 0) => coordIn, -- coordIn is only 9 bits wide
      output            => regVal(20),
      rst               => rst,
      clk               => clk
   );

   touchY : Reg port map(
      doRead            => writeY,
      input(15 downto 9)=> (others => '0'),
      input(8 downto 0) => coordIn, -- coordIn is only 9 bits wide
      output            => regVal(21),
      rst               => rst,
      clk               => clk
   );

   -- 6 Filter registers ---
   -- SVF current sample (Register 22) remember to send load filter signal to SVF 
   SVFcur <= regVal(22);
   SVFin : Reg port map(
      doRead   => writeReg(22),
      input    => regWriteVal,
      output   => regVal(22),
      rst      => rst,
      clk      => clk
   );

   -- SVF delay1in (Register 23)
   SVFdelay1out <= regVal(23);
   delay1in <= SVFdelay1in when SVFwriteDelay = '1' else regWriteVal;
   delay1read <= writeReg(23) or SVFwriteDelay;
   SVFd1 : Reg port map(
      doRead   => delay1read,
      input    => delay1in,
      output   => regVal(23),
      rst      => rst,
      clk      => clk
   );

   -- SVF delay2in (Register 24)
   SVFdelay2out <= regVal(24);
   delay2in <= SVFdelay2in when SVFwriteDelay = '1' else regWriteVal;
   delay2read <= writeReg(24) or SVFwriteDelay;
   SVFd2 : Reg port map(
      doRead   => delay2read,
      input    => delay2in,
      output   => regVal(24),
      rst      => rst,
      clk      => clk
   );

   -- SVF output (Register 25)
   SVFout : Reg port map(
      doRead   => SVFwriteDelay,
      input    => SVFoutput,
      output   => regVal(25),
      rst      => rst,
      clk      => clk
   );

   -- SVF f (frequency) (Register 26)
   SVFfr : Reg port map(
      doRead   => writeReg(26),
      input    => regWriteVal,
      output   => SVFf,
      rst      => rst,
      clk      => clk
   );

   -- SVF q (resonance) (Register 27)
   SVFqr : Reg port map(
      doRead   => writeReg(27),
      input    => regWriteVal,
      output   => SVFq,
      rst      => rst,
      clk      => clk
   );

   -- Setup register (Register 28)
   Setup : Reg port map(
      doRead   => writeReg(28),
      input    => regWriteVal,
      output   => regVal(28),
      rst      => rst,
      clk      => clk
   );
   SVFType <= regVal(28)(1 downto 0);
   
   -- Midi register 1 & 2 (Register 29)
   mreg12S <= mreg1 & mreg2;
   mregister12 : Reg port map(
      doRead   => midiRdy,
      input    => mreg12S,
      output   => regVal(29),
      rst      => rst,
      clk      => clk
   );

   -- Midi register 3 (Register 30)
   mreg3S <= "00000000" & mreg3;
   mregister3 : Reg port map(
      doRead   => midiRdy,
      input    => mreg3S,
      output   => regVal(30),
      rst      => rst,
      clk      => clk
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
      writeReg(I) <= regWrite when to_integer(unsigned(regWriteSel)) = I else '0';
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
                              regVal(SR_REG_OFFSET)(I) = '1' AND
                        to_integer(unsigned(ir2(PMEM_WIDTH - OP_WIDTH downto PMEM_WIDTH - OP_WIDTH - REG_BITS + 1))) = I) OR
                              to_integer(unsigned(regASel)) = SR_REG_OFFSET OR
                              to_integer(unsigned(regBSel)) = SR_REG_OFFSET else
                     '0';
                           
   end generate rstsr;

   process (clk) is
   begin
      if rising_edge(clk) then

         runNow   <= writeReg(22); -- If SVFin reg was written to, run the filter  
         runLast  <= runNow;       -- Needs to be high two consec. clk pulses

         for I in SR_WIDTH - 1 downto 0 loop
            if resetSR(I) = '1' or rst = '1' then
               SRlast(I) <= '0';
               -- Reset on read
            else
               SRlast(I) <= SRsig(I);
               -- Non-resetting flags need to keep their value once set
            end if;
         end loop;
      end if;
   end process;
   SVFrun <= runLast or runNow;
   
   SRsig <= (( SRin(SR_WIDTH - 1 downto 9) &
               coordReady & midiRdy & st2done & st1done & lt1done)
            or SRlast(SR_WIDTH - 1 downto 4)) & SRin(3 downto 0);
   
   -- Destination (or value to save to memory)
   regBSel <=  ir2(REG_DEST_OFFSET downto REG_DEST_OFFSET - REG_BITS + 1)
                  when  ir2OP = "11100"         -- LOAD.a
                     OR ir2OP = "11101"         -- LOAD.c
                     OR ir2OP = "11110" else    -- LOAD.wo
               ir2(REG_BITS - 1 downto 0)
                  when  ir2OP = "11001"         -- STORE.r
                     OR ir2OP = "11010"         -- STORE.wo
                     OR ir2OP = "11011"         -- STORE.wofr
                     OR ir2OP = "00100" else    -- move
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

