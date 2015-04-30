library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity CheckMsg is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      msgReady          : in std_logic; -- 1 when there is a msg ready in tmpReg
      outReady          : in std_logic; -- 1 when message is ready to be transferred from tmpReg to mreg#
      muxCtr            : in std_logic_vector(1 downto 0);
      tmpReg            : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg1             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      validMsgO         : out std_logic; -- 1 when we have a valid incoming midi-msg
      msgReadyDelayed   : out std_logic; -- A msgReady pulse that is delayed by 1 ck
      readRdy           : out std_logic -- pulse when a complete message is ready in Mreg1-3
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
			 

	validMsgO <= readingValid;
	readRdy <= readRdyS;

   
   -- Master
   process(clk) is
   begin
      if rising_edge(clk) then
         -- Reset
         if rst = '1' then
            readingValid <= '0';
            mreg1 <= (others => '0');
            mreg2 <= (others => '0');
            mreg3 <= (others => '0');
         end if;
         
         -- MUX
         if readingValid = '1' and outReady = '1' then
            case muxCtr is
               when "01" => mreg1 <= tmpReg;
               when "10" => mreg2 <= tmpReg;
               when "11" => 
                        mreg3 <= tmpReg;
                        readingValid <= '0';
                        readRdyS <= '1';
               when others => null;
            end case;

         elsif valid = '1' then         
            -- When we have a valid midi-msg incoming, set readingValid = 1
            readingValid <= '1';
         end if;         
         -- Pulse a delayed msgReady
         if msgReady = '1' then
            msgReadyDelayed <= '1';
         else
            msgReadyDelayed <= '0';
         end if;
         
         -- readRdyS should only be 1 for 1 clk
         if readRdyS = '1' then
            readRdyS <= '0';
         end if;
         
	   end if;
   end process;
end Behavioral;
