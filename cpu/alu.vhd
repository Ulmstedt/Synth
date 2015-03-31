
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

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
      variable tmp   : std_logic_vector(2*REG_WIDTH-1 downto 0);
   begin
      if rising_edge(clk) then
         case(ALUInstr) is
            when ("00001") =>
               --ADD unsigned
               
               --variable is set instantly
               reg(REG_WIDTH downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(rightIn)) + to_integer(unsigned(leftIn)), REG_WIDTH+1));
               --set out
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(unsigned(reg)) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               
               if reg(REG_WIDTH) = '1' then
                  sRC <= '1';
               else
                  sRC <= '0';
               end if;
                  
            when ("00010") =>
               --ADD signed
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(signed(rightIn) + signed(leftIn));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(signed(reg)) = 0 then
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
               
               --makes no sense checking if negative flag should be set when dealing with unsigned
               --REPORT "REG VALUE: " & integer'image(to_integer(unsigned(reg)));
               if unsigned(reg) = 0 then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;
               --revise this one
               if reg(REG_WIDTH) = '1' then
                  sRC <= '1';
               else
                  sRC <= '0';
               end if;
               
            when ("00100") =>
               --SUB signed
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(signed(rightIn) - signed(leftIn));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(signed(reg)) = 0 then
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
               --convert the product of these to a std_logic_vector of size 32 bits
               tmp := std_logic_vector(to_signed(to_integer(signed(rightIn))*to_integer(signed(leftIn)), 2*REG_WIDTH));
               --put 16 highest bits from tmp into reg
               reg(REG_WIDTH-1 downto 0) := tmp(2*REG_WIDTH-1 downto REG_WIDTH);
               --fill rest of reg with 0's, possibly unnecessarily
               reg(2*REG_WIDTH-1 downto REG_WIDTH) := "00000000" & "00000000";
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(signed(reg)) = 0 then
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
               --set overflow if any of the upper half of tmp's bits except the sign bit 
               --probably useless
               if to_integer(signed(tmp(REG_WIDTH*2-1 downto REG_WIDTH))) = 0  then
                  sRO <= '0';
               else
                  sRO <= '1';
               end if;
            when("00110") =>
               --bitshift right
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(unsigned(rightIn) srl to_integer(unsigned(leftIn)));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(unsigned(reg)) = 0 then
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
                  sRO <= '0';
               else
                  sRO <= rightIn(to_integer(unsigned(leftIn)-1));
               end if;
               
            when("00111") =>
               --bitshift left
               reg(REG_WIDTH-1 downto 0) := std_logic_vector(unsigned(rightIn) sll to_integer(unsigned(leftIn)));
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(unsigned(reg)) = 0 then
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
                  sRO <= '0';
               else
                  sRO <= rightIn(REG_WIDTH-to_integer(unsigned(leftIn)));
               end if;
               
            when("01000") =>
               --AND
               reg(REG_WIDTH-1 downto 0) := rightIn and leftIn;
               ALUOut <= reg(REG_WIDTH-1 downto 0);
               
               if to_integer(unsigned(reg)) = 0 then
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
               
               if to_integer(unsigned(reg)) = 0 then
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
               
               if to_integer(unsigned(reg)) = 0 then
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
               
               if to_integer(unsigned(reg)) = 0 then
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
               if to_integer(unsigned(leftIn)) >= REG_WIDTH or to_integer(unsigned(leftIn)) < 0 then
                  --guard against bad usage
                  sRZ <= '0';
               elsif rightIn(to_integer(unsigned(leftIn))) = '0' then
                  sRZ <= '1';
               else
                  sRZ <= '0';
               end if;  
            when others =>
               --do nothing and others
               --perhaps sr should stay the same as previous clk? in that case need to keep previous flags
               null;
         end case;
      end if;
   end process;
end Behavioural;