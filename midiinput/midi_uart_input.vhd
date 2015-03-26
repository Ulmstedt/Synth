library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MidiInput is
   port(
      uart        : in std_logic;  -- Incoming message bit
      clk         : in std_logic; -- Clock
      tmpReg     : out std_logic_vector(MIDI_WIDTH - 1 downto 0); -- The full UART message
      msgReady    : out std_logic; -- 1 if a complete message has been read into m1
   );
end MidiInput;

architecture Behavioral of MidiInput is
   signal m1            : std_logic_vector((M1_WIDTH - 1) downto 0) := B"0_00000000_0"; -- 10 bit shiftregister
   signal clkCounter    : std_logic_vector(4 downto 0) := std_logic_vector(UART_CLK_PERIOD/2); -- Counts ck, initialized to 16
   signal inputActive   : std_logic := '0'; -- 1 if receiving UART message, 0 if not
   signal bitsRecieved  : std_logic_vector(3 downto 0) := B"0000"; -- How many bits of the message has been received
begin

-- Check if UART message is coming
process(clk) is
   if rising_edge(clk) then
      if uart = '0' then
         inputActive <= '1';
      end if;
   end if;
end process;


process(clk) is
   if rising_edge(clk) and inputActive = '1' then
      -- Increment clk counter
      clkCounter <= std_logic_vector(to_unsigned(clkCounter)+1);
      
      -- Read a bit from uart to m1
      if clkCounter = UART_CLK_PERIOD then
         m1(to_unsigned(bitsRecieved)) <= uart;
         bitsRecieved <= std_logic_vector(to_unsigned(bitsRecieved)+1);
         clkCounter <= "00000";
         
         -- Full UART message has been received to m1
         if bitsRecieved = (M1_WIDTH - 1) then
            inputActive <= '0';
            msgReady <= '1';
            bitsRecieved <= "0000";
            tmpReg <= m1(M1_WIDTH - 2 downto 1); -- Transfer message to tmpReg, excluding start/stop bits
         end if;
         
      end if;
   end if;
end process;

process(clk) is
   if rising_edge(clk) and msgReady = '1' then
      msgReady <= '0';
   end if;
end process;

end Behavioral; 