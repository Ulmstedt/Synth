--left forwarding logic
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

entity forwardLogicLeft is
   port(
      IR2            :   in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR3            :   in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR4            :   in std_logic_vector(REG_WIDTH*2-1 downto 0);     
      selectSignal   :   out std_logic_vector(1 downto 0)
   );
end forwardLogicLeft;

--so there will be 4 cases
-- selectSignal: XX
-- 00 => D3_Out goes through
-- 01 => Z4/D4_Out goes through
-- 1Z => B2_Out goes through

architecture Behavourial of forwardLogicLeft is
   signal store_Read_Reg      : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg        : std_logic_vector(REG_BITS-1 downto 0);
   
   signal possibleForward     : std_logic;
   signal changeInIR3         : std_logic;
   signal changeInIR4         : std_logic;
   signal isIR2ALUinstr       : std_logic;
  
   signal IR2OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   signal IR3OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   signal IR4OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   
   signal IR3DestReg          : std_logic_vector(REG_BITS-1 downto 0);
   signal IR3DestRegALU       : std_logic_vector(REG_BITS-1 downto 0);
   signal IR4DestReg          : std_logic_vector(REG_BITS-1 downto 0);
   signal IR4DestRegALU       : std_logic_vector(REG_BITS-1 downto 0);
   
begin
   store_Read_Reg <= IR2(READ_REG_OFFSET downto READ_REG_OFFSET-REG_BITS+1);
   ALU_Read_Reg <= IR2(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
   
   IR2OP <= IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   
   IR3OP <= IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   IR3DestReg <= IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1);
   IR3DestRegALU <= IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
   
   IR4OP <= IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   IR4DestReg <= IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1);
   IR4DestRegALU <= IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
   
   --kolla om IR2Op �r en ALU instr ty det ger "specialfall"
   with IR2OP select isIR2ALUinstr  <= 
               '1' when "00101",
               '1' when "00110",
               '0' when others;
                  
   --Kolla IR2 om OP
   --STORE.r, STORE.wo, STORE.wofr, MOVE, ALUINST.r eller ALUINST.c
   with IR2OP select possibleForward   <= 
               '1' when "11001",
               '1' when "11010",
               '1' when "11011",
               '1' when "00100",
               '1' when "00101",
               '1' when "00110",
               '0' when others;
                        
   --Kolla IR3 om det �r m�jligt om det �r en instruktion som kan f�r�ndra register, givetvis m�ste �ven possibleForward vara 1 kollar ocks� om det finns registerberoende
   --Intsruktioner som skall kollas:
   --LOAD.a, LOAD.c, LOAD.wo, LOAD.wro, MOVE, ALUINST.r eller ALUINST.c
   --and not(IR2OP = "00101" or IR2OP = "00110") och and(IR2OP = "00101" or IR2OP = "00110") �r fallen d� det r�r sig om ALU instr, eftersom det �r de enda fallen d�r dest. reg
   --skiljer sig p� vilka bitar som h�r till den s� m�ste detta specialfall g�ras
   changeInIR3             <= '1' when IR3OP = "11100" and possibleForward = '1' and IR3DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR3OP = "11101" and possibleForward = '1' and IR3DestReg = store_Read_Reg and isIR2ALUinstr = '0' else 
                              '1' when IR3OP = "11110" and possibleForward = '1' and IR3DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR3OP = "11111" and possibleForward = '1' and IR3DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR3OP = "00100" and possibleForward = '1' and IR3DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR3OP = "00101" and possibleForward = '1' and IR3DestRegALU = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR3OP = "00110" and possibleForward = '1' and IR3DestRegALU = store_Read_Reg and isIR2ALUinstr = '0' else
                           
                              '1' when IR3OP = "11100" and possibleForward = '1' and IR3DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR3OP = "11101" and possibleForward = '1' and IR3DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else 
                              '1' when IR3OP = "11110" and possibleForward = '1' and IR3DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR3OP = "11111" and possibleForward = '1' and IR3DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR3OP = "00100" and possibleForward = '1' and IR3DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR3OP = "00101" and possibleForward = '1' and IR3DestRegALU = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR3OP = "00110" and possibleForward = '1' and IR3DestRegALU = ALU_Read_Reg and isIR2ALUinstr = '1' else
                           
                              '0';
                           
   --kollar �ven IR4 men bara om IR3 inte �ndrade registret
   changeInIR4             <= '1' when IR4OP = "11100" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "11101" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "11110" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "11111" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "00100" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "00101" and possibleForward = '1' and changeInIR3 = '0' and IR4DestRegALU = store_Read_Reg and isIR2ALUinstr = '0' else
                              '1' when IR4OP = "00110" and possibleForward = '1' and changeInIR3 = '0' and IR4DestRegALU = store_Read_Reg and isIR2ALUinstr = '0' else
                           
                              '1' when IR4OP = "11100" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "11101" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "11110" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "11111" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "00100" and possibleForward = '1' and changeInIR3 = '0' and IR4DestReg = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "00101" and possibleForward = '1' and changeInIR3 = '0' and IR4DestRegALU = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '1' when IR4OP = "00110" and possibleForward = '1' and changeInIR3 = '0' and IR4DestRegALU = ALU_Read_Reg and isIR2ALUinstr = '1' else
                              '0';
                           
   --Nu �terst�r att kolla om vi har registerberoende i IR3 och har vi det s� skall selectSignal s�ttas till 00
   --Har vi registerberoende i IR4 s� skall selectSignal s�ttas till 01
   --Har vi ej reg. beroende s� s�tts selectSignal till 1Z
   --I fallen d� registerv�rdet ligger i steg 4 kollas ocks� att det inte �r beroende i steg 3 redan f�r d� b�r vi redan ha forwardat det som nu ligger i steg 4 vid f�rra klockcykeln f�r det var is�fall beroende mellan vad
   --som d� fanns i steg 2 och steg 3 men nu ligger i steg 3 och 4.
   --G�r i varje koll ocks� samma koll f�r OP p� b�de IR3 och IR4 som gjordes f�r att s�tta changeInIR3, dvs att
   --Intsruktioner som kollas �r
   --LOAD.a, LOAD.c, LOAD.wo, LOAD.wro, MOVE, ALUINST.r eller ALUINST.c
   selectSignal            <= "00" when changeInIR3 = '1' else                
                              "01" when changeInIR4 = '1' else                       
                              "1-";
end Behavourial;
