-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.sout_constants.all;

ENTITY sout_tb IS
END sout_tb;

ARCHITECTURE behavior OF sout_tb IS 

   -- Component Declaration
component SoutArea is
   port(
      clk               : in std_logic;
      rst               : in std_logic;
      --sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic; -- Master clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic -- Serial data output
   );
end component;
	
   signal clk 		         : std_logic	:= '0';
   signal rst 		         : std_logic	:= '0';
   signal sampleBuffer     : std_logic_vector(SAMPLE_SIZE - 1 downto 0);
   signal sclk             : std_logic; -- Serial clock
   signal mclk             : std_logic; -- Master clock
   signal lrck             : std_logic; -- Left/Right clock
   signal sdout            : std_logic; -- Serial data output
   signal tb_running       : boolean 	:= true;

BEGIN

  -- Component Instantiation
   sout : SoutArea port map(
      clk => clk, 
      rst => rst,
      --sampleBuffer => sampleBuffer,
      sclk => sclk,
      mclk => mclk,
      lrck => lrck,
      sdout => sdout
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
      variable n : integer := 0;
   begin
      -- Aktivera reset ett litet tag.
      rst <= '1';
      wait for 500 ns;

      wait until rising_edge(clk);        -- se till att reset släpps synkront
                                        -- med klockan
      rst <= '0';
      report "Reset released" severity note;
	
	
	   --sampleBuffer <= "1000100010001001";
      --wait for 13 us;
      --sampleBuffer <= "0111011101110111";

      for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
         wait until rising_edge(clk);

      end loop;  -- i
	
      tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
      wait;
   end process;
      
END;
