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
   
   --kolla om IR2Op är en ALU instr ty det ger "specialfall"
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
                        
   --Kolla IR3 om det är möjligt om det är en instruktion som kan förändra register, givetvis måste även possibleForward vara 1 kollar också om det finns registerberoende
   --Intsruktioner som skall kollas:
   --LOAD.a, LOAD.c, LOAD.wo, LOAD.wro, MOVE, ALUINST.r eller ALUINST.c
   --and not(IR2OP = "00101" or IR2OP = "00110") och and(IR2OP = "00101" or IR2OP = "00110") är fallen då det rör sig om ALU instr, eftersom det är de enda fallen där dest. reg
   --skiljer sig på vilka bitar som hör till den så måste detta specialfall göras
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
                           
   --kollar även IR4 men bara om IR3 inte ändrade registret
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
                           
   --Nu återstår att kolla om vi har registerberoende i IR3 och har vi det så skall selectSignal sättas till 00
   --Har vi registerberoende i IR4 så skall selectSignal sättas till 01
   --Har vi ej reg. beroende så sätts selectSignal till 1Z
   --I fallen då registervärdet ligger i steg 4 kollas också att det inte är beroende i steg 3 redan för då bör vi redan ha forwardat det som nu ligger i steg 4 vid förra klockcykeln för det var isåfall beroende mellan vad
   --som då fanns i steg 2 och steg 3 men nu ligger i steg 3 och 4.
   --Gör i varje koll också samma koll för OP på både IR3 och IR4 som gjordes för att sätta changeInIR3, dvs att
   --Intsruktioner som kollas är
   --LOAD.a, LOAD.c, LOAD.wo, LOAD.wro, MOVE, ALUINST.r eller ALUINST.c
   selectSignal            <= "00" when changeInIR3 = '1' else                
                              "01" when changeInIR4 = '1' else                       
                              "1-";
end Behavourial;
