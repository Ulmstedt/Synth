library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity TouchInterface is
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
end TouchInterface;


architecture Behavioural of TouchInterface is
  
   signal reqMsg        : std_logic_vector(7 downto 0) := "10010111";--(others => '0');
   signal counter       : std_logic_vector(3 downto 0) := (others => '0');
   signal clkCounter    : std_logic_vector(11 downto 0) := (others => '0');
   signal touchMsg      : std_logic_vector(11 downto 0) := (others => '0');
   signal touchMsgCtr   : std_logic_vector(3 downto 0) := (others => '0');
   signal receivedMsg   : std_logic := '1';
   signal sendPulse     : std_logic := '0';
   signal beenBusy      : std_logic := '0';
   
begin 

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            counter <= (others => '0');
            clkCounter <= (others => '0');
            sendPulse <= '0';
            receivedMsg <= '1';
            DIN <= '0';
         else
            if PENIRQ = '0' and receivedMsg = '1' then
               receivedMsg <= '0';
               counter <= (others => '0');
               clkCounter <= (others => '0');
               beenBusy <= '0';
               touchMsgCtr <= std_logic_vector(to_unsigned(12,4));
            else
               clkCounter <= std_logic_vector(unsigned(clkCounter)+1);
               if unsigned(clkCounter) = 0 then
                  sendPulse <= '1';
               else
                  sendPulse <= '0';
               end if;
            end if;
            
            if receivedMsg = '0' then
               if BUSY = '1' then
                  beenBusy <= '1';
               end if;
               -- Send request msg
               if sendPulse = '1' then
                  if counter(3) /= '1' then
                     counter <= std_logic_vector(unsigned(counter)+1);
                     DIN <= reqMsg(7 - to_integer(unsigned(counter(2 downto 0)))); -- Shift out bit
                  else
                     DIN <= '0';
                     -- Receive msg
                     if BUSY = '0' and beenBusy = '1' and unsigned(touchMsgCtr) /= 0 then
                        touchMsg(to_integer(unsigned(touchMsgCtr)) - 1) <= DOUT;
                        touchMsgCtr <= std_logic_vector(unsigned(touchMsgCtr)-1);
                     end if;
                  end if;
               end if;
            end if;
            

         end if;
      end if;
   end process;

   DCLK <= clkCounter(clkCounter'high) and (not receivedMsg);
   CS <= receivedMsg;
 
end Behavioural;
