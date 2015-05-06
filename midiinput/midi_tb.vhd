-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.midi_constants.all;

ENTITY midi_tb IS
END midi_tb;

ARCHITECTURE behavior OF midi_tb IS 

   -- Component Declaration
component MidiArea is
   port(
      clk      : in std_logic;
      rst      : in std_logic;
      uart     : in std_logic;
      mreg1    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      readRdy  : out std_logic
   );
end component;
	
   SIGNAL clk 		      : std_logic	:= '0';
   SIGNAL rst 		      : std_logic	:= '0';
   signal uart          : std_logic := '1';
   signal mreg1         : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg2         : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal mreg3         : std_logic_vector(MIDI_WIDTH - 1 downto 0);
   signal readRdy       : std_logic;
   signal tb_running    : boolean 	:= true;
   signal midi_msg      : std_logic_vector(0 to 34) := "11111" & B"0_0000_1001_1" & B"0_1110_1101_1" & B"0_1100_0101_1";


BEGIN

  -- Component Instantiation
   midi : MidiArea port map(
      clk => clk,
      rst => rst,
      uart => uart,
      mreg1 => mreg1,
      mreg2 => mreg2,
      mreg3 => mreg3,
      readRdy => readRdy
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
	
	
	

      for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
         wait until rising_edge(clk);
         -- Send midi message
         if i mod UART_CLK_PERIOD = 0 and n < 34 then
            uart <= midi_msg(n);
            -- report "Midi_msg(n): " & std_logic'image(midi_msg(n));
            --report "(n): " & integer'image(n);
            n := n+1;
         end if;
      end loop;  -- i
	
      tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
      wait;
   end process;
      
END;
