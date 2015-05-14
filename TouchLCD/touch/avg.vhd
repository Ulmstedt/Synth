library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.TouchConstants.all;

entity Avg is
   port(
      voltage     : in std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
      result      : out std_logic_vector(VOLTAGE_WIDTH - 1 downto 0);
      savePulse   : in std_logic;
      donePulse   : out std_logic;
      clk         : in std_logic;
      rst         : in std_logic
   );
end Avg;

architecture Behavioral of Avg is
   signal min        : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0) := (others => '1');
   signal max        : std_logic_vector(VOLTAGE_WIDTH - 1 downto 0) := (others => '0');
   signal avgAcc     : std_logic_vector(VOLTAGE_WIDTH + 3 downto 0) := (others => '0');

   signal counter    : std_logic_vector(3 downto 0) := (others => '0'); 
   signal donePulseS : std_logic := '0';

   signal tmpRes     : std_logic_vector(VOLTAGE_WIDTH + 3 downto 0);
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if donePulseS = '1' then
            donePulseS <= '0';
            avgAcc <= (others => '0');
            min <= (others => '1');
            max <= (others => '0');
         end if;
         if rst = '1' then
            min <= (others => '1');
            max <= (others => '0');
            counter <= (others => '0');
            avgAcc <= (others => '0');
         elsif savePulse = '1' and to_integer(unsigned(voltage)) /= 0 then
            if to_integer(unsigned(counter)) = 9 then
               counter <= (others => '0');
               donePulseS <= '1';
            else
               counter <= std_logic_vector(unsigned(counter) + 1);
            end if;
            avgAcc <= std_logic_vector(unsigned(avgAcc) + unsigned(voltage)); --add sample to accumulator
			   if (voltage < min) then --keep track of minimum
				   min <= voltage;
			   end if;
			   if (voltage > max) then --keep track of maximum
				   max <= voltage;
			   end if;
         end if;
      end if;
   end process;

   tmpRes <= std_logic_vector((unsigned(avgAcc) - unsigned(min) - unsigned(max)) / 8);
   result <= tmpRes(VOLTAGE_WIDTH - 1 downto 0);
   donePulse <= donePulseS;

end Behavioral;
