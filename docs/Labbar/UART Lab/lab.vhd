library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab is
    Port ( clk,rst, rx : in  STD_LOGIC;
           seg: out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end lab;

architecture Behavioral of lab is
    component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           value : in  STD_LOGIC_VECTOR (15 downto 0));
    end component;
    signal sreg : STD_LOGIC_VECTOR(9 downto 0) := B"0_00000000_0";  -- 10 bit skiftregister
    signal tal : STD_LOGIC_VECTOR(15 downto 0) := X"0000";  
    signal rx1,rx2 : std_logic;         -- vippor på insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp : std_logic;         -- laddpuls
    signal pos : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
  -- rst är tryckknappen i mitten under displayen
  -- *****************************
  -- *  synkroniseringsvippor    *
  -- *****************************
sync: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            rx1 <= '0';
            rx2 <= '0';
        else
            rx1 <= rx;
            rx2 <= rx1;
        end if;
    end if;
end process sync;
  
  -- *****************************
  -- *       styrenhet           *
  -- *****************************

styr: process(clk)
Variable clk_counter : std_logic_vector(9 downto 0) := B"0110110010"; -- initiera till 434 så att vi hämtar mitt i varje transfer
Variable input_active : std_logic := '0'; -- boolean som håller koll på om vi är mitt i en transfer
Variable inputs_collected : std_logic_vector(3 downto 0) := B"0000"; -- räknar hur många bitar vi har hämtat
begin
    if rising_edge(clk) then
        -- kolla om vi ska reseta
        if rst = '1' then
            clk_counter := "0110110010";
            input_active := '0';
            inputs_collected := "0000";
            sp <= '0';
            lp <= '0';
        else
            -- startbit för överföring
            if rx2 = '0' then 
                input_active := '1';
            end if;
            -- laddpuls ska vara 1 endast 1 clk
            if lp = '1' then 
                lp <= '0';
            end if;
            -- skiftpuls ska vara 1 endast 1 clk
            if sp = '1' then 
                sp <= '0';
            end if;
            -- om input_active är 1 så ska vi hämta en bit var 868:e klockpuls
            if input_active = '1' then
                -- när vi har hämtat 10 bitar är vi klara (när inputs_collected == 10) så då resetar vi allt
                if inputs_collected = "1010" then
                    clk_counter := "0110110010";
                    input_active := '0';
                    inputs_collected := "0000";
                    sp <= '0';
                    lp <= '1';
                else
                    if clk_counter = 868 then -- skicka ut skiftpuls var 868:e clk
                        clk_counter := "0000000000"; -- nollställ clk_counter
                        inputs_collected := inputs_collected+1; -- räkna upp hur många bitar vi har hämtat
                        sp <= '1';
                    else
                        clk_counter := clk_counter+1;
                    end if;
                end if;   
            end if;
        end if;
    end if;
end process styr;  



  -- *****************************
  -- * 10 bit skiftregister      *
  -- *****************************
  
process(clk)
begin
    if rising_edge(clk) then
        -- kolla om vi ska reseta
        if rst = '1' then
            sreg <= "0000000000";
        else
            if sp = '1' then
                sreg(0) <= sreg(1);
                sreg(1) <= sreg(2);
                sreg(2) <= sreg(3);
                sreg(3) <= sreg(4);
                sreg(4) <= sreg(5);
                sreg(5) <= sreg(6);
                sreg(6) <= sreg(7);
                sreg(7) <= sreg(8);
                sreg(8) <= sreg(9);
                sreg(9) <= rx2;
            end if;
        end if;
    end if;
end process;

  -- *****************************
  -- * 2  bit register           *
  -- *****************************
process(clk)
begin
    if rising_edge(clk) then
        -- kolla om vi ska reseta
        if rst = '1' then
            pos <= "00";
        else
            if lp = '1' then
              if pos<3 then
                pos <=pos+1;
              else
                pos <= "00";
              end if;
            end if;
        end if;
    end if;
end process;
    
  -- *****************************
  -- * 16 bit register           *
  -- *****************************

process(clk)
begin
    if rising_edge(clk) then
        -- kolla om vi ska reseta
        if rst = '1' then
            tal <= "0000000000000000";
        else
            if lp = '1' then
                case pos is
                    when "00" => tal(15 downto 12) <= sreg(4 downto 1);
                    when "01" => tal(11 downto 8) <= sreg(4 downto 1);
                    when "10" => tal(7 downto 4) <= sreg(4 downto 1);
                    when "11" => tal(3 downto 0) <= sreg(4 downto 1);
                    when others => null;
                end case;
            end if;
        end if;
    end if;
end process;

  -- *****************************
  -- * Multiplexad display       *
  -- *****************************
  led: leddriver port map (clk, rst, seg, an, tal);
end Behavioral;

