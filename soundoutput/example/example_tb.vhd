library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity example_tb is

end example_tb;

architecture Behavioral of example_tb is

component i2s_output is
    Port ( clk       : in  STD_LOGIC;
           data_l    : in  STD_LOGIC_VECTOR (15 downto 0);
           data_r    : in  STD_LOGIC_VECTOR (15 downto 0);
           accepted  : out  STD_LOGIC;
           i2s_sd    : out  STD_LOGIC;
           i2s_lrclk : out  STD_LOGIC;
           i2s_sclk  : out  STD_LOGIC;
           i2s_mclk  : out  STD_LOGIC);
end component;

   signal clk 		         : std_logic	:= '0';
   signal rst 		         : std_logic	:= '0';
   signal mclks : STD_LOGIC;
   signal lrclks : STD_LOGIC;
   signal sclks : STD_LOGIC;
   signal sdatas   : STD_LOGIC;
   signal data_ls   : STD_LOGIC_VECTOR (15 downto 0) := "0101010101010101";
   signal data_rs : STD_LOGIC_VECTOR (15 downto 0) := (others => '1');
   signal acceptedS : std_logic;
   signal tb_running       : boolean 	:= true;

begin

   i2scl : i2s_output port map(
      clk => clk,
      i2s_mclk => mclks,
		i2s_lrclk => lrclks,
		i2s_sclk => sclks,
		i2s_sd => sdatas,
		data_l => data_ls,
		data_r => data_rs,
      accepted => acceptedS
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

end Behavioral;
