library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity CheckMsg is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      msgReady          : in std_logic; -- 1 when there is a msg ready in tmpReg
      tmpReg            : in std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg1             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg2             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      mreg3             : out std_logic_vector(MIDI_WIDTH - 1 downto 0);
      readRdy           : out std_logic -- pulse when a complete message is ready in Mreg1-3
   );
end CheckMsg;

architecture Behavioral of CheckMsg is

   signal valid         : std_logic := '0'; -- 1 when the last message received was a valid one
   signal cntDataByte   : std_logic := '0';
   signal readRdyS    : std_logic := '0';
   signal mreg1S        : std_logic_vector(MIDI_WIDTH - 1 downto 0) := (others => '0');


begin

	-- MK3, checks if tmpReg contains a midi-msg that we are interested in
	with mreg1S(MIDI_WIDTH-1 downto 4) select valid <=
	   '1' when "1000",
	   '1' when "1001",
      '1' when "1011",
      '1' when "1110",
	   '0' when others;
   
   -- Master
   process(clk) is
   begin
      if rising_edge(clk) then
         -- Reset
         if rst = '1' then
            cntDataByte <= '0';
            readRdyS  <= '0';
            mreg2       <= (others => '0');
            mreg3       <= (others => '0');
            mreg1S      <= (others => '0');
         else
            -- Read ready is a pulse, so reset it
            if readRdyS = '1' then
               readRdyS <= '0';
            end if;

            -- A message is received
            if msgReady = '1' then
               if tmpReg(MIDI_WIDTH - 1) = '1' then
                  cntDataByte <= '0';
                  mreg1S <= tmpReg;
               else
                  if cntDataByte = '0' then
                     mreg2 <= tmpReg;
                  else
                     mreg3 <= tmpReg;
                     readRdyS <= '1';
                  end if;
                  cntDataByte <= not cntDataByte;
               end if;
            end if;
         end if;
	   end if;
   end process;
   
   mreg1       <= mreg1S;
   -- Send the readReady pulse writing the values to the registers and setting the SR flag
   readRdy   <= readRdyS and valid;
end Behavioral;
