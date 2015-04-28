library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity Synth is
   port(
      mclk        : out std_logic;
      lrck        : out std_logic;
      sclk        : out std_logic;
      sdin        : out std_logic;
      seg         : out std_logic_vector(7 downto 0);
      an          : out std_logic_vector(3 downto 0);
      uart        : in std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end Synth;

architecture Behavioral of Synth is

   constant SAMPLE_SIZE : natural := 16;
   constant MIDI_WIDTH  : natural := 8;

   component CPUArea is
      port(
         audioOut    : out std_logic_vector(SAMPLE_SIZE - 1 downto 0);
         mreg1       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg2       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg3       : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
         midiRdy     : in std_logic;
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;

   component SoutArea is
      port(
         clk               : in std_logic;
         rst               : in std_logic;
         sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
         mclk              : out std_logic; -- Master clock
         lrck              : out std_logic; -- Left/Right clock
         sdout             : out std_logic; -- Serial data output
         sclk              : out std_logic
      );
   end component;

   component MidiArea is
      port(
         clk      : in std_logic;
         rst      : in std_logic;
         uart     : in std_logic;
         mreg1    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg2    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         mreg3    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         readRdy  : out std_logic -- pulse when a complete message is ready in Mreg1-3
      );
   end component;

   signal audio      : std_logic_vector(SAMPLE_SIZE - 1 downto 0);
   
   signal sdouts     : std_logic;
   --signal sclkS      : std_logic;

   signal mreg1S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg2S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg3S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal midiRdyS   : std_logic;

   signal counter_r :  unsigned(17 downto 0) := "000000000000000000";


begin

   cpu : CPUArea port map(
      audioOut    => audio,
      mreg1       => mreg1S,
      mreg2       => mreg2S,
      mreg3       => mreg3S,
      midiRdy     => midiRdyS,
      rst         => rst,
      clk         => clk
   );

   sout : SoutArea port map(
      clk            => clk,
      rst            => rst,
      sampleBuffer   => audio,
      mclk           => mclk,
      lrck           => lrck,
      sdout          => sdouts,
      sclk           => sclk
   );

   midi : MidiArea port map(
      clk      => clk,
      rst      => rst,
      uart     => uart,
      mreg1    => mreg1S,
      mreg2    => mreg2S,
      mreg3    => mreg3S,
      readRdy  => midiRdyS
   );

   process(clk) begin
     if rising_edge(clk) then 
       counter_r <= counter_r + 1;

      case counter_r(17 downto 16) is
         when "00" => an <= "0111";
         when "01" => an <= "1011";
         when "10" => an <= "1101";
         when others => an <= "1110";
       end case;
     end if;
   end process;
   
   --sclk <= '1'; -- or '1'?
   sdin <= sdouts;
   seg <= audio(7 downto 0);

end Behavioral;
