-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.Constants.all;

ENTITY bus_tb IS
END bus_tb;

ARCHITECTURE behavior OF bus_tb IS 

  -- Component Declaration
Component ALU is
   port(
      left_In  : in std_logic_vector(REG_WIDTH-1 downto 0);
      right_In : in std_logic_vector(REG_WIDTH-1 downto 0);
      alu_Out  : out std_logic_vector(REG_WIDTH-1 downto 0);
      ALU_instr  : in std_logic_vector(4 downto 0);
      
      clk      : in std_logic;
      
      sr_Z     : out std_logic;
      sr_N     : out std_logic;
      sr_O     : out std_logic;
      sr_C     : out std_logic
   );
end Component;
	
   SIGNAL clk 		   : std_logic	:= '0';
   SIGNAL rst 		   : std_logic	:= '0';
   signal left_In    : std_logic_vector(REG_WIDTH-1 downto 0) := "1111" & "1111" & "1111" & "1111" ;
   signal right_In   : std_logic_vector(REG_WIDTH-1 downto 0) := "1111" & "1111" & "0000" & "1010";
   signal alu_Out    : std_logic_vector(REG_WIDTH-1 downto 0);
   signal ALU_instr  : std_logic_vector(4 downto 0) := "01000";
      
   signal sr_Z       : std_logic;
   signal sr_N       : std_logic;
   signal sr_O       : std_logic;
   signal sr_C       : std_logic;
   signal tb_running : boolean 	:= true;

BEGIN

  -- Component Instantiation
   alut : ALU port map(
      left_In  => left_In,
      right_In => right_In,
      alu_Out  => alu_Out,
      ALU_instr=> ALU_instr,
      
      clk      => clk,
      
      sr_Z     => sr_Z,
      sr_N     => sr_N,
      sr_O     => sr_O,
      sr_C     => sr_C
   );
   
   
process
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