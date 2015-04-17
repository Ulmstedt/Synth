
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

---ALUOut == D3Out
entity ALU is
   port(
      leftIn  : in std_logic_vector(REG_WIDTH-1 downto 0);
      rightIn : in std_logic_vector(REG_WIDTH-1 downto 0);
      ALUOut  : out std_logic_vector(REG_WIDTH-1 downto 0);
      ALUInstr  : in std_logic_vector(4 downto 0);
      
      clk      : in std_logic;
      
      sRZ     : out std_logic;
      sRN     : out std_logic;
      sRO     : out std_logic;
      sRC     : out std_logic
   );
end ALU;

--ALUINST.r
--00101 OOOOO RRRR X XXXX XXXX XXXX RRRR

--ALUINST.c
--00110 OOOOO RRRR X DDDD DDDD DDDD DDDD

--First register will be put into rightIn, second reg or constant will be put in leftIn

--carry flag is only of importance for unsigned arithmetic
--overflow flag is only of importance for signed arithmetic
--so will not care about those other cases

architecture Behavioural of ALU is
begin 
   process (clk)
      variable reg  : std_logic_vector(2*REG_WIDTH-1 downto 0);
   begin
      if rising_edge(clk) then
         case(ALUInstr) is
            when ("00001") =>
               --ADD unsigned
               --variable is set instantly(not like signals)
               reg(REG_WIDTH downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(rightIn)) + to_integer(unsigned(leftIn)), REG_WIDTH+1));
               --Then set out
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               --then we check if we should set flags, all cases will follow this "formula"
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --There is carry if bit # REG_WIDTH is 1
               if reg(REG_WIDTH) = '1' then
                  sRC <= '1';
               else
                  sRC <= '0';
               end if;
                  
            when ("00010") =>
               --ADD signed
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(signed(rightIn) + signed(leftIn));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if signed(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
               --if the sum of two operands both with sign bit on results in a number with sign bit off we set overflow
               --do same if two operands with sign bit off results in a number with sign bit on we have overflow
               if (rightIn(REG_WIDTH-1) = '1' and leftIn(REG_WIDTH-1) = '1' and reg(REG_WIDTH-1) = '0') or
                  (rightIn(REG_WIDTH-1) = '0' and leftIn(REG_WIDTH-1) = '0' and reg(REG_WIDTH-1) = '1') then
                  sRO <= '1';
               else
                  sRO <= '0';
               end if;
               
            when ("00011") =>
               --SUB unsigned
               reg(REG_WIDTH downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(rightIn)) - to_integer(unsigned(leftIn)), REG_WIDTH+1));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               --REPORT "REG VALUE: " & integer'image(to_integer(unsigned(reg)));
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check if negative to indicate error of use of this function
               if unsigned(leftIn) > unsigned(rightIn) then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
               if reg(REG_WIDTH) = '1' then
                  sRC <= '1';
               else
                  sRC <= '0';
               end if;
               
            when ("00100") =>
               --SUB signed
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(signed(rightIn) - signed(leftIn));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if signed(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH*2-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
               --rightIn-leftIn
               --if the sum of the two operands rightIn with sign bit on, leftIn with sign bit off results in something with sign bit off we set overflow
               --if the sum of the two operands rightIn with sign bit off, leftIn with sign bit on results in something with sign bit on we set overflow
               if (rightIn(REG_WIDTH-1) = '1' and leftIn(REG_WIDTH-1) = '0' and reg(REG_WIDTH-1) = '0') or
                  (rightIn(REG_WIDTH-1) = '0' and leftIn(REG_WIDTH-1) = '1' and reg(REG_WIDTH-1) = '1') then
                  sRO <= '1';
               else
                  sRO <= '0';
               end if;
               
            when ("00101") =>
               --MUL (signed fixed point)
               reg(REG_WIDTH*2-1 downto 0) := std_logic_vector(signed(rightIn) * signed(leftIn));

               --REPORT "RIN VALUE: " & integer'image(to_integer(signed(rightIn)));
               --REPORT "LIN VALUE: " & integer'image(to_integer(signed(leftIn)));
               --REPORT "REG VALUE: " & integer'image(to_integer(signed(reg)));
               
               --take the highest 16 bits to output
               ALUOut <= reg(REG_WIDTH*2-1 downto REG_WIDTH);
               
               if signed(reg(REG_WIDTH*2-1 downto REG_WIDTH)) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH*2-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
          
            when("00110") =>
               --bitshift right
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(unsigned(rightIn) srl to_integer(unsigned(leftIn)));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg(REG_WIDTH-1 downto 0)) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit(here we just look at most significant bit that we put ALUOut)
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
               --set overflow to last bit shifted out
               if to_integer(unsigned(leftIn)) > REG_WIDTH or to_integer(unsigned(leftIn)) = 0 then
                  sRC <= '0';
               else
                  sRC <= rightIn(to_integer(unsigned(leftIn)-1));
               end if;
               
            when("00111") =>
               --bitshift left
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(unsigned(rightIn) sll to_integer(unsigned(leftIn)));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
               --set overflow to last bit shifted out
               if to_integer(unsigned(leftIn)) > REG_WIDTH or to_integer(unsigned(leftIn)) = 0 then
                  sRC <= '0';
               else
                  sRC <= rightIn(REG_WIDTH-to_integer(unsigned(leftIn)));
               end if;
               
            when("01000") =>
               --AND
               reg(REG_WIDTH-1 downto 0) := rightIn and leftIn;
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg(REG_WIDTH-1 downto 0)) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               --check signbit
               
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
            when("01001") =>
               --OR
               reg(REG_WIDTH-1 downto 0) := rightIn or leftIn;
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
            when("01010") =>
               --XOR
               reg(REG_WIDTH-1 downto 0) := rightIn xor leftIn;
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
            when("01011") =>
               --NOT
               reg(REG_WIDTH-1 downto 0) := not rightIn;
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  sRN <= '1';
               else
                  sRN <= '0';
               end if;
               
            when("01100") =>
               --CMP
               if rightIn = leftIn then
                  --if they are equal 
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               if rightIn < leftIn then
                  --if rx < ry or rx < const we put a 1 on the most significant bit of reg
                  sRN <= '1';
               elsif rightIn >= leftIn then
                  sRN <= '0';
               end if;
               
            when("01111") =>
               --BITTEST
               --make sure this works
               if unsigned(leftIn) >= REG_WIDTH then
                  srZ <= '0';
               elsif rightIn(to_integer(unsigned(leftIn))) = '0' then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
            when("11111") =>
            --reserved to let left_in go through
            ALUOut <= leftIn;
            
            when("10000") =>
            --ADD unsigned without affecting flags
               --variable is set instantly(not like signals)
               reg(REG_WIDTH downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(rightIn)) + to_integer(unsigned(leftIn)), REG_WIDTH+1));
               --Then set out
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
            when others =>
               --do nothing and others
               --if this case goes through same ALUOut and flags remain same as from last clk
               null;
         end case;
      end if;
   end process;
end Behavioural;
