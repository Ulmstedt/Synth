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
      --IOP         : out std_logic_vector(20 downto 1);
      --ION         : out std_logic_vector(20 downto 1);
      --TP_BUSY     : in std_logic;
      --TP_DOUT     : in std_logic;
      --TP_PENIRQ   : in std_logic;

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

   constant midi_msg_width : natural := 120;


   signal midi_msg      : std_logic_vector(0 to midi_msg_width - 1) := B"0_0111_1111_1" & B"0_0111_1111_1" & B"0_0111_1111_1" &
                                                                   B"0_0000_1001_1" & B"0_1111_1100_1" & B"0_1100_0100_1" &
                                                                   B"0_0111_1111_1" & B"0_0111_1111_1" & B"0_0111_1111_1" &
                                                                   B"0_0000_1001_1" & B"0_1111_1100_1" & B"0_0000_0000_1";

   constant UART_CLK_PERIOD  		   : natural := 3200;

   signal IOPinternal   : std_logic_vector(20 downto 1);
   signal IONinternal   : std_logic_vector(20 downto 1);

BEGIN

  -- Component Instantiation
   synt : Synth port map(
      mclk        => mclkS,
      lrck        => lrckS,
      sclk        => sclkS,
      sdin        => sdinS,
      
      --IOP         => IOPinternal,
      --ION         => IONinternal,
      --TP_BUSY     => '1',
      --TP_DOUT     => '1',
      --TP_PENIRQ   => '1',

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
         if i mod 3200 = 0 then
            if n < midi_msg_width - 1 then
               uartS <= midi_msg(n);
            else
               uartS <= '1';
            end if;
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
