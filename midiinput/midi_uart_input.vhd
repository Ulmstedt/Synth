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
   signal m1            : std_logic_vector((MIDI_WIDTH + 1) downto 0) := (others => '0'); -- 10 bit "shiftregister"
   signal clkCounter    : std_logic_vector(UART_CLK_PERIOD_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(UART_CLK_PERIOD/2, UART_CLK_PERIOD_WIDTH));
   signal inputActive   : std_logic := '0'; -- 1 if receiving UART message, 0 if not
   signal bitsReceived  : std_logic_vector(3 downto 0) := (others => '0'); -- How many bits of the message has been received1
   signal msgReadyS     : std_logic := '0';
   signal msgReadyCtr   : std_logic := '0';
begin


	-- Receive incoming message
	process(clk) is
	begin
      -- Check for incoming message
      if rising_edge(clk) then
      
         if rst = '1' then
            tmpReg <= (others => '0');
            m1 <= (others => '0');
            clkCounter <= std_logic_vector(to_unsigned(UART_CLK_PERIOD/2, UART_CLK_PERIOD_WIDTH));
            inputActive <= '0';
            bitsReceived <= (others => '0');
            
         else   
         
            if inputActive = '0' then
               if uart = '0' then
                  inputActive <= '1';
               end if;
            -- Receive the message
            elsif inputActive = '1' then
               -- Increment clk counter
               clkCounter <= std_logic_vector(unsigned(clkCounter)+1);
              
               -- Read a bit from uart to m1
               if clkCounter = std_logic_vector(to_unsigned(UART_CLK_PERIOD,UART_CLK_PERIOD_WIDTH)) then
               --if clkCounter = "100000" then
                  m1(MIDI_WIDTH+1 - to_integer(unsigned(bitsReceived))) <= uart; -- Save the bit to the correct location in m1
                  bitsReceived <= std_logic_vector(unsigned(bitsReceived)+1); -- Increment bits received counter
                  clkCounter <= (others => '0');
                
                -- Full UART message has been received to m1
                  if bitsReceived = std_logic_vector(to_unsigned(MIDI_WIDTH,4)+1) then
                     inputActive <= '0';
                     msgReadyS <= '1';
                     bitsReceived <= (others => '0');
                     clkCounter <= std_logic_vector(to_unsigned(UART_CLK_PERIOD/2, UART_CLK_PERIOD_WIDTH));
                     tmpReg <= m1(MIDI_WIDTH downto 1); -- Transfer message to tmpReg, excluding start/stop bits
                  end if;
               end if;
            end if;
            
            -- msgReady is 1 for 1 ck
            if msgReadyS = '1' then
               msgReadyS <= '0';
            end if;
            
         end if;
	   end if;
      
	end process;

	msgReady <= msgReadyS;

end Behavioral; 
