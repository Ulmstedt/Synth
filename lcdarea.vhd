library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity LCDArea is
   port(
      rst               : in std_logic;
      clk               : in std_logic;
      
      XCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      YCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      TileAdress        :  in std_logic(TILE_MEM_ADRESS_BITS - 1 downto 0);

      IOPi              : out std_logic_vector(20 downto 1);
      IONi              : out std_logic_vector(20 downto 1)
   );
end LCDArea;

architecture Behavioral of LCDArea is

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
   
   signal RED              : std_logic_vector(7 downto 0) := "00000000";
   signal GREEN            : std_logic_vector(7 downto 0) := "00000000";
   signal BLUE             : std_logic_vector(7 downto 0) := "00000000";

   signal F_LCDclk         : std_logic; --10MHz
   signal LCDDEin          : std_logic;
   signal LCDDATAin        : std_logic_vector(RGB_BITS - 1 downto 0);

   signal XCountMSBBits    : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal YCountMSBBits    : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal tileAdressfromCPU   : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);
   
   signal complStartUp     : std_logic =: '0';
   
   signal TFT_EN           : std_logic;
   
   
begin

   lcdin : LCDInputarea port map(   
         rst               => rst,
         clk               => clk,
         F                 => F_LCDclk,
         LCD_DE            => LCDEin,
         LCD_DATA          => LCDDATAin,
         XCountHighBits    => XCountHighBits,
         YCountHighBits    => YCountHighBits,
         TileAdress        => TileAdress
         );

begin
   process(clk, rst)
   begin
      if(rst = '1') then
         complStartUp <= '0';
      elsif(rising_edge(clk)) then
         if (complStartUp = '0') then
            --TFT-EN should be 1 for a certain time
            --Before DE,CLK
            
         end if;
      end if;
   end process;


--SET correct bits in the vectors

--RED
IONi(17) <= RED(0);
IOPi(17) <= RED(1);
IOPi(16) <= RED(2);
IONi(16) <= RED(3);
IOPi(15) <= RED(4);
IONi(15) <= RED(5);
IOPi(14) <= RED(6);
IONi(14) <= RED(7);

--GREEN
IOPi(13) <= GREEN(0);
IOPi(12) <= GREEN(1);
IONi(13) <= GREEN(2);
IONi(12) <= GREEN(3);
IONi(9) <= GREEN(4);
IOPi(9) <= GREEN(5);
IOPi(8) <= GREEN(6);
IONi(8) <= GREEN(7);

--BLUE
IOPi(7) <= BLUE(0);
IONi(7) <= BLUE(1);
IOPi(6) <= BLUE(2);
IONi(6) <= BLUE(3);
IOPi(5) <= BLUE(4);
IOPi(4) <= BLUE(5);
IONi(5) <= BLUE(6);
IONi(4) <= BLUE(7);

end Behavioral;

