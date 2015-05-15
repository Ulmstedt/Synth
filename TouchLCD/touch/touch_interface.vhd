library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.TouchConstants.all;

entity TouchInterface is
   port(
      PENIRQ   : in std_logic;
      BUSY     : in std_logic;
      DOUT     : in std_logic;
      DIN      : out std_logic;
      DCLK     : out std_logic;
      voltage  : out std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
      savePulse: out std_logic;
      Xaxis    : out std_logic;
      clk      : in std_logic;
      rst      : in std_logic
   );
end TouchInterface;


architecture Behavioural of TouchInterface is
   constant GET_X_MSG   : std_logic_vector(MESSAGE_WIDTH - 1 downto 0) := "110100110000000";
   constant GET_Y_MSG   : std_logic_vector(MESSAGE_WIDTH - 1 downto 0) := "100100110000000";

   signal reqMsg        : std_logic_vector(MESSAGE_WIDTH - 1 downto 0) := GET_X_MSG;--(others => '0');
   signal clkCounter    : std_logic_vector(6 downto 0) := (others => '0');
   signal touchMsg      : std_logic_vector(MESSAGE_WIDTH - 1 downto 0) := (others => '0');
   signal dclkS         : std_logic;

   signal sendCounter   : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(MESSAGE_WIDTH - 1,4));
   signal receiveCounter: std_logic_vector(3 downto 0) := (others => '0');
   signal aMsgIsSent    : std_logic := '0';
begin 
   
   -- Clkgen
   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            -- fill
         else
            clkCounter <= std_logic_vector(unsigned(clkCounter) + 1);
         end if;
      end if;
   end process;
   dclkS <= clkCounter(6);
   DCLK <= dclkS;

   -- Send
   process(dclkS) is
   begin
      if falling_edge(dclkS) then
         if rst = '1' then
            aMsgIsSent <= '0';
         else
            if to_integer(unsigned(sendCounter)) /= 0 then
               sendCounter <= std_logic_vector(unsigned(sendCounter) - 1);
            else
               sendCounter <= std_logic_vector(to_unsigned(MESSAGE_WIDTH - 1,4));
            end if;
            if to_integer(unsigned(sendCounter)) = 9 then
               aMsgIsSent <= '1';
            end if;
         end if;
      end if;
   end process;
   DIN <= reqMsg(to_integer(unsigned(sendCounter)));

   -- Recieve
   process(dclkS) is
   begin
      if rising_edge(dclkS) then
         if rst = '1' then
            receiveCounter <= (others => '0');
         elsif aMsgIsSent = '1' then
            if to_integer(unsigned(receiveCounter)) = MESSAGE_WIDTH - 1 then
               receiveCounter <= (others=> '0');
            else
               receiveCounter <= std_logic_vector(unsigned(receiveCounter) + 1);
            end if;
            touchMsg(to_integer(unsigned(receiveCounter))) <= DOUT;
         end if;
      end if;
   end process;
   voltage <= touchMsg(14 downto 3);

   -- The save pulse, a message has been received
   savePulse <= '1' when to_integer(unsigned(receiveCounter)) = 12 and to_integer(unsigned(clkCounter)) = 0 else '0';
 
end Behavioural;
