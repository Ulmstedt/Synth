library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity MUXbeforeALU is
   port(
      in1               in std_logic_vector(REG_WIDTH-1 downto 0);
      in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1              out std_logic_vector(REG_WIDTH - 1 downto 0);
      --IR2 måste kollas för styrsignalen
      IR2               in std_logic_vector(REG_WIDTH-1 downto 0)
   );
end MUXbeforeALU;

architecture Behavourial of MUXbeforeALU is
--interna signaler

begin
   --3 instruktioner som tar konstanter
   --STORE.c (constant) (specialfall där vi inte hade tillräckligt med bitar för adress och data)
   --11000 AAA AAAA AAAA DDDD DDDD DDDD DDDD
   
   --LOAD.c
   --11101 RRRR RXX XXXX DDDD DDDD DDDD DDDD
   
   --ALUINST.c - stall
   --00110 OOOOO RRRR RX DDDD DDDD DDDD DDDD
   with IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) select
      out1 <=  in1 when "11000",
               in1 when "11101",
               in1 when "00110",
               in2 when others;                
end Behavourial;

--special mux to handle storing of a constant
entity storeMUXBeforeZ3 is
   port(
      --in1 unused in current form
      in1               in std_logic_vector(REG_WIDTH-1 downto 0);
      in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1              out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2               in std_logic_vector(REG_WIDTH-1 downto 0)
   );
end storeMUXBeforeZ3;

architecture Behavourial of storeMUXBeforeZ3 is

begin
   if IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11000" then
      --mask out the constant to be stored and let it through
      out1 <= "00000000"&"00000000"&IR2(REG_WITDH/2 - 1 downto 0);
   else
      out1 <= in2;
      
end Behavourial;

--Special mux to handle withoffset instructions
entity withOffSetMUX is
   port(
      --in1 unused in current form
      in1               in std_logic_vector(REG_WIDTH-1 downto 0);
      in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1              out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2               in std_logic_vector(REG_WIDTH-1 downto 0)
   );
end withOffSetMUX;

architecture Behavourial of withOffSetMUX is

begin
   --STORE WO
   if IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11010" then
      --mask out the constant and let it through
      out1 <= "00000000"&"00000000"&"00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH);
   --LOAD WO
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11110" then
      --mask out the constant and let it through
      out1 <= "00000000"&"00000000"&"00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH);
   else
      out1 <= in2;
end Behavourial;


--Forwarding muxes and logic for them
--Det finns ett problem med LOAD.a instruktionen ty värdet som ska läggas i registret finns inte i pipelinen förrän steg 4 i pipelinen, med andra ord kan man t e x inte göra såhär:
-- LOAD.a Reg0, 0x00000004
-- ADDuns Reg0, Reg1
-- vad som fungerar dock är att lägga in en nop mellan dessa rader
-- vad som borde hända just nu om man skriver kod som exemplet är att man adderar 0x00000004 med värdet i reg1
entity leftForwardMUXALU is
   port(
         in1               in std_logic_vector(REG_WIDTH-1 downto 0);
         in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3               in std_logic_vector(REG_WIDTH  - 1 downto 0);
         IR2               in std_logic_vector(REG_WIDTH-1 downto 0);
         IR3               in std_logic_vector(REG_WIDTH-1 downto 0);
         IR4               in std_logic_vector(REG_WIDTH-1 downto 0);
         out1              out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end leftForwardMUXALU;

architecture Behavourial of leftForwardMUXALU is
   signal store_Read_Reg : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg   : std_logic_vector(REG_BITS-1 downto 0);

begin
   store_Read_Reg <= IR2(READ_REG_OFFSET downto READ_REG_OFFSET-REG_BITS);
   ALU_Read_Reg <= IR2(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS);
    
    
   --if STORE.r
   if IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11001" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      else 
         --else normal B2_out through
         out1 <= in1;
      end if;
      
   --STORE.wo IR2
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11010" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      else 
         --else normal B2_out through
         out1 <= in1;
      end if;
      
   --STORE.wofr IR2 KOLLA IGENOM DENNA IGEN
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11011" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      else 
         --else normal B2_out through
         out1 <= in1;
      end if;
      
   --MOVE IR2
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      else 
         --else normal B2_out through
         out1 <= in1;
      end if;
      
   --if IR2 ALUINST.r or ALUINST.c
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "10101" or IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "10110" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      else 
         --else normal B2_out through
         out1 <= in1;
      end if;      
   --else no forwarding   
   else
      --else normal B2_out through
      out1 <= in1;
   end if;
end Behavourial;

entity rightForwardMUXALU is
   port(
         in1               in std_logic_vector(REG_WIDTH-1 downto 0);
         in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3               in std_logic_vector(REG_WIDTH  - 1 downto 0);
         IR2               in std_logic_vector(REG_WIDTH-1 downto 0);
         IR3               in std_logic_vector(REG_WIDTH-1 downto 0);
         IR4               in std_logic_vector(REG_WIDTH-1 downto 0);
         out1              out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end rightForwardMUXALU;

architecture Behavourial of rightForwardMUXALU is

   signal store_Read_Reg : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg   : std_logic_vector(REG_BITS-1 downto 0);
   signal load_Read_Reg  : std_logic_vector(REG_BITS-1 downto 0);

begin
   store_Read_Reg <= IR2(STORE_WOFR_OFFSET downto STORE_WOFR_OFFSET-REG_BITS);
   ALU_Read_Reg <= IR2(ALU_SRC_REG_OFFSET downto ALU_SRC_REG_OFFSET-REG_BITS);
   load_Read_Reg <= IR2(LOAD_WRO_OFFSET downto LOAD_WRO_OFFSET-REG_BITS);
        
   --STORE.wofr IR2 KOLLA IGENOM DENNA IGEN
   if IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "11011" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --så måste forwarda vad som skall finnas i registret innehållande offseten
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = store_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      else 
         --else normal A2_out through
         out1 <= in1;
      end if;
      
   --if IR2 ALUINST.r
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "10101" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      else 
         --else normal A2_out through
         out1 <= in1;
      end if;
      
   --if LOAD.wro måste kolla om registret innehållande konstanten ligger i pipelinen
   elsif IR2(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "10101" then
      --if LOAD IR3
      if IR3(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR3(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00101" or IR4(REG_WIDTH-1 downto REG_WIDTH-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_REG_DEST_OFFSET-REG_BITS) = load_Read_Reg then
            --out is set to D3out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      else 
         --else normal A2_out through
         out1 <= in1;
      end if;
   --else no forwarding   
   else
      --else normal A2_out through
      out1 <= in1;
   end if;
end Behavourial;