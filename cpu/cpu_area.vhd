library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

-- Binds together Pmem area and the main area (with ALU and similar)
entity CPUArea is
   port(
      audioOut          : out std_logic_vector(REG_WIDTH - 1 downto 0);
      mreg1             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      midiRdy           : in std_logic;
      srOut             : out std_logic_vector(7 downto 0);

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

      coordOut          : in std_logic_vector(8 downto 0);
      writeX            : in std_logic;
      writeY            : in std_logic;
      coordReady        : in std_logic;

      tileXcnt          : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileYcnt          : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileMapOut        : out std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);
   
      rst               : in std_logic;
      clk               : in std_logic      
   );
end CPUArea;

architecture Behavioral of CPUArea is
   component MainArea is
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
   end component;
   
   component PMemArea is
      port(
         ir1out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir2out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
         regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
         regIn    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         sr       : in std_logic_vector(SR_WIDTH - 1 downto 0);
         rst      : in std_logic;
         clk      : in std_logic
      );
   end component;
   
   signal ir1     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal ir2     : std_logic_vector(PMEM_WIDTH - 1 downto 0);
   signal regSel  : std_logic_vector(REG_BITS - 1 downto 0);
   signal regVal  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal sr      : std_logic_vector(SR_WIDTH - 1 downto 0);
   
begin

   srOut <= sr(7 downto 0);

   main : MainArea port map(
      ir1            => ir1,
      ir2            => ir2,
      pmemSel        => regSel,
      pmemOut        => regVal,
      srOut          => sr,
      audioOut       => audioOut,
      mreg1          => mreg1,
      mreg2          => mreg2,
      mreg3          => mreg3,
      midiRdy        => midiRdy,

      tmpOut         => tmpOut,

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

      coordOut       => coordOut,
      writeX         => writeX,
      writeY         => writeY,
      coordReady     => coordReady,

      rst            => rst,
      clk            => clk,

      tileXcnt       => tileXcnt,
      tileYcnt       => tileYcnt,
      tileMapOut     => tileMapOut
   );
   
   pmem : PMemArea port map(
      ir1out      => ir1,
      ir2out      => ir2,
      regSel      => regSel,
      regIn       => regVal,
      sr          => sr,
      rst         => rst,
      clk         => clk
   );
end Behavioral;

