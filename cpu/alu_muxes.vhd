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
      IR2               in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end MUXbeforeALU;

architecture Behavourial of MUXbeforeALU is
--interna signaler

begin
   --3 instruktioner som tar konstanter
   --STORE.c (constant) (specialfall där vi inte hade tillräckligt med bitar för adress och data)
   --11000 AAA AAAA AAAA DDDD DDDD DDDD DDDD
   --I detta fall så ordnas så att konstanten hamnar i Z3 via en extra mux, bara att låta adressen gå igenom i detta fall alltså som kommer från D2
   
   --LOAD.c
   --11101 RRRR RXX XXXX DDDD DDDD DDDD DDDD
   
   --ALUINST.c - stall
   --00110 OOOOO RRRR RX DDDD DDDD DDDD DDDD
   --Detta specialfall sköts via withOffSetMUX ty här ska konstanten komma in till ALUns högra inport
   
   --för LOAD: I fallen med offset i register behöver adressen gå igenom från D2 också, dessutom behöver adressen gå igenom när det gäller konstant offset
   --antar att i fallet wro att det läses direkt till A2, för fallet LOAD.a skall även där adressen gå igenom som antas ligga i D2
   
   --för STORE skall även här adressen gå igenom i alla fallen från D2
   
   --vid MOVE antas src komma från B2
   
   -- vid ALIINST.r antas DEST komma från B2 och SRC från A2
   with IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) select
               -- alla stores
      out1 <=  in1 when "11000",
               in1 when "11001",
               in1 when "11010",
               in1 when "11011",
               --alla loads
               in1 when "11100",
               in1 when "11101",
               in1 when "11110",
               in1 when "11111",
               in2 when others;                
end Behavourial;

--special mux to handle storing of a constant
entity storeMUXBeforeZ3 is
   port(
      --in1 unused in current form
      in1               in std_logic_vector(REG_WIDTH-1 downto 0);
      in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1              out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2               in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end storeMUXBeforeZ3;

architecture Behavourial of storeMUXBeforeZ3 is

begin
   --for STORE.c
   if IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11000" then
      --mask out the constant to be stored and let it through
      out1 <= IR2(CONST_STORE_OFFSET downto 0);
   else
      --else whatever comes in from leftforward mux goes through
      out1 <= in2;
      
end Behavourial;

--Special mux to handle withoffset instructions, adress part is thought to be put through to the left inport of the ALU, this offset to the right
--also used for ALUINST.c where contents of register comes into left aluinport and the constant to the right inport
entity withOffSetMUX is
   port(
      --in1 unused in current form
      in1               in std_logic_vector(REG_WIDTH-1 downto 0);
      in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1              out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2               in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end withOffSetMUX;

architecture Behavourial of withOffSetMUX is

begin
   --STORE WO
   if IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11010" then
      --mask out the constant and let it through
      out1 <= "00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH + 1);
   --LOAD WO
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11110" then
      --mask out the constant and let it through
      out1 <= "00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH + 1);
   --ALUINST.c
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
      out1 <= IR2(CONST_STORE_OFFSET downto 0);
   else
      out1 <= in2;
end Behavourial;


--Forwarding muxes and logic for them
entity leftForwardMUXALU is
   port(
         in1               in std_logic_vector(REG_WIDTH-1 downto 0);
         in2               in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3               in std_logic_vector(REG_WIDTH  - 1 downto 0);
         IR2               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR3               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR4               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         out1              out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end leftForwardMUXALU;

architecture Behavourial of leftForwardMUXALU is
   signal store_Read_Reg : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg   : std_logic_vector(REG_BITS-1 downto 0);

begin
   store_Read_Reg <= IR2(READ_REG_OFFSET downto READ_REG_OFFSET-REG_BITS+1);
   ALU_Read_Reg <= IR2(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
    
    
   --if STORE.r
   if IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11001" then
      --if LOAD IR3
      -- LOAD.a kräver en stall, så här kan värdet som värst endast ligga i steg 4 (efter 1 stall)
      -- LOAD.c så kan reg värdet ligga i steg 3-4
      -- LOAD.wo kräver också en stall så värdet kan ligga i steg 4 men inte 3
      -- LOAD.wro samma sak, kräver stall och värdet kan som värst ligga i steg 4
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3
      -- vid MOVE kan värdet ligga i steg 3 eller 4
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
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
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11010" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
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
      
   --STORE.wofr IR2
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11011" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
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
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = read_Reg then
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
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "10101" or IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "10110" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal B2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = ALU_Read_Reg then
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
         IR2               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR3               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         IR4               in std_logic_vector(REG_WIDTH*2-1 downto 0);
         out1              out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end rightForwardMUXALU;

architecture Behavourial of rightForwardMUXALU is

   signal store_Read_Reg : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg   : std_logic_vector(REG_BITS-1 downto 0);
   signal load_Read_Reg  : std_logic_vector(REG_BITS-1 downto 0);

begin
   --notice difference from left forward MUX, here we check if src register has been modified and is in the pipeline
   
   store_Read_Reg <= IR2(STORE_WOFR_OFFSET downto STORE_WOFR_OFFSET-REG_BITS+1);
   ALU_Read_Reg <= IR2(ALU_SRC_REG_OFFSET downto ALU_SRC_REG_OFFSET-REG_BITS+1);
   load_Read_Reg <= IR2(LOAD_WRO_OFFSET downto LOAD_WRO_OFFSET-REG_BITS+1);
        
   --STORE.wofr IR2 
   --kolla om registret innehållande offset ligger i pipelinen
   if IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "11011" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --så måste forwarda vad som skall finnas i registret innehållande offseten
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = store_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = store_Read_Reg then
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
   --kolla om src registret ligger i pipelinen
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "10101" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = ALU_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = ALU_Read_Reg then
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
   elsif IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "10101" then
      --if LOAD IR3
      if IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR3   
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR3
      elsif IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = load_Read_Reg then
            --out is set to D3out
            out1 <= in3;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if LOAD IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_LOAD) = "111" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = load_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if MOVE IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00100" then
         if IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1) = load_Read_Reg then
            --out is set to Z4/D4out
            out1 <= in2;
         else 
         --else normal A2_out through
            out1 <= in1;
         end if;
      --if ALUINST.r or ALUINST.c IR4
      elsif IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00101" or IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) = "00110" then
         if IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1) = load_Read_Reg then
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