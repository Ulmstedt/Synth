-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.Constants.all;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS 

  -- Component Declaration
Component ALU is
   port(
      leftIn  : in std_logic_vector(REG_WIDTH-1 downto 0);
      rightIn : in std_logic_vector(REG_WIDTH-1 downto 0);
      ALUOut  : out std_logic_vector(REG_WIDTH-1 downto 0);
      ALUInstr: in std_logic_vector(4 downto 0);
      
      clk     : in std_logic;
      
      sRZ     : out std_logic;
      sRN     : out std_logic;
      sRO     : out std_logic;
      sRC     : out std_logic
   );
end Component;
	
   SIGNAL clk 		   : std_logic	:= '0';
   SIGNAL rst 		   : std_logic	:= '0';
   signal leftIn    : std_logic_vector(REG_WIDTH-1 downto 0) := "1111" & "1111" & "1111" & "1111" ;
   signal rightIn   : std_logic_vector(REG_WIDTH-1 downto 0) := "1111" & "1111" & "0000" & "1010";
   signal ALUOut    : std_logic_vector(REG_WIDTH-1 downto 0);
   signal ALUInstr  : std_logic_vector(4 downto 0) := "01000";
      
   signal sRZ       : std_logic := '0';
   signal sRN       : std_logic := '0';
   signal sRO       : std_logic := '0';
   signal sRC       : std_logic := '0';
   signal tb_running : boolean 	:= true;

BEGIN

  -- Component Instantiation
   alut : ALU port map(
      leftIn  => leftIn,
      rightIn => rightIn,
      ALUOut  => ALUOut,
      ALUInstr=> ALUInstr,
      
      clk      => clk,
      
      sRZ     => sRZ,
      sRN     => sRN,
      sRO     => sRO,
      sRC     => sRC
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
      if i = 1 then
         --do nothing
         ALUInstr <= "00000";
      elsif i = 2 then
         --add uns
         ALUInstr <= "00001";
      elsif i = 3 then
         --sub uns
         ALUInstr <= "00011";
      elsif i = 4 then
         --add signed
         ALUInstr <= "00010";
      elsif i = 5 then
         --sub signed
         ALUInstr <= "00100";
      elsif i = 6 then
         --fiexed mul signed
         leftIn <= "01111111" & "11111111";
         ALUInstr <= "00101";
      elsif i = 7 then
         --bitshift right
         leftIn <= "00000000" & "00000010";
         ALUInstr <= "00110";
      elsif i = 8 then
         --bitshift left
         ALUInstr <= "00111";
      elsif i = 9 then
         --AND
         ALUInstr <= "01000";
      elsif i = 10 then
         --OR
         ALUInstr <= "01001";
      elsif i = 11 then
         --XOR
         ALUInstr <= "01010";
      elsif i = 12 then
         --NOT
         ALUInstr <= "01011";
      elsif i = 13 then
         --CMP
         ALUInstr <= "01100";
      elsif i = 14 then
         --BITTEST
         ALUInstr <= "01111";
      end if;
    end loop;  -- i
	
    tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;