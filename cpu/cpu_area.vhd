library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity CPUArea is
   port(
      audioOut    : out std_logic_vector(REG_WIDTH - 1 downto 0);
      mreg1       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      midiRdy     : in std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end CPUArea;

architecture Behavioral of CPUArea is
   component MainArea is
      port(
         ir1         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         ir2         : in std_logic_vector(PMEM_WIDTH - 1 downto 0);
         pmemSel     : in std_logic_vector(REG_BITS - 1 downto 0);
         pmemOut     : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
         srOut       : out std_logic_vector(SR_WIDTH - 1 downto 0);
         audioOut    : out std_logic_vector(REG_WIDTH - 1 downto 0);
         mreg1       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg2       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg3       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         midiRdy     : in std_logic;
         rst         : in std_logic;
         clk         : in std_logic
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
   main : MainArea port map(
      ir1         => ir1,
      ir2         => ir2,
      pmemSel     => regSel,
      pmemOut     => regVal,
      srOut       => sr,
      audioOut    => audioOut,
      mreg1       => mreg1,
      mreg2       => mreg2,
      mreg3       => mreg3,
      midiRdy     => midiRdy,
      rst         => rst,
      clk         => clk
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

