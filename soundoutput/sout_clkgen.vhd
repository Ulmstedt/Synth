library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoutClkgen is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sendBit           : out std_logic;
      sclk              : out std_logic; -- Serial clock
      mclk              : out std_logic -- Master clock
   );
end SoutClkgen;


architecture Behavioral of SoutClkgen is
   
   signal sclkS            : std_logic; -- Serial clock signal
   signal mclkS            : std_logic; -- Master clock signal
   signal clk_counter      : std_logic_vector(11 downto 0) := (others => '0'); -- Clk counter
   signal mclk_counter     : std_logic_vector(3 downto 0) := "0001";
   signal sendBitS         : std_logic;
   
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sclkS <= '0';
            mclkS <= '0';
            clk_counter <= (others => '0');
         else
            -- Generate clocks

            clk_counter <= std_logic_vector(unsigned(clk_counter)+1);
            if clk_counter = std_logic_vector(to_unsigned(34,12)) then -- 2267?
               -- "Shift" clock
               if sclkS = '0' then
                  sendBitS <= '1';
                  sclkS <= '1';
               else
                  sclkS <= '0';
               end if;
               clk_counter <= (others => '0');

            end if;
            
            mclk_counter <= std_logic_vector(unsigned(mclk_counter)+1);
            if mclk_counter = std_logic_vector(to_unsigned(7,4)) then
               -- Master clock 
               if mclkS = '0' then
                  mclkS <= '1';
               else
                  mclkS <= '0';
               end if;
               mclk_counter <= (others => '0');
            end if;
            
         end if;

         if sendBitS = '1' then
            sendBitS <= '0';
         end if;

      end if;
   end process;

   mclk <= mclkS;
   sclk <= sclkS;
   sendBit <= sendBitS;
   
end Behavioral;
