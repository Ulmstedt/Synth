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

--First register will be put into leftIn, second reg or constant will be put in rightIn

--carry flag is only of importance for unsigned arithmetic
--overflow flag is only of importance for signed arithmetic
--so will not care about those other cases

architecture Behavioural of ALU is
   --with initialized values
   signal temp                :  std_logic_vector(2*REG_WIDTH-1 downto 0) := (others => '0');
   signal checkCarryTemp      :  std_logic_vector(2*REG_WIDTH-1 downto 0) := (others => '0');
   signal checkOverflowTemp   :  std_logic_vector(2*REG_WIDTH-1 downto 0) := (others => '0');
   
   signal sRZInternal         :  std_logic := '0';
   signal sRNInternal         :  std_logic := '0';
   signal sRCInternal         :  std_logic := '0';
   signal sROInternal         :  std_logic := '0';

   signal srZlast             : std_logic := '0';
   signal srNlast             : std_logic := '0';
   signal srClast             : std_logic := '0';
   signal srOlast             : std_logic := '0';
   
begin 
   --only when compare uns
   checkCarryTemp <= (REG_WIDTH*2 - 1 downto REG_WIDTH + 1 => '0') & std_logic_vector(to_unsigned(to_integer(unsigned(leftIn)) - to_integer(unsigned(rightIn)), REG_WIDTH+1)) when ALUInstr = "01100" else
                     (others => '0');
   
   --only when compare sig
   checkOverflowTemp <= (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & std_logic_vector(signed(leftIn) - signed(rightIn)) when ALUInstr = "01101" else
                     (others => '0');
   
   with ALUInstr select
      --do arithmetic operation
      temp  <= (REG_WIDTH*2 - 1 downto REG_WIDTH + 1 => '0') & std_logic_vector(to_unsigned(to_integer(unsigned(leftIn)) + to_integer(unsigned(rightIn)), REG_WIDTH+1)) when "00001",  --ADD unsigned
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & std_logic_vector(signed(leftIn) + signed(rightIn)) when "00010",                                                            --ADD signed
               (REG_WIDTH*2 - 1 downto REG_WIDTH + 1 => '0') & std_logic_vector(to_unsigned(to_integer(unsigned(leftIn)) - to_integer(unsigned(rightIn)), REG_WIDTH+1)) when "00011",  --SUB unsigned
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & std_logic_vector(signed(leftIn) - signed(rightIn)) when "00100",                                                            --SUB signed
               std_logic_vector((signed(leftIn) * signed(rightIn)) srl REG_WIDTH) when "00101",                                                                                        --MUL(signed fixed point)(result in 16 msb so make right shifts so result ends up in 16 lsb like all other)
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & std_logic_vector(unsigned(leftIn) srl to_integer(unsigned(rightIn))) when "00110",                                          --bitshift right
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & std_logic_vector(unsigned(leftIn) sll to_integer(unsigned(rightIn))) when "00111",                                          --bitshift left
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & (leftIn and rightIn) when "01000",                                                                                          --AND
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & (leftIn or rightIn) when "01001",                                                                                           --OR
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & (leftIn xor rightIn) when "01010",                                                                                          --XOR
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & (not leftIn) when "01011",                                                                                                  --NOT
               (REG_WIDTH*2 - 1 downto REG_WIDTH + 1 => '0') & std_logic_vector(to_unsigned(to_integer(unsigned(leftIn)) + to_integer(unsigned(rightIn)), REG_WIDTH+1)) when "10000",  --ADD unsigned without affecting flags
               (REG_WIDTH*2 - 1 downto REG_WIDTH => '0') & leftIn when "11111",                                                                                                        --let leftIn go through ALU
               temp when "00000",                                                                                                                                                      --DO nothing
               temp when "01100",                                                                                                                                                      --CMP unsigned
               temp when "01101",                                                                                                                                                      --CMP signed
               temp when "01111",                                                                                                                                                      --BITTEST
               temp when others;                                                                                                                                                       --catch all
   
   --set ZERO flag
   sRZInternal   <= '1' when ALUInstr = "00001" and unsigned(temp) = 0 else                                                                           --ADD unsigned
            '1' when ALUInstr = "00010" and signed(temp) = 0 else                                                                                     --ADD signed
            '1' when ALUInstr = "00011" and unsigned(temp) = 0 else                                                                                   --SUB unsigned
            '1' when ALUInstr = "00100" and signed(temp) = 0 else                                                                                     --SUB signed
            '1' when ALUInstr = "00101" and signed(temp) = 0 else                                                                                     --MUL(signed fixed point)
            '1' when ALUInstr = "00110" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --BITSHIFT RIGHT
            '1' when ALUInstr = "00111" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --BITSHIFT LEFT
            '1' when ALUInstr = "01000" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --AND
            '1' when ALUInstr = "01001" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --OR
            '1' when ALUInstr = "01010" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --XOR
            '1' when ALUInstr = "01011" and unsigned(temp(REG_WIDTH-1 downto 0)) = 0 else                                                             --NOT
            '1' when ALUInstr = "01100" and unsigned(leftIn) = unsigned(rightIn) else                                                                 --CMP UNSIGNED
            '1' when ALUInstr = "01101" and signed(leftIn) = signed(rightIn) else                                                                     --CMP SIGNED
            '1' when ALUInstr = "01111" and to_integer(unsigned(rightIn)) <=(REG_WIDTH-1) and leftIn(to_integer(unsigned(rightIn))) = '0' else        --BITTEST
            srZlast when ALUInstr = "10000" else                                                                                                      --ADD without affecting SR
            srZlast when ALUInstr = "11111" else                                                                                                      --Let leftIn through
            srZlast when ALUInstr = "00000" else                                                                                                      --Do nothing
            '0';                                                                                                                                      --other cases
   

      --set NEGATIVE flag
   sRNInternal   <= srNlast when ALUInstr = "00001" else                                                                                              --ADD unsigned
            '1' when ALUInstr = "00010" and temp(REG_WIDTH-1) = '1' else                                                                              --ADD signed
            '1' when ALUInstr = "00011" and unsigned(leftIn) < unsigned(rightIn) else                                                                 --SUB unsigned
            '1' when ALUInstr = "00100" and temp(REG_WIDTH-1) = '1' else                                                                              --SUB signed
            '1' when ALUInstr = "00101" and temp(REG_WIDTH-1) = '1' else                                                                              --MUL(signed fixed point)
            '1' when ALUInstr = "00110" and temp(REG_WIDTH-1) = '1' else                                                                              --BITSHIFT RIGHT
            '1' when ALUInstr = "00111" and temp(REG_WIDTH-1) = '1' else                                                                              --BITSHIFT LEFT
            '1' when ALUInstr = "01000" and temp(REG_WIDTH-1) = '1' else                                                                              --AND
            '1' when ALUInstr = "01001" and temp(REG_WIDTH-1) = '1' else                                                                              --OR
            '1' when ALUInstr = "01010" and temp(REG_WIDTH-1) = '1' else                                                                              --XOR
            '1' when ALUInstr = "01011" and temp(REG_WIDTH-1) = '1' else                                                                              --NOT
            '1' when ALUInstr = "01100" and unsigned(leftIn) < unsigned(rightIn) else                                                                 --CMP UNSIGNED
            '1' when ALUInstr = "01101" and signed(leftIn) < signed(rightIn) else                                                                     --CMP SIGNED
            srNlast when ALUInstr = "01111" else                                                                                                      --BITTEST
            srNlast when ALUInstr = "10000" else                                                                                                      --ADD without affecting SR
            srNlast when ALUInstr = "11111" else                                                                                                      --Let leftIn through
            srNlast when ALUInstr = "00000" else                                                                                                      --Do nothing
            '0';                                                                                                                                      --other cases

         
     --set CARRY flag
   sRCInternal   <= '1' when ALUInstr = "00001" and temp(REG_WIDTH) = '1' else                                                                        --ADD unsigned
            srClast when ALUInstr = "00010" else                                                                                                      --ADD signed
            '1' when ALUInstr = "00011" and temp(REG_WIDTH) = '1' else                                                                                --SUB unsigned
            srClast when ALUInstr = "00100" else                                                                                                      --SUB signed
            srClast when ALUInstr = "00101" else                                                                                                      --MUL(signed fixed point)
            leftIn(to_integer(unsigned(rightIn)) - 1) when ALUInstr = "00110" and to_integer(unsigned(rightIn)) < REG_WIDTH and 
                                                           to_integer(unsigned(rightIn)) /= 0 else                                                    --BITSHIFT RIGHT
            leftIn(REG_WIDTH - to_integer(unsigned(rightIn))) when ALUInstr = "00111" and to_integer(unsigned(rightIn)) < REG_WIDTH and 
                                                                   to_integer(unsigned(rightIn)) /= 0 else                                            --BITSHIFT LEFT
            srClast when ALUInstr = "01000" else                                                                                                      --AND
            srClast when ALUInstr = "01001" else                                                                                                      --OR
            srClast when ALUInstr = "01010" else                                                                                                      --XOR
            srClast when ALUInstr = "01011" else                                                                                                      --NOT
            '1' when ALUInstr = "01100" and checkCarryTemp(REG_WIDTH) = '1' else                                                                      --CMP UNSIGNED(check if carry was generated)
            srClast when ALUInstr = "01101" else                                                                                                      --CMP SIGNED
            srClast when ALUInstr = "01111" else                                                                                                      --BITTEST
            srClast when ALUInstr = "10000" else                                                                                                      --ADD without affecting SR
            srClast when ALUInstr = "11111" else                                                                                                      --Let leftIn through
            srClast when ALUInstr = "00000" else                                                                                                      --Do nothing
            '0';                                                                                                                                      --other cases
         
         --set OVERFLOW flag
   sROInternal   <= srOlast when ALUInstr = "00001" else                                                                                              --ADD unsigned
            '1' when ALUInstr = "00010" and ((leftIn(REG_WIDTH-1) = '1' and rightIn(REG_WIDTH-1) = '1' and temp(REG_WIDTH-1) = '0') or
                  (leftIn(REG_WIDTH-1) = '0' and rightIn(REG_WIDTH-1) = '0' and temp(REG_WIDTH-1) = '1')) else                                         --ADD signed if the sum of two operands both with sign bit on results in a number with sign bit off we set overflow
                                                                                                                                                      --do same if two operands with sign bit off results in a number with sign bit on we have overflow
            srOlast when ALUInstr = "00011" else                                                                                                      --SUB unsigned
            '1' when ALUInstr = "00100" and ((leftIn(REG_WIDTH-1) = '1' and rightIn(REG_WIDTH-1) = '0' and temp(REG_WIDTH-1) = '0') or
                  (leftIn(REG_WIDTH-1) = '0' and rightIn(REG_WIDTH-1) = '1' and temp(REG_WIDTH-1) = '1')) else                                        --SUB signed assume x negative and y positive, if x-y results in a positive value we have overflow. Assume x positive and y negative,
                                                                                                                                                      -- if x-y results in a negative value we have overflow
            srOlast when ALUInstr = "00101" else                                                                                                      --MUL(signed fixed point)
            srOlast when ALUInstr = "00110" else                                                                                                      --BITSHIFT RIGHT
            srOlast when ALUInstr = "00111" else                                                                                                      --BITSHIFT LEFT
            srOlast when ALUInstr = "01000" else                                                                                                      --AND
            srOlast when ALUInstr = "01001" else                                                                                                      --OR
            srOlast when ALUInstr = "01010" else                                                                                                      --XOR
            srOlast when ALUInstr = "01011" else                                                                                                      --NOT
            srOlast when ALUInstr = "01100" else                                                                                                      --CMP UNSIGNED
            '1' when ALUInstr = "01101" and ((leftIn(REG_WIDTH-1) = '1' and rightIn(REG_WIDTH-1) = '0' and checkOverflowTemp(REG_WIDTH-1) = '0') or
                  (leftIn(REG_WIDTH-1) = '0' and rightIn(REG_WIDTH-1) = '1' and checkOverflowTemp(REG_WIDTH-1) = '1')) else                           --CMP SIGNED
            srOlast when ALUInstr = "01111" else                                                                                                      --BITTEST
            srOlast when ALUInstr = "10000" else                                                                                                      --ADD without affecting SR
            srOlast when ALUInstr = "11111" else                                                                                                      --Let leftIn through
            srOlast when ALUInstr = "00000" else                                                                                                      --Do nothing
            '0';                                                                                                                                      --other cases    

   --set flags
   sRZ <= sRZInternal;
   sRN <= sRNInternal;
   sRC <= sRCInternal;
   sRO <= sROInternal;
   
   --set proper out         
   ALUOut <= temp(REG_WIDTH-1 downto 0);

   -- Set the values for the last cycle, so the SR-outs keep their values if unchanged.
   process (clk) is
   begin
      if rising_edge(clk) then
         srZlast <= sRZInternal;
         srNlast <= sRNInternal;
         srClast <= sRCInternal;
         srOlast <= sROInternal;
      end if;
   end process;
   
end Behavioural;
