-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.constants.all;

ENTITY cpu_tb IS
END cpu_tb;

ARCHITECTURE behavior OF cpu_tb IS 

  -- Component Declaration
component CPUArea is
   port(
      audioOut : out std_logic_vector(REG_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic;

      tileXcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileYcnt    : in std_logic_vector(HIGHER_BITS - 1 downto 0);
      tileMapOut  : out std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0)
   );
end component;
	
  signal clk 		   : std_logic	:= '0';
  signal rst 		   : std_logic	:= '0';
  signal audioOut    : std_logic_vector(REG_WIDTH - 1 downto 0);
  signal tb_running	: boolean 	:= true;

  signal tileX       : std_logic_vector(HIGHER_BITS -1 downto 0) := "000000";
  signal tileY       : std_logic_vector(HIGHER_BITS -1 downto 0) := "000000";
  signal tileMap     : std_logic_vector(TILE_MEM_ADRESS_BITS - 1 downto 0) := "00000";

BEGIN

  -- Component Instantiation
   cpu : CPUArea port map(
      audioOut => audioOut,
      rst      => rst,
      clk      => clk,
      tileXcnt    => tileX,
      tileYcnt    => tileY,
      tileMapOut  => tileMap
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
    end loop;  -- i
	
    tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;
