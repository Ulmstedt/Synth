library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sout_constants.all;

entity SoundOutput is
   port(
      clk               : in std_logic; -- Clock
      rst               : in std_logic; -- Reset
      sampleBuffer      : in std_logic_vector(SAMPLE_SIZE - 1 downto 0);
      sclk              : in std_logic; -- Serial clock
      lrck              : out std_logic; -- Left/Right clock
      sdout             : out std_logic -- Serial data output
   );
end SoundOutput;


architecture Behavioral of SoundOutput is

   signal bitCounter       : std_logic_vector(SAMPLE_SIZE_WIDTH - 1 downto 0) := (others => '0'); -- Counts the number of bits that has been output
   signal sample           : std_logic_vector(SAMPLE_SIZE - 1 downto 0) := (others => '0'); -- Current sample
   signal lrckS            : std_logic := '0'; -- Are we sending left/right output?
   
   signal sclkS            : std_logic; -- Serial clock signal

   signal tempsignal       : std_logic_vector(SAMPLE_SIZE_WIDTH-1 downto 0);
   
begin

   tempsignal <= std_logic_vector(to_unsigned(SAMPLE_SIZE-1 - to_integer(unsigned(bitCounter)),SAMPLE_SIZE_WIDTH));


   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            sample <= (others => '0');
            lrckS <= '0';
            bitCounter <= (others => '0');
            sdout <= '0';
         else
            sdout <= sample(SAMPLE_SIZE-1 - to_integer(unsigned(bitCounter))); -- Tidigare: SAMPLE_SIZE - 1
            -- Check for when the entire sample has been sent
            if bitCounter = std_logic_vector(to_unsigned(SAMPLE_SIZE-1,SAMPLE_SIZE_WIDTH)) then -- Tidigare: SAMPLE_SIZE - 1
               bitCounter <= (others => '0');
               if lrckS = '0' then
                  lrckS <= '1';
               else
                  lrckS <= '0';
                  sample <= sampleBuffer;
               end if;
            else
               bitCounter <= std_logic_vector(unsigned(bitCounter)+1);
            end if;
         end if;
      end if;
   end process;

   lrck <= lrckS;
   sclkS <= sclk;
   
end Behavioral;
