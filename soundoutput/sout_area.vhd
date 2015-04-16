library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoutArea is
   port(
      clk               : in std_logic;
      rst               : in std_logic;
      --sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic; -- Master clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic -- Serial data output
   );
end SoutArea;

architecture Behavioral of SoutArea is

component SoundOutput is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      sclk              : in std_logic; -- Serial clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic -- Serial data output
   );
end component;

component SoutClkgen is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic -- Master clock
   );
end component;

component SoutWaveGen is
   port(
      clk               : in std_logic; -- Clock
      soundwave         : out std_logic_vector(SAMPLE_SIZE-1 downto 0) -- sound out
   );
end component;

signal sclkS            : std_logic;
signal sampleBuffer     : std_logic_vector(SAMPLE_SIZE - 1 downto 0);


begin

   sound_output  : SoundOutput port map(
      clk => clk, 
      rst => rst,
      sampleBuffer => sampleBuffer,
      sclk => sclkS,
      lrck => lrck,
      sdout => sdout
   );

   sound_clkgen  : SoutClkgen port map(
      clk => clk, 
      rst => rst,
      sclk => sclkS,
      mclk => mclk
   );

   sound_wave : SoutWaveGen port map(
      clk => clk,
      soundwave => sampleBuffer
   );
   
sclk <= sclkS;
end Behavioral;
