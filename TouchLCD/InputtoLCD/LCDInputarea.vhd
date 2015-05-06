library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity LCDInputarea is
   port(
      rst               :  in std_logic;
      clk               :  in std_logic;
      F                 :  out std_logic;
      LCD_DE            :  out std_logic;
      LCD_DATA          :  out std_logic_vector(RGB_BITS - 1 downto 0);
      XCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      YCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      TileAdress        :  in std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0)

   );
end LCDInputarea;

architecture Behaviorial of LCDInputarea is

   component updatefreq is
      port(
         rst   : in std_logic;
         clk   : in std_logic;
         F     : out std_logic --desired frequency 10 MHz
      );
   end component;
   
   component X_COUNTER is
      port(
         rst         : in std_logic;
         clk         : in std_logic;
         count       : out std_logic_vector(XCOUNT_BITS - 1 downto 0);
         firstCycle  : out std_logic_vector(5 downto 0)
      );
   end component;
   
   component Y_COUNTER is
      port(
         rst   : in std_logic;
         clk   : in std_logic;
         xcount: in std_logic_vector(XCOUNT_BITS - 1 downto 0);
         count : out std_logic_vector(YCOUNT_BITS - 1 downto 0)
      );
   end component;

   component TileMemory is
      port(
         tileAddr : in std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);
         YCoord   : in std_logic_vector(LOWER_BITS - 1 downto 0);
         XCoord   : in std_logic_vector(LOWER_BITS - 1 downto 0);
         output   : out std_logic_vector(RGB_BITS - 1 downto 0)
      );
   end component;
   
   component GK4 is
      port(
         XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
         YCounter      : in std_logic_vector(YCOUNT_BITS - 1 downto 0);
         toLCD_DE      : out std_logic;
         firstXdelay   : in std_logic_vector(5 downto 0)
      );
   end component;
   
   component GK3 is
      port(
         XCounter      : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
         fromTileMem   : in std_logic_vector(RGB_BITS - 1 downto 0);
         toLCD         : out std_logic_vector(RGB_BITS - 1 downto 0)
      );
   end component;
   
   component GK2 is
      port(
         YCounter       : in std_logic_vector(YCOUNT_BITS - 1 downto 0);
         toTileMap      : out std_logic_vector(HIGHER_BITS - 1 downto 0);
         toTileMem      : out std_logic_vector(LOWER_BITS - 1 downto 0)
      );
   end component;
   
   component GK1 is
      port(
         XCounter       : in std_logic_vector(XCOUNT_BITS - 1 downto 0);
         toTileMap      : out std_logic_vector(HIGHER_BITS - 1 downto 0);
         toTileMem      : out std_logic_vector(LOWER_BITS - 1 downto 0)
      );
   end component;
   
 
   --interna signaler
   signal newclkF             : std_logic;
   signal xcount              : std_logic_vector(XCOUNT_BITS - 1 downto 0);
   signal ycount              : std_logic_vector(YCOUNT_BITS - 1 downto 0);
   
   signal xlsb                : std_logic_vector(LOWER_BITS - 1 downto 0);
   signal ylsb                : std_logic_vector(LOWER_BITS - 1 downto 0);

   signal tilememtoGK3        : std_logic_vector(RGB_BITS - 1 downto 0);
   
   signal xmsb                : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal ymsb                : std_logic_vector(HIGHER_BITS - 1 downto 0);

   signal firstTimei          : std_logic_vector(5 downto 0);
begin
   UF : updatefreq port map (
      rst      => rst,
      clk      => clk,
      F        => newclkF
   );
   
   x_cntr : X_COUNTER port map(
      rst      => rst,
      clk      => newclkF,
      count    => xcount,
      firstCycle => firstTimei
   );

   y_cntr : Y_COUNTER port map(
      rst      => rst,
      clk      => newclkF,
      xcount   => xcount,
      count    => ycount
   );

   TileM : TileMemory port map(
      tileAddr => TileAdress, 
      YCoord   => ylsb,
      XCoord   => xlsb,
      output   => tilememtoGK3
   );
   
   gk4i : GK4 port map (
      XCounter    =>  xcount,
      YCounter    =>  ycount,
      toLCD_DE    =>  LCD_DE,
      firstXdelay => firstTimei
   );
   
   gk3i : GK3 port map (
      XCounter      => xcount,
      fromTileMem   => tilememtoGK3,
      toLCD         => LCD_DATA
   );

   gk2i : GK2 port map (
      YCounter       => ycount,
      toTileMap      => YCountHighBits,
      toTileMem      => ylsb
   );
   
   
   gk1i : GK1 port map (
      XCounter       => xcount,
      toTileMap      => XCountHighBits,
      toTileMem      => xlsb
   );
   
   F <= newclkF;
   
end Behaviorial;
