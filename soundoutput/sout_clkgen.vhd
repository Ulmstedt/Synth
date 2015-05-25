library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

-- This component generates the SCLK (serial clk) and MCLK (master clk) for the PmodI2S

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
   
   signal clk_counter      : std_logic := '0';
   signal mclk_counter     : std_logic_vector(2 downto 0) := (others => '0');
   signal mclk_pulse       : std_logic;
   signal mclkS            : std_logic := '0';
   signal sclkS            : std_logic := '0'; 
   
   signal hold_counter     : std_logic_vector(15 downto 0) := (others => '1');
begin

   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sclkS <= '0';
            mclkS <= '0';
            clk_counter <= '0';
            mclk_counter <= "000";
            hold_counter <= (others => '1');
         else
            if mclk_pulse = '1' then
               mclk_pulse <= '0';
               mclk_counter <= std_logic_vector(unsigned(mclk_counter)+1);
            end if;

            -- Generate clocks

            -- Master clock
            clk_counter <= not clk_counter; -- clk_counter is half the speed of clk (50 MHz)
            if clk_counter = '1' then
               if mclkS = '0' then
                  -- Set the pulse to start counting LRCK/SCLK when the intial delay has passed
                  if hold_counter /= std_logic_vector(to_unsigned(0, hold_counter'length)) then
                     hold_counter <= std_logic_vector(unsigned(hold_counter)-1);
                  else
                     mclk_pulse <= '1';
                  end if;
               end if;
               mclkS <= not mclkS; -- mclk is half the speed of clk_counter (25 MHz)
               
               -- Serial clock
               if mclk_counter = "111" and mclkS = '0' then
                  sclkS <= not sclkS; -- sclk is 1/16 of mclk
               end if;
            end if;
         end if;           
      end if;
   end process;

   mclk <= mclkS;
   sclk <= sclkS;
   sendBit <= '1' when sclkS = '1' and mclkS = '0' and clk_counter = '1' and mclk_counter = "111" else '0';
   
end Behavioral;
