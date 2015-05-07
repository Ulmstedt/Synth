-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use work.constants.all;

ENTITY LCD_tb IS
END LCD_tb;

ARCHITECTURE behavior OF LCD_tb IS 

  -- Component Declaration
component LCDarea is
   port(
      rst               : in std_logic;
      clk               : in std_logic;
      
      XCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      YCountHighBits    :  out std_logic_vector(HIGHER_BITS - 1 downto 0);
      TileAdress        :  in std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0);

      IOPi              : out std_logic_vector(20 downto 1);
      IONi              : out std_logic_vector(20 downto 1);
      TP_BUSYi          : in std_logic;
      TP_DOUTi          : in std_logic;
      TP_PENIRQi        : in std_logic 
   );
end component;
	
  signal clk 		   : std_logic	:= '0';
  signal rst 		   : std_logic	:= '0';
  signal tb_running	: boolean 	:= true;
   
  
  signal tileXMSBBits: std_logic_vector(HIGHER_BITS -1 downto 0) := "000000";
  signal tileYMSBBits: std_logic_vector(HIGHER_BITS -1 downto 0) := "000000";
  signal tileMap     : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0) := "00000";
  signal IOP              : std_logic_vector(20 downto 1) := "00000000000000000000";
  signal ION              : std_logic_vector(20 downto 1) := "00000000000000000000";
  
  signal BUSY        : std_logic;
  signal DOUT        : std_logic;
  signal PENIRQ      : std_logic;

BEGIN

  -- Component Instantiation
   lcdinternal : LCDarea port map(
      rst               => rst,
      clk               => clk,
      XCountHighBits    => tileXMSBBits,
      YCountHighBits    => tileYMSBBits,
      TileAdress        => tileMap,
      IOPi              => IOP,
      IONi              => ION,
      TP_BUSYi          => BUSY,
      TP_DOUTi          => DOUT,
      TP_PENIRQi        => PENIRQ   
   );


  clk_gen : process
  begin
    while tb_running loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process;

  

  stimuli_generator : process
    variable i : integer;
  begin
    -- Aktivera reset ett litet tag.
    rst <= '1';
    wait for 500 ns;

    wait until rising_edge(clk);        -- se till att reset släpps synkront
                                        -- med klockan
    rst <= '0';
    report "Reset released" severity note;
	
	

    for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
      wait until rising_edge(clk);
      if( i = 5 ) then
         tileMap <= "00001";
      elsif ( i = 1000000) then
         tileMap <= "00000";
      end if;
    end loop;  -- i
	
    tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;
