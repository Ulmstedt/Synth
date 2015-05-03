-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.FilterConstants.all;

ENTITY svf_tb IS
END svf_tb;

ARCHITECTURE behavior OF svf_tb IS 

  -- Component Declaration
component SVF is
   port(
      sample      : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay1in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay2in    : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      output      : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay1out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      delay2out   : out std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      f           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      q           : in std_logic_vector(AUDIO_WIDTH - 1 downto 0);
      loadFilter  : in std_logic;
      saveDelay   : out std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end component;
	
  signal clk 		   : std_logic	:= '0';
  signal rst 		   : std_logic	:= '0';
  signal audioOut    : std_logic_vector(AUDIO_WIDTH - 1 downto 0) := "0110110100101010";
  signal tb_running	: boolean 	:= true;

   signal delay1inS  : std_logic_vector(AUDIO_WIDTH - 1 downto 0) := "0010111000110011";
   signal delay2inS  : std_logic_vector(AUDIO_WIDTH - 1 downto 0) := "1010100100110001";
   signal fS         : std_logic_vector(AUDIO_WIDTH - 1 downto 0) := "0000000010000000";
   signal qS         : std_logic_vector(AUDIO_WIDTH - 1 downto 0) := "0000000000100000";
   signal loadFilterS: std_logic := '0';

BEGIN

  -- Component Instantiation
   SVFc : SVF port map(
      sample      => audioOut,
      delay1in    => delay1inS,
      delay2in    => delay2inS,
      f           => fS,
      q           => qS,
      loadFilter  => loadFilterS,
      rst         => rst,
      clk         => clk
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
      if i = 100 or i = 150 then
         loadFilterS <= '1';
      else
         loadFilterS <= '0';
      end if;
      wait until rising_edge(clk);
    end loop;  -- i
	
    tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;
