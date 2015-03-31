library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity CheckMsg is
   port(
      clk      : in std_logic; -- Clock
      rst      : in std_logic; -- Reset
      msgReady : in std_logic; -- 1 when there is a msg ready in tmpReg
      outReady : in std_logic; -- 1 when message is ready to be transfered from tmpReg to mreg#
      muxCtr   : in std_logic_vector(1 downto 0);
      tmpReg   : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg1    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3    : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      validMsg : out std_logic; -- 1 when we have a valid incoming midi-msg
      readRdy  : out std_logic -- pulse when a complete message is ready in Mreg1-3
   );
end CheckMsg;

architecture Behavioral of CheckMsg is

signal valid         : std_logic;
signal readingValid  : std_logic := '0';
signal readRdyS      : std_logic := '0';

begin

	-- MK3, checks if tmpReg contains a midi-msg that we are interested in
	with tmpReg(MIDI_WIDTH-1 downto 4) select valid <=
	   '1' when "1000",
	   '1' when "1001",
	   '0' when others;
			 
	-- MUX
	process(clk) is
	begin
	   if rising_edge(clk) and readingValid = '1' and outReady = '1' and rst = '0' then
		  case muxCtr is
			 when "00" => mreg1 <= tmpReg;
			 when "01" => mreg2 <= tmpReg;
			 when "10" => 
						 mreg3 <= tmpReg;
						 readingValid <= '0';
						 readRdyS <= '1';
			 when others => null;
		  end case;
	   end if;
	end process;

	-- When we have a valid midi-msg incoming, set readingValid = 1
	process(clk) is
	begin
	   if rising_edge(clk) and valid = '1' and rst = '0' then
		  readingValid <= '1';
	   end if;
	end process;

	validMsg <= readingValid;

	-- readRdyS should only be 1 for 1 clk
	process(clk) is
	begin
	   if rising_edge(clk) and readRdyS = '1' then
		  readRdyS <= '0';
	   end if;
	end process;

	readRdy <= readRdyS;

	-- Reset
	process(clk) is
	begin
	   if rising_edge(clk) and rst = '1' then
		  readingValid <= '0';
		  validMsg <= '0';
		  mreg1 <= (others => '0');
		  mreg2 <= (others => '0');
		  mreg3 <= (others => '0');
	   end if;
	end process;

end Behavioral;