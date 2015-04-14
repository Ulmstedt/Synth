library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity MUXbeforeALU is
   port(
      in1       :        in std_logic_vector(REG_WIDTH-1 downto 0);
      in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
      --IR2 måste kollas för styrsignalen
      IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

--special mux to handle storing of a constant
entity storeMUXBeforeZ3 is
   port(
      in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end storeMUXBeforeZ3;

architecture Behavourial of storeMUXBeforeZ3 is

begin
   --for STORE.c
   with IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) select
               --mask out the constant to be stored and let it through
      out1 <=  IR2(CONST_STORE_OFFSET downto 0) when "11000",
               --else whatever comes in from leftforward mux goes through
               in2 when others;      
end Behavourial;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

--Special mux to handle withoffset instructions, adress part is thought to be put through to the left inport of the ALU, this offset to the right
--also used for ALUINST.c where contents of register comes into left aluinport and the constant to the right inport
entity withOffSetMUX is
   port(
      --in1 unused in current form
      in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
      out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
      IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end withOffSetMUX;

architecture Behavourial of withOffSetMUX is

begin
   with IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH) select
               --STORE WO
               ----mask out the constant and let it through
      out1 <=  "00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH + 1) when "11010",
               --LOAD WO
               ----mask out the constant and let it through
               "00000"&IR2(WITH_OFFSET_OFFSET downto WITH_OFFSET_OFFSET - WITH_OFFSET_WIDTH + 1) when "11110",
               --special case
               --ALUINST.c
               IR2(CONST_STORE_OFFSET downto 0) when "00110",
               --else whatever comes in from leftforward mux goes through
               in2 when others;    
end Behavourial;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

--Forwarding muxes
entity leftForwardMUXALU is
   port(
         in1      :         in std_logic_vector(REG_WIDTH-1 downto 0);
         in2      :         in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3      :         in std_logic_vector(REG_WIDTH  - 1 downto 0);
         selectSig:         in std_logic_vector(1 downto 0);
         out1     :         out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end leftForwardMUXALU;

architecture Behavourial of leftForwardMUXALU is

begin
   out1  <= in3 when selectSig = "00" else
            in2 when selectSig = "01" else
            in1;
         
end Behavourial;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity rightForwardMUXALU is
   port(
         in1       :        in std_logic_vector(REG_WIDTH-1 downto 0);
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3       :        in std_logic_vector(REG_WIDTH  - 1 downto 0);
         selectSig:         in std_logic_vector(1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0)
   );
end rightForwardMUXALU;

architecture Behavourial of rightForwardMUXALU is

begin
   out1  <= in3 when selectSig = "00" else
            in2 when selectSig = "01" else
            in1;
         
end Behavourial;