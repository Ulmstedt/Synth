-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.constants.all;

ENTITY bus_tb IS
END bus_tb;

ARCHITECTURE behavior OF bus_tb IS 

  -- Component Declaration
component PMemArea is
   port(
      IR1out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      IR2out   : out std_logic_vector(PMEM_WIDTH - 1 downto 0);
      regSel   : out std_logic_vector(REG_BITS - 1 downto 0);
      regIn    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      rst      : in std_logic;
      clk      : in std_logic
   );
end component;
	
  SIGNAL clk 		   : std_logic	:= '0';
  SIGNAL rst 		   : std_logic	:= '0';
  signal ir1out      : std_logic_vector(PMEM_WIDTH - 1 downto 0);
  signal ir2out      : std_logic_vector(PMEM_WIDTH - 1 downto 0);
  signal regSel      : std_logic_vector(REG_BITS - 1 downto 0);
  signal regIn       : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal tb_running	: boolean 	:= true;

BEGIN

  -- Component Instantiation
   mem : PMemArea port map(
      IR1out   => ir1out,
      IR2out   => ir2out,
      regSel   => regSel,
      regIn    => regIn,
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