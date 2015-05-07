library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Touch is
   port(
      PENIRQ      : in std_logic;
      BUSY        : in std_logic;
      DOUT        : in std_logic;
      DIN         : out std_logic;
      DCLK        : out std_logic;
      CS          : out std_logic;
      coordOut    : out std_logic_vector(8 downto 0);
      writeX      : out std_logic;
      writeY      : out std_logic;
      coordReady  : out std_logic;
      clk         : in std_logic;
      rst         : in std_logic
   );
end Touch;

architecture Behavioural of Touch is

   component TouchInterface is
      port(
         PENIRQ   : in std_logic;
         BUSY     : in std_logic;
         DOUT     : in std_logic;
         DIN      : out std_logic;
         DCLK     : out std_logic;
         CS       : out std_logic;
         voltage  : out std_logic_vector(11 downto 0);
         savePulse: out std_logic;
         Xaxis    : out std_logic;
         clk      : in std_logic;
         rst      : in std_logic
      );
   end component;

   component CoordConverter is
      port(
         voltage  : in std_logic_vector(11 downto 0);
         coord    : out std_logic_vector(8 downto 0);
         Xaxis    : in std_logic
      );
   end component;

   signal voltageS   : std_logic_vector(11 downto 0);
   signal savePulseS : std_logic;
   signal XaxisS     : std_logic;
   
begin 

   touch : TouchInterface port map(
      PENIRQ      => PENIRQ,
      BUSY        => BUSY,
      DOUT        => DOUT,
      DIN         => DIN,
      DCLK        => DCLK,
      CS          => CS,
      voltage     => voltageS,
      savePulse   => savePulseS,
      Xaxis       => XaxisS,
      clk         => clk,
      rst         => rst
   );

   converter : CoordConverter port map(
      voltage     => voltageS,
      coord       => coordOut,
      Xaxis       => XaxisS
   );

   writeX <= XaxisS and savePulseS;
   writeY <= (not XaxisS) and savePulseS;
   coordReady <= (not XaxisS) and savePulseS;
 
end Behavioural;
