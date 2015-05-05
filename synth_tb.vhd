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
      mclk        : out std_logic;
      lrck        : out std_logic;
      sclk        : out std_logic;
      sdin        : out std_logic;
      
      --LCDtft stuff
      IOP         : out std_logic_vector(20 downto 1);
      ION         : out std_logic_vector(20 downto 1);
      TP_BUSY     : in std_logic;
      TP_DOUT     : in std_logic;
      TP_PENIRQ   : in std_logic;

      uart        : in std_logic;
      rst         : in std_logic;
      clk         : in std_logic
   );
end component;
	
   signal clk 	       : std_logic	:= '0';
   signal rst 	       : std_logic	:= '0';
   signal tb_running	 : boolean 	:= true;

   signal mclkS       : std_logic;
   signal lrckS       : std_logic;
   signal sclkS       : std_logic;
   signal sdinS       : std_logic;
   signal uartS       : std_logic;
  
   signal midi_msg      : std_logic_vector(0 to 34) := "11111" & B"0_1001_0000_1" & B"0_1011_0111_1" & B"0_1010_0011_1";

   constant UART_CLK_PERIOD  		   : natural := 3200;

BEGIN

  -- Component Instantiation
   synt : Synth port map(
      mclk        => mclkS,
      lrck        => lrckS,
      sclk        => sclkS,
      sdin        => sdinS,

      TP_BUSY     => '1',
      TP_DOUT     => '1',
      TP_PENIRQ   => '1',

      uart        => uartS,
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
         if i mod UART_CLK_PERIOD = 0 and n < 35 then
            uartS <= midi_msg(n);
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
