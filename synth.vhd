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
         sdout             : out std_logic -- Serial data output
      );
   end component;

   signal audio      : std_logic_vector(SAMPLE_SIZE - 1 downto 0);
   signal dem        : std_logic := '1'; 

begin

   cpu : CPUArea port map(
      audioOut    => audio,
      rst         => rst,
      clk         => clk
   );

   sout : SoutArea port map(
      clk            => clk,
      rst            => rst,
      sampleBuffer   => audio,
      mclk           => mclk,
      lrck           => lrck,
      sdout          => sdin
   );
   
   sclk <= dem;

end Behavioral;