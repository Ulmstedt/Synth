-- TestBench Template 

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY touch_tb IS
END touch_tb;

ARCHITECTURE behavior OF touch_tb IS 

   -- Component Declaration
component TouchInterface is
   port(
      PENIRQ   : in std_logic;
      BUSY     : in std_logic;
      DOUT     : in std_logic;
      DIN      : out std_logic;
      DCLK     : out std_logic;
      CS       : out std_logic;
      clk      : in std_logic;
      rst      : in std_logic
   );
end component;
	
   SIGNAL clk 		      : std_logic	:= '0';
   SIGNAL rst 		      : std_logic	:= '0';
   signal tb_running    : boolean := true;
   signal PENIRQS       : std_logic := '1';
   signal BUSYS         : std_logic := '0';
   signal DOUTS         : std_logic := '1';
   


BEGIN

   touch : TouchInterface port map(
      PENIRQ   => PENIRQS,
      BUSY     => BUSYS,
      DOUT     => DOUTS,
      clk      => clk,
      rst      => rst
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

         if i = 100 then
            PENIRQS <= '0';
         elsif i = 3000 then
            BUSYS <= '1';
         elsif i = 4000 then
            BUSYS <= '0';         
         end if;
         

      end loop;  -- i
	
      tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
      wait;
   end process;
      
END;
