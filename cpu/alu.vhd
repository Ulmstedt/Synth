
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.types.all;
use work.constants.all;

entity ALU is
   port(
      left_In  : in std_logic_vector(REG_WIDTH-1 downto 0);
      right_In : in std_logic_vector(REG_WIDTH-1 downto 0);
      alu_Out  : out std_logic_vector(REG_WIDTH-1 down to 0);
      ALU_instr  : in std_logic_vector(4 down to 0);
      
      clk      : in std_logic;
      
      sr_Z     : out std_logic;
      sr_N     : out std_logic;
      sr_O     : out std_logic;
      sr_C     : out std_logic;
   );
end ALU;

--ALUINST.r
--00101 OOOOO RRRR X XXXX XXXX XXXX RRRR

--ALUINST.c
--00110 OOOOO RRRR X DDDD DDDD DDDD DDDD

--First register will be put into right_In, second reg or constant will be put in left_In

--carry flag is only of importance for unsigned arithmetic
--overflow flag is only of importance for signed arithmetic
--so will not care about those other cases

architecture Behavioural of ALU is
   variable reg  : std_logic_vector(2*REG_WIDTH-1 down to 0);
   
   variable tmp   : std_logic_vector(2*REG_WIDTH-1 down to 0);
   
   signal set_Z   : std_logic;
   signal set_N   : std_logic;
   signal set_C   : std_logic;
   signal set_O   : std_logic;   
   
begin 
   process (clk)
   begin
      if rising_edge(clk) then
         case(ALU_instr) is
            when (00001) =>
               --ADD unsigned
               reg <= std_logic_vector(unsigned(right_In) + unsigned(left_In));
               
               if to_integer(unsigned(reg)) = 0 then
                  set_Z <= '1';
               end if;
               
               if reg(REG_WIDTH) = '1' then
                  set_C <= '1';
               end if;
                  
            when (00010) =>
               --ADD signed
               reg <= std_logic_vector(signed(right_In) + signed(left_In));
               
               if to_integer(signed(reg)) = 0 then
                  set_Z <= '1';
               end if;
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  set_N <= '1';
               end if;
               --if the sum of two operands both with sign bit on results in a number with sign bit off we set overflow
               --do same if two operands with sign bit off results in a number with sign bit on we have overflow
               if (right_In(REG_WIDTH-1) = '1' and left_In(REG_WIDTH-1) = '1' and reg(REG_WIDTH-1) = '0') or
                  (right_In(REG_WIDTH-1) = '0' and left_In(REG_WIDTH-1) = '0' and reg(REG_WIDTH-1) = '1') then
                     set_O <= '1';
               end if;
            when (00011) =>
               --SUB unsigned
               reg <= std_logic_vector(unsigned(right_In) - unsigned(left_In));
               
               --makes no sense checking if negative flag should be set when dealing with unsigned
               if to_integer(unsigned(reg)) = 0 then
                  set_Z <= '1';
               end if;
               --revise this one
               if reg(REG_WIDTH) = '1' then
                  set_C <= '1';
               end if;
            when (00100) =>
               --SUB signed
               reg <= std_logic_vector(signed(right_In) - signed(left_In));
               if to_integer(signed(reg)) = 0 then
                  set_Z <= '1';
               end if;
               --check signbit
               if reg(REG_WIDTH-1) = '1' then
                  set_N <= '1';
               end if;
               --STOPPED HERE
               --if the sum of two operands both with sign bit on results in a number with sign bit off we set overflow
               --do same if two operands with sign bit off results in a number with sign bit on we have overflow
               if (right_In(REG_WIDTH-1) = '1' and left_In(REG_WIDTH-1) = '1' and reg(REG_WIDTH-1) = '0') or
                  (right_In(REG_WIDTH-1) = '0' and left_In(REG_WIDTH-1) = '0' and reg(REG_WIDTH-1) = '1') then
                     set_O <= '1';
               end if;
            when (00101) =>
               --MUL (signed fixed point)
               --convert the product of these to a std_logic_vector of size 32 bits
               tmp <= std_logic_vector(to_signed(to_integer(signed(right_In)))*to_integer(signed(left_In))), 2*REG_WIDTH));
               --put 16 highest bits from tmp into reg
               reg(REG_WIDTH-1 down to 0) <= tmp(2*REG_WIDTH-1 down to REG_WIDTH);
               --fill rest of reg with 0's, possibly unnecessarily
               reg(2*REG_WIDTH-1 down to REG_WIDTH) <= "00000000";
               
            when(00110) =>
               --bitshift right
               reg <= right_In srl to_integer(left_In);
            when(00111) =>
               --bitshift left
               reg <= right_In sll to_integer(left_In);
            when(01000) =>
               --AND
               reg <= right_In and left_In;
            when(01001) =>
               --OR
               reg <= right_In or left_In;
            when(01010) =>
               --XOR
               reg <= right_In xor left_In;
            when(01011) =>
               --NOT
               reg <= not right_In
            when(01100) =>
               --CMP
               if right_In = left_In then
                  --if they are equal 
                  set_Z <= '1';
               elsif right_In < left_In then
                  --if rx < ry or rx < const we put a 1 on the most significant bit of reg
                  set_N <= '1';
               elsif right_In > left_In then
                  set_N <= '0';
               end if;
            when(01111) =>
               --BITTEST
               if to_integer(to_unsigned(left_In)>=REG_WIDTH or to_integer(to_unsigned(left_In)>=REG_WIDTH < 0 then
                  --guard against bad usage
                  null;
               elsif right_In(to_integer(to_unsigned(left_In))) = '0' then
                  set_Z <= '1';
               else
                  set_Z <= '0';
               end if;  
            when others =>
               --do nothing and others
               null;
         end case;
      end if;
   end process;
   
   --set proper out
   alu_Out <= reg;
   
   --set status reg
   if set_Z = '1' then
      sr_Z <= '1';
      set_Z <= '0';
   else
      sr_Z <= '0';
   end if;
   
   if set_N = '1' then
      sr_N <= '1';
      set_N <= '0';
   else
      sr_N <= '0';
   end if;
   
   if set_O = '1' then
      sr_O <= '1';
      set_O <= '0';
   else 
      sr_O <= '0';
   end if;
   
   if set_C = '1' then
      sr_C <= '1';
      set_C <= '0';
   else
      sr_C <= '0';
   end if;
end Behavioural;