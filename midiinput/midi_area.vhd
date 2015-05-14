library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity MidiArea is
   port(
      clk      : in std_logic;
      rst      : in std_logic;
      uart     : in std_logic;
      mreg1    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      m1out    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      readRdy  : out std_logic -- pulse when a complete message is ready in Mreg1-3
   );
end MidiArea;

architecture Behavioral of MidiArea is

   component MidiInput is
      port(
         clk         : in std_logic; -- Clock
         rst         : in std_logic; -- Reset
         uart        : in std_logic; -- Incoming message bit
         tmpReg      : out std_logic_vector(MIDI_WIDTH - 1 downto 0); -- The full UART message
         m1out       : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         msgReady    : out std_logic -- 1 if a complete message has been read into m1
      );
   end component;

   component CheckMsg is
      port(
         clk               : in std_logic; -- Clock
         rst               : in std_logic; -- Reset
         msgReady          : in std_logic; -- 1 when there is a msg ready in tmpReg
         tmpReg            : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg1             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg2             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg3             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         readRdy           : out std_logic -- pulse when a complete message is ready in Mreg1-3
      );
   end component;


   signal tmpRegS          : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal msgReady         : std_logic;

begin

   midiUartInput  : MidiInput port map(
      clk => clk, 
      rst => rst,
      uart => uart,
      tmpReg => tmpRegS,
      m1out    => m1out,
      msgReady => msgReady
   );
   
   midiCheckMsg   : CheckMsg port map(
      clk => clk, 
      rst => rst,
      msgReady => msgReady,
      tmpReg => tmpRegS,
      mreg1 => mreg1,
      mreg2 => mreg2,
      mreg3 => mreg3,
      readRdy => readRdy
   );

end Behavioral;
