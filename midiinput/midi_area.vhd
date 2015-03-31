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
      msgReady    : out std_logic -- 1 if a complete message has been read into m1
   );
end component;

component CheckMsg is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      msgReady          : in std_logic; -- 1 when there is a msg ready in tmpReg
      outReady          : in std_logic; -- 1 when message is ready to be transfered from tmpReg to mreg#
      muxCtr            : in std_logic_vector(1 downto 0);
      tmpReg            : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg1             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      validMsgO         : out std_logic; -- 1 when we have a valid incoming midi-msg
      msgReadyDelayed   : out std_logic; -- A msgReady pulse that is delayed by 1 ck
      readRdy           : out std_logic -- pulse when a complete message is ready in Mreg1-3
   );
end component;

component MuxCounter is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      validMsgI         : in std_logic; -- 1 when the message in tmpReg is valid
      msgReadyDelayed   : in std_logic; -- 1 when a message is ready in tmpReg
      muxCtr            : out std_logic_vector(1 downto 0); -- MUX counter
      outReady          : out std_logic -- 1 when the message is ready to be transfered from tmpReg to mreg#
   );
end component;


signal tmpRegS          : std_logic_vector(MIDI_WIDTH - 1 downto 0);
signal msgReady         : std_logic;
signal msgReadyDelayedS : std_logic;
signal outReady         : std_logic;
signal muxCtr           : std_logic_vector(1 downto 0);
signal validMsg         : std_logic;

begin

   midiUartInput  : MidiInput port map(
      clk => clk, 
      rst => rst,
      uart => uart,
      tmpReg => tmpRegS,
      msgReady => msgReady
   );
   
   midiCheckMsg   : CheckMsg port map(
      clk => clk, 
      rst => rst,
      msgReady => msgReady,
      msgReadyDelayed => msgReadyDelayedS,
      outReady => outReady,
      muxCtr => muxCtr,
      tmpReg => tmpRegS,
      mreg1 => mreg1,
      mreg2 => mreg2,
      mreg3 => mreg3,
      validMsgO => validMsg,
      readRdy => readRdy
   );
   
   midiMuxCounter  : MuxCounter port map(
      clk => clk, 
      rst => rst,
      validMsgI => validMsg,
      msgReadyDelayed => msgReadyDelayedS,
      muxCtr => muxCtr,
      outReady => outReady
   );

end Behavioral;
