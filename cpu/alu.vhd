
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

architecture Behavioural of ALU is
   variable reg  : std_logic_vector(2*REG_WIDTH-1 down to 0);
   
   variable right : integer;  
   variable left  : integer;
   variable tmp   : std_logic_vector(2*REG_WIDTH-1 down to 0);
   
begin 
   process (clk)
   begin
      if rising_edge(clk) then
         case(ALU_instr) is
            when (00001) =>
               --ADD unsigned
               reg <= std_logic_vector(unsigned(right_In) + unsigned(left_In));
            when (00010) =>
               --ADD signed
               reg <= std_logic_vector(signed(right_In) + signed(left_In));
            when (00011) =>
               --SUB unsigned
               reg <= std_logic_vector(unsigned(right_In) - unsigned(left_In));
            when (00100) =>
               --SUB signed
               reg <= std_logic_vector(signed(right_In) - signed(left_In));
            when (00101) =>
               --MUL (signed fixed point)
               
               --convert to integers
               right := to_integer(signed(right_In)));  
               left := to_integer(signed(left_In)));
               --convert the result of these to a std_logic_vector of size 32 bits
               tmp <= std_logic_vector(to_signed(right*left, 2*REG_WIDTH));
               --put 16 highest bits from tmp into reg
               reg(REG_WIDTH-1 down to 0) <= tmp(2*REG_WIDTH-1 down to REG_WIDTH);
               --fill rest of reg with 0's, possibly unnecessarily
               reg(2*REG_WIDTH-1 down to REG_WIDTH) <= "00000000";
               
            when(00110) =>
               --bitshift right
            when(00111) =>
               --bitshift left
            when(01000) =>
               --AND
            when(01001) =>
               --OR
            when(01010) =>
               --XOR
            when(01011) =>
               --NOT
            when(01100) =>
               --EQUAL
            when(01101) =>
               --LESS THAN
            when(01110) =>
               --MORE THAN
            when(01111) =>
               --BITTEST
            when others
               --do nothing and others
               null;
         end case;
      end if;
   end process;
   --set status reg
   sr_Z <= '1' when reg(REG_WIDTH-1 downto 0) = 0 else '0';
end Behavioural;