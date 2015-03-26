library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.midi_constants.all;

entity MidiInput is
   port(
      clk         : in std_logic; -- Clock
      rst         : in std_logic; -- Reset
      uart        : in std_logic; -- Incoming message bit
      tmpReg      : out std_logic_vector(MIDI_WIDTH - 1 downto 0); -- The full UART message
      msgReady    : out std_logic -- 1 if a complete message has been read into m1
   );
end MidiInput;

architecture Behavioral of MidiInput is
   signal m1            : std_logic_vector((MIDI_WIDTH + 1) downto 0) := B"0_00000000_0"; -- 10 bit "shiftregister"
   signal clkCounter    : std_logic_vector(UART_CLK_PERIOD'range) := std_logic_vector(UART_CLK_PERIOD/2,UART_CLK_PERIOD'left+1); -- Counts ck, initialized to 16
   signal inputActive   : std_logic := '0'; -- 1 if receiving UART message, 0 if not
   signal bitsReceived  : std_logic_vector(3 downto 0) := B"0000"; -- How many bits of the message has been received
   signal msgReadyS     : std_logic := '0';
begin

-- Check if UART message is coming
process(clk) is
   if rising_edge(clk) and rst = '0' then
      if uart = '0' then
         inputActive <= '1';
      end if;
   end if;
end process;

-- Receive incoming message
process(clk) is
   if rising_edge(clk) and inputActive = '1' and rst = '0' then
      -- Increment clk counter
      clkCounter <= std_logic_vector(to_unsigned(clkCounter)+1,UART_CLK_PERIOD'left+1);
      
      -- Read a bit from uart to m1
      if clkCounter = UART_CLK_PERIOD then
         m1(to_unsigned(bitsReceived)) <= uart;
         bitsReceived <= std_logic_vector(to_unsigned(bitsReceived)+1,4);
         clkCounter <= "00000";
         
         -- Full UART message has been received to m1
         if bitsReceived = (M1_WIDTH - 1) then
            inputActive <= '0';
            msgReadyS <= '1';
            bitsReceived <= "0000";
            tmpReg <= m1(M1_WIDTH - 2 downto 1); -- Transfer message to tmpReg, excluding start/stop bits
         end if;
         
      end if;
   end if;
end process;

-- msgReadyS should only be 1 for 1 clk
process(clk) is
   if rising_edge(clk) and msgReadyS = '1' then
      msgReadyS <= '0';
   end if;
end process;

msgReady <= msgReadyS;

-- Reset
process(clk) is
   if rising_edge(clk) and rst = '1' then
      tmpReg <= (others => '0');
      m1 <= (others => '0');
      clkCounter <= std_logic_vector(UART_CLK_PERIOD/2,UART_CLK_PERIOD'left+1);
      inputActive <= '0';
      bitsReceived <= (others => '0');
   end if;
end process;

end Behavioral; 