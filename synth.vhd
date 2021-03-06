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
      
      --LCDtft stuff
      IOP         : out std_logic_vector(20 downto 1):= "00000000000000000000";
      ION         : out std_logic_vector(20 downto 1) := "00000000000000000000";
      TP_BUSY     : in std_logic;
      TP_DOUT     : in std_logic;
      TP_DIN      : out std_logic;
      TP_PENIRQ   : in std_logic;
      TP_CS       : out std_logic;
      TP_DCLK     : out std_logic;

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
         audioOut          : out std_logic_vector(SAMPLE_SIZE - 1 downto 0);
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
         m1out    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
         readRdy  : out std_logic -- pulse when a complete message is ready in Mreg1-3
      );
   end component;
   
   component LCDArea is
      port(
         rst               : in std_logic;
         clk               : in std_logic;
         
         XCountHighBits    : out std_logic_vector(HIGHER_BITS - 1 downto 0);
         YCountHighBits    : out std_logic_vector(HIGHER_BITS - 1 downto 0);
         TileAdress        : in std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);

         IOPi              : out std_logic_vector(20 downto 1);
         IONi              : out std_logic_vector(20 downto 1);
         TP_BUSYi          : in std_logic;
         TP_DOUTi          : in std_logic;
         TP_PENIRQi        : in std_logic
      );
   end component;


   component SVF is
      port(
         sample      : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay1in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay2in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         output      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay1out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         delay2out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         q           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
         svfType     : in std_logic_vector(1 downto 0);
         loadFilter  : in std_logic;
         saveDelay   : out std_logic;
         rst         : in std_logic;
         clk         : in std_logic
      );
   end component;

   signal audio      : std_logic_vector(SAMPLE_SIZE - 1 downto 0);
   
   signal sdouts     : std_logic;

   signal mreg1S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg2S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg3S     : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal midiRdyS   : std_logic;

   signal sampleS    : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay1inS  : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay2inS  : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal outputS    : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay1outS : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal delay2outS : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal fS         : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal qS         : std_logic_vector(AUDIO_WIDTH - 1 downto 0);
   signal loadFilterS: std_logic;
   signal saveDelayS : std_logic;
   signal halvedDelay: std_logic;
   signal svfType    : std_logic_vector(1 downto 0);
   signal svfClk     : std_logic := '0';
   signal lastLoad   : std_logic := '0';

   signal counter_r  :  unsigned(17 downto 0) := "000000000000000000";

   signal m1         : std_logic_vector(7 downto 0);

   signal srSig      : std_logic_vector(7 downto 0);

   signal memTemp    : std_logic_vector(REG_WIDTH/2 - 1 downto 0);

   signal XCountMSBBits       : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal YCountMSBBits       : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal tileAdressfromCPU   : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);

   -- Touch
   signal coordOutS   : std_logic_vector(8 downto 0);
   signal tmpS        : std_logic_vector(11 downto 0);
   signal writeXS     : std_logic;
   signal writeYS     : std_logic;
   signal coordReadyS : std_logic;

begin
   cpu : CPUArea port map(
      audioOut       => audio,
      mreg1          => mreg1S,
      mreg2          => mreg2S,
      mreg3          => mreg3S,
      midiRdy        => midiRdyS,
      srOut          => srSig,

      tmpOut         => memTemp,

      SVFwriteDelay  => saveDelayS,
      SVFcur         => sampleS,
      SVFdelay1in    => delay1inS,
      SVFdelay1out   => delay1outS,
      SVFdelay2in    => delay2inS,
      SVFdelay2out   => delay2outS,
      SVFoutput      => outputS,
      SVFf           => fS,
      SVFq           => qS,
      SVFrun         => loadFilterS,
      SVFType        => svfType,

      coordOut       => coordOutS,
      writeX         => writeXS,
      writeY         => writeYS,
      coordReady     => coordReadyS,

      rst            => rst,
      clk            => clk,
      tileXcnt       => XCountMSBBits,
      tileYcnt       => YCountMSBBits,
      tileMapOut     => tileAdressfromCPU
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
      m1out    => m1,
      readRdy  => midiRdyS
   );


   SVFc : SVF port map(
      sample      => sampleS,
      delay1in    => delay1outS,
      delay2in    => delay2outS,
      output      => outputS,
      delay1out   => delay1inS,
      delay2out   => delay2inS,
      f           => fS,
      q           => qS,
      svfType     => svfType,
      loadFilter  => loadFilterS,
      saveDelay   => halvedDelay,
      rst         => rst,
      clk         => svfClk
   );

   -- Generate the pulse that saves values to registers
   -- when a filter run has finished
   process(clk) is
   begin
      if rising_edge(clk) then
         lastLoad <= loadFilterS;
         saveDelayS <= lastLoad and not loadFilterS;
      end if;
   end process;


   LCDareai :  LCDArea port map(
      rst               => rst,
      clk               => clk,
      XCountHighBits    => XCountMSBBits,
      YCountHighBits    => YCountMSBBits,
      TileAdress        => tileAdressfromCPU,

      IOPi              => IOP,
      IONi              => IOn,  
      TP_BUSYi          => TP_BUSY,
      TP_DOUTi          => TP_DOUT,
      TP_PENIRQi        => TP_PENIRQ
   );

   -- A process used to display the recieved MIDI messages
   -- on the 7-segment display. 
   -- Also generates the svfClk since it runs at half speed (50MHz).
   process(clk) begin
      if rising_edge(clk) then 
         counter_r <= counter_r + 1;
         svfClk <= not svfClk;
         case counter_r(17 downto 16) is
            when "00" => 
                  an <= "0111";
                  seg <= m1;
            when "01" => 
                  an <= "1011";
                  seg <= mreg1S;
            when "10" => 
                  an <= "1101";
                  seg <= mreg2S;
            when others => 
                  an <= "1110";
                  seg <= mreg3S;
         end case;
      end if;
   end process;
   
   sdin <= sdouts;

   --Drive with something, unused currently
   TP_DIN <= '0';
   TP_CS <= '1';
   TP_DCLK <= '0';

end Behavioral;
