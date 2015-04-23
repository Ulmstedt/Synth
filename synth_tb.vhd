-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.constants.all;

ENTITY synth_tb IS
END synth_tb;

ARCHITECTURE behavior OF synth_tb IS 

  -- Component Declaration
component Synth is
   port(
      rst         : in std_logic;
      clk         : in std_logic
   );
end component;
	
  signal clk 		   : std_logic	:= '0';
  signal rst 		   : std_logic	:= '0';
  signal tb_running	: boolean 	:= true;

BEGIN

  -- Component Instantiation
   synt : Synth port map(
      rst      => rst,
      clk      => clk
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
