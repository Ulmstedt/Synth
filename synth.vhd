library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity Synth is
   port(
      rst         : in std_logic;
      clk         : in std_logic
   );
end Synth;

architecture Behavioral of Synth is

   constant SAMPLE_SIZE : natural := 16;

   component CPUArea is
      port(
         audioOut    : out std_logic_vector(SAMPLE_SIZE - 1 downto 0);
         rst         : in std_logic;
         clk         : in std_logic;

         tileXcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
         tileYcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
         tileMapOut  : out std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0)
      );
   end component;

   component SoutArea is
      port(
         clk               : in std_logic;
         rst               : in std_logic;
         sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
         mclk              : out std_logic; -- Master clock
         lrck              : out std_logic; -- Left/Right clock
         sdout             : out std_logic -- Serial data output
      );
   end component;
   
   component LCDInputarea is
      port(
         rst               :  in std_logic;
         clk               :  in std_logic;
         F                 :  out std_logic;
         LCD_DE            :  out std_logic;
         LCD_DATA          :  out std_logic_vector(RGB_BITS - 1 downto 0);
         XCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
         YCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
         TileAdress        :  in std_logic(TILE_MEM_ADRESS_BITS - 1 downto 0)
      );
   end component;

   signal audio      : std_logic_vector(SAMPLE_SIZE - 1 downto 0);
   signal mclks      : std_logic;
   signal lrcks       : std_logic;
   signal sdouts      : std_logic;

   signal F_LCDclk   : std_logic;
   signal LCDDEin    : std_logic;
   signal LCDDATAin  : std_logic_vector(RGB_BITS - 1 downto 0);

   signal XCountMSBBits     : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal YCountMSBBits     : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal tileAdressfromCPU : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);

begin
   -- fix someth and add LCDInputarea
   cpu : CPUArea port map(
      audioOut    => audio,
      rst         => rst,
      clk         => clk,
      tileXcnt    => XCountMSBBits,
      tileYcnt    => YCountMSBBits,
      tileMapOut  => tileAdressfromCPU
   );

   sout : SoutArea port map(
      clk            => clk,
      rst            => rst,
      sampleBuffer   => audio,
      mclk           => mclkS,
      lrck           => lrcks,
      sdout          => sdouts
   );

   LCDIn :  LCDInputarea port map(
      rst               => rst,
      clk               => clk,
      F                 => F_LCDclk,
      LCD_DE            => LCDDEin,
      LCD_DATA          => LCDDATAin,
      XCountHighBits    => XCountMSBBits,
      YCountHighBits    => YCountMSBBits,
      TileAdress        => tileAdressfromCPU

   );

end Behavioral;
