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

   component backlightpwmsignal is
      port(
         rst   : in std_logic;
         clk   : in std_logic;
         F     : out std_logic; --desired frequency 50 kHz
         clkStop  : in std_logic  
      );
   end component;  
   

   signal F_LCDclk         : std_logic; --10MHz
   signal TFT_DE           : std_logic;
   signal LCDDATAin        : std_logic_vector(RGB_BITS - 1 downto 0);

   signal XCountMSBBits    : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal YCountMSBBits    : std_logic_vector(HIGHER_BITS - 1 downto 0);
   signal tileAdressfromCPU   : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);
   
   signal complStartUp     : std_logic =: '0';
   
   signal TFT_EN           : std_logic =: '0';
   signal LCD_DE_from_input: std_logic =: '0';
   signal TFT_DISPLAY           : std_logic =: '0';


   constant CLOCKFREQ : natural := 10; --MHZ
	constant TPOWERUP : natural := 1; --ms
	constant TPOWERDOWN : natural := 1; --ms
	constant TLEDWARMUP : natural := 200; --ms
	constant TLEDCOOLDOWN : natural := 200; --ms
	constant TLEDWARMUP_CYCLES : natural := natural(CLOCKFREQ*TLEDWARMUP*1000);
	constant TLEDCOOLDOWN_CYCLES : natural := natural(CLOCKFREQ*TLEDCOOLDOWN*1000);
	constant TPOWERUP_CYCLES : natural := natural(CLOCKFREQ*TPOWERUP*1000);
	constant TPOWERDOWN_CYCLES : natural := natural(CLOCKFREQ*TPOWERDOWN*1000);	

	signal waitCnt : natural range 0 to TLEDCOOLDOWN_CYCLES := 0;
	signal waitCntEn : std_logic;
   
   type state_type is (stOff, stPowerUp, stLEDWarmup, stLEDCooldown, stPowerDown, stOn); 
   signal state, nstate : state_type := stPowerDown;
   
   signal LED_EN, int_De, clkStop : std_logic := '0';

   signal backLightFreq : std_logic := '0'; 

   signal RED              : std_logic_vector(7 downto 0) := "00000000";
   signal GREEN            : std_logic_vector(7 downto 0) := "00000000";
   signal BLUE             : std_logic_vector(7 downto 0) := "00000000";

begin

   lcdin : LCDInputarea port map(   
         rst               => rst,
         clk               => clk,
         F                 => F_LCDclk,
         LCD_DE            => LCD_DE_from_input,
         LCD_DATA          => LCDDATAin,
         XCountHighBits    => XCountHighBits,
         YCountHighBits    => YCountHighBits,
         TileAdress        => TileAdress,
         clkStop           => clkStop
         );

   pwmsiggenerator : backlightpwmsignal port map(
         rst   => rst,
         clk   => clk,
         F     => backLightFreq, --desired frequency 50 kHz
         clkStop  => clkStop
         );

----------------------------------------------------------------------------------
-- LCD Power Sequence
----------------------------------------------------------------------------------	
--LCD & backlight power 
TFT_EN <= 	'0' when state = stOff or state = stPowerDown else
				'1';
--Display On/Off signal
TFT_DISPLAY <= 	'0' when state = stOff or state = stPowerUp or state = stPowerDown else
				'1';
--Interface signals
TFT_DE <= 		'0' when state = stOff or state = stPowerUp or state = stPowerDown else --TFT_DE
				LCD_DE_from_input;
RED <= 		(others => '0') when state = stOff or state = stPowerUp or state = stPowerDown else
				LCD_DATA(RGB_BITS - 1 downto RGB_BITS - 8);
GREEN <= 		(others => '0') when state = stOff or state = stPowerUp or state = stPowerDown else
				LCD_DATA(RGB_BITS - 8 - 1 downto RGB_BITS - 2*8);
BLUE <= 		(others => '0') when state = stOff or state = stPowerUp or state = stPowerDown else
				LCD_DATA(RGB_BITS - 2*8 -1 downto 0);
--Clock signal
clkStop <= 	'1' when state = stOff or state = stPowerUp or state = stPowerDown else
				'0';
--Backlight adjust/enable
LED_EN <= 	backLightFreq when state = stOn else
				'0';
--Wait States
waitCntEn <= 	'1' when (state = stPowerUp or state = stLEDWarmup or state = stLEDCooldown or state = stPowerDown) and 
								(state = nstate) else
					'0';
					
   SYNC_PROC: process (F_LCDclk)
   begin
      if (F_LCDclk'event and F_LCDclk = '1') then
         state <= nstate;
      end if;
   end process;				

   NEXT_STATE_DECODE: process (state, waitCnt)
   begin
      nstate <= state;
      case (state) is
         when stOff =>
            if (true) then -- control when to startup if we want here
               nstate <= stPowerUp;
            end if;
			when stPowerUp => --turn power on first
				if (waitCnt = TPOWERUP_CYCLES) then
               nstate <= stLEDWarmup;
            end if;
         when stLEDWarmup => --turn on interface signals
            if (waitCnt = TLEDWARMUP_CYCLES) then
               nstate <= stOn;
            end if;
         when stOn => --turn on backlight too
				if (rst = '1') then
					nstate <= stLEDCooldown;
				end if;
			when stLEDCooldown =>
            if (waitCnt = TLEDCOOLDOWN_CYCLES) then
               nstate <= stPowerDown;
            end if;
			when stPowerDown => --turn off power last
				if (waitCnt = TPOWERDOWN_CYCLES) then
					nstate <= stOff;
				end if;
      end case;      
   end process;
----------------------------------------------------------------------------------
-- Wait Counter
----------------------------------------------------------------------------------	
	process(F_LCDclk)
	begin
		if Rising_Edge(F_LCDclk) then
			if waitCntEn = '0' then
				waitCnt <= 0;
			else
				waitCnt <= waitCnt + 1;
			end if;
		end if;
	end process;

begin



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

--TFT Signals and backlight control
IOPi(19) <= TFT_EN;
IOPi(18) <= TFT_DISP;
IONi(18) <= TFT_DE;
IONi(19) <= LED_EN;

--TFT_CLK
IOP1(11) <= F_LCDclk;

end Behavioral;

