library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

-- This component is the entire sound output handler

entity SoutArea is
   port(
      clk               : in std_logic;
      rst               : in std_logic;
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      mclk              : out std_logic; -- Master clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic; -- Serial data output
      sclk              : out std_logic
   );
end SoutArea;

architecture Behavioral of SoutArea is

component SoundOutput is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      sendBit           : in std_logic; -- Serial clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic -- Serial data output
   );
end component;

component SoutClkgen is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sendBit           : out std_logic;
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic -- Master clock
   );
end component;

signal sendBitS            : std_logic;


begin

   sound_output  : SoundOutput port map(
      clk => clk, 
      rst => rst,
      sampleBuffer => sampleBuffer,
      sendBit => sendBitS,
      lrck => lrck,
      sdout => sdout
   );

   sound_clkgen  : SoutClkgen port map(
      clk => clk, 
      rst => rst,
      sendBit => sendBitS,
      sclk => sclk,
      mclk => mclk
   );

end Behavioral;
