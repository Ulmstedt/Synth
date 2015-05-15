library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.TouchConstants.all;

entity Touch is
   port(
      PENIRQ      : in std_logic;
      BUSY        : in std_logic;
      DOUT        : in std_logic;
      DIN         : out std_logic;
      DCLK        : out std_logic;
      CS          : out std_logic;
      coordOut    : out std_logic_vector(COORD_WIDTH - 1 downto 0);
      writeX      : out std_logic;
      writeY      : out std_logic;
      coordReady  : out std_logic;

      tmp         : out std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);

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
         voltage  : out std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
         savePulse: out std_logic;
         Xaxis    : out std_logic;
         clk      : in std_logic;
         rst      : in std_logic
      );
   end component;

   component Avg is
      port(
         voltage     : in std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
         result      : out std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
         savePulse   : in std_logic;
         donePulse   : out std_logic;
         clk         : in std_logic;
         rst         : in std_logic
      );
   end component;

   component CoordConverter is
      port(
         voltage  : in std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
         coord    : out std_logic_vector(COORD_WIDTH - 1 downto 0);
         Xaxis    : in std_logic
      );
   end component;

   signal voltageS   : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
   signal savePulseS : std_logic;
   signal XaxisS     : std_logic;

   signal rstCounter : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0) := (others => '1');
   signal rstS       : std_logic;

   signal coordOutS  : std_logic_vector(COORD_WIDTH - 1 downto 0);
   signal touched    : std_logic := '0';
   
   signal avgVolt    : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
   signal donePulseS : std_logic;
   
   signal tmpS       : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
begin 

   touch : TouchInterface port map(
      PENIRQ      => PENIRQ,
      BUSY        => BUSY,
      DOUT        => DOUT,
      DIN         => DIN,
      DCLK        => DCLK,
      voltage     => voltageS,
      savePulse   => savePulseS,
      Xaxis       => XaxisS,
      clk         => clk,
      rst         => rstS
   );

   avg_c : Avg port map(
      voltage     => voltageS,
      result      => avgVolt,
      savePulse   => savePulseS,
      donePulse   => donePulseS,
      clk         => clk,
      rst         => rst
   );

   converter : CoordConverter port map(
      voltage     => avgVolt,
      coord       => coordOutS,
      Xaxis       => XaxisS
   );

   writeX <= XaxisS and donePulseS;
   writeY <= (not XaxisS) and donePulseS;
   coordReady <= (not XaxisS) and donePulseS;

   -- The cs counter
   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            rstCounter <= (others => '1');
         elsif to_integer(unsigned(rstCounter)) /= 0 then
            rstCounter <= std_logic_vector(unsigned(rstCounter) - 1);
         end if;
         -- TMPS HSIT
         if donePulseS = '1' then
            tmpS <= avgVolt;
         end if;
      end if;
   end process;

   coordOut <= coordOutS;
   --tempthing
   tmp <= tmpS;

   rstS <= '1' when to_integer(unsigned(rstCounter)) /= 0 else '0';
   CS <= rstS;
end Behavioural;
