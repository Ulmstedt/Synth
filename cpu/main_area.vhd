library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity MainArea is
   port(
      ir1               : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      ir2               : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
      pmemSel           : in std_logic_vector(REG_BITS - 1 downto 0);
      pmemOut           : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      srOut             : out std_logic_vector(SR_WIDTH - 1 downto 0);
      audioOut          : out std_logic_vector(REG_WIDTH - 1 downto 0);
      mreg1             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      midiRdy           : in std_logic;

      tmpOut      : out std_logic_vector(REG_WIDTH/2 - 1 downto 0);

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

      tileXcnt          : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileYcnt          : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileMapOut        : out std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);  

      coordOut          : in std_logic_vector(8 downto 0);
      writeX            : in std_logic;
      writeY            : in std_logic;
      coordReady        : in std_logic;    

      rst               : in std_logic;
      clk               : in std_logic
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

         coordIn           : in std_logic_vector(8 downto 0);
         writeX            : in std_logic;
         writeY            : in std_logic;
         coordReady        : in std_logic;

         rst               : in std_logic;
         clk               : in std_logic
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
         IR4     :  in std_logic_vector(REG_WIDTH*2-1 downto 0)
      );
   end component;
   
   component MemArea is
      port(
         ir3         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir4         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         z3          : in std_logic_vector(REG_WIDTH - 1 downto 0);
         d3          : in std_logic_vector(REG_WIDTH - 1 downto 0);
         z4d4        : out std_logic_vector(REG_WIDTH - 1 downto 0);
         regSel      : out std_logic_vector(REG_BITS - 1 downto 0);
         doWrite     : out std_logic;
         rst         : in std_logic;
         clk         : in std_logic;

         tmpOut      : out std_logic_vector(REG_WIDTH/2 - 1 downto 0);

         tileXcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
         tileYcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
         tileMapOut  : out std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0)
      );
   end component;

   component DReg is
      port(
         ir1in    : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         output   : out std_logic_vector(REG_WIDTH - 1 downto 0);
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   signal Reg2ASig      : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal Reg2BSig      : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal regDOut       : std_logic_vector(REG_WIDTH - 1 downto 0);

   signal ALUOut        : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal SR            : std_logic_vector(SR_WIDTH - 1 downto 0) := (others => '0');
   signal d3Out         : std_logic_vector(REG_WIDTH - 1 downto 0);

   signal z3In          : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal z3Out         : std_logic_vector(REG_WIDTH - 1 downto 0);
   
   signal ir3out        : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir4out        : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   
   signal regWriteSel   : std_logic_vector(REG_BITS - 1 downto 0);
   signal regWriteVal   : std_logic_vector(REG_WIDTH - 1 downto 0);
   signal regWrite      : std_logic;
   
begin

   d2  : DReg port map(   
      ir1in    => ir1,
      output   => regDOut,
      rst      => rst,
      clk      => clk
   );

   alu : ALUArea port map(
      ALUOut  => ALUOut,
      Z3in    => z3In,
      sRZ     => SR(Z_OFFSET),
      sRN     => SR(N_OFFSET),
      sRO     => SR(O_OFFSET),
      sRC     => SR(C_OFFSET),
      D2Out   => regDOut,
      B2Out   => reg2BSig,
      A2Out   => reg2ASig,
      D3Out   => d3Out,
      Z4D4Out => regWriteVal,
      rst     => rst,
      clk     => clk,
      IR2     => ir2,
      IR3     => ir3out,
      IR4     => ir4out
   );
   
   mem : MemArea port map(
      ir3         => ir3out,
      ir4         => ir4out,
      z3          => z3Out,
      d3          => d3Out,
      z4d4        => regWriteVal,
      regSel      => regWriteSel,
      doWrite     => regWrite,
      rst         => rst,
      clk         => clk,
      tileXcnt    => tileXcnt,
      tileYcnt    => tileYcnt,
      tmpOut      => tmpOut,
      tileMapOut  => tileMapOut
   );

   regs : RegArea port map(
      pmemSel        => pmemSel,
      pmemOut        => pmemOut,
      ir2            => ir2,
      regAOut        => reg2ASig,
      regBOut        => reg2BSig,
      SRin           => SR,
      SRout          => srOut,
      audioOut       => audioOut,
      regWriteSel    => regWriteSel,
      regWriteVal    => regWriteVal,
      regWrite       => regWrite,
      mreg1          => mreg1,
      mreg2          => mreg2,
      mreg3          => mreg3,
      midiRdy        => midiRdy,

      SVFwriteDelay  => SVFwriteDelay,
      SVFcur         => SVFcur,
      SVFdelay1in    => SVFdelay1in,
      SVFdelay1out   => SVFdelay1out,
      SVFdelay2in    => SVFdelay2in,
      SVFdelay2out   => SVFdelay2out,
      SVFoutput      => SVFoutput,
      SVFf           => SVFf,
      SVFq           => SVFq,
      SVFrun         => SVFrun,
      SVFType        => SVFType,

      coordIn        => coordOut,
      writeX         => writeX,
      writeY         => writeY,
      coordReady     => coordReady,

      rst            => rst,
      clk            => clk
   );
   
   ir3   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
         doRead   => '1',
         input    => ir2,
         output   => ir3out,
         rst      => rst,
         clk      => clk
      );
   
   ir4   : Reg
      generic map(regWidth => PMEM_WIDTH)
      port map(
         doRead   => '1',
         input    => ir3out,
         output   => ir4out,
         rst      => rst,
         clk      => clk
      );
   
   d3Reg : Reg port map(
      doRead   => '1',
      input    => ALUOut,
      output   => d3Out,
      rst      => rst,
      clk      => clk
   );
   
   z3Reg : Reg port map(
      doRead   => '1',
      input    => z3In,
      output   => z3out,
      rst      => rst,
      clk      => clk
   );
   
end Behavioral;

