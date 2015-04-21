--right forwardingmux logic
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Constants.all;

--notice difference from left forward MUX logic, here we check if src register has been modified and is in the pipeline
entity forwardLogicRight is
   port(
      IR2            :   in std_logic_vector(REG_WIDTH*2 - 1 downto 0);
      IR3            :   in std_logic_vector(REG_WIDTH*2 - 1 downto 0);
      IR4            :   in std_logic_vector(REG_WIDTH*2 - 1 downto 0);     
      selectSignal   :   out std_logic_vector(1 downto 0)
   );
end forwardLogicRight;

--so there will be 4 cases
-- selectSignal: XX
-- 00 => D3_Out goes through
-- 01 => Z4/D4_Out goes through
-- 1Z => A2_Out goes through

architecture Behavourial of forwardLogicRight is
   signal store_Read_Reg      : std_logic_vector(REG_BITS-1 downto 0);
   signal ALU_Read_Reg        : std_logic_vector(REG_BITS-1 downto 0);
   signal load_Read_Reg       : std_logic_vector(REG_BITS-1 downto 0);
   
   signal changeInIR3         : std_logic;
   signal changeInIR4         : std_logic;
   
   signal IR2OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   signal IR3OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   signal IR4OP               : std_logic_vector(OP_WIDTH-1 downto 0);
   
   signal IR3DestReg          : std_logic_vector(REG_BITS-1 downto 0);
   signal IR3DestRegALU       : std_logic_vector(REG_BITS-1 downto 0);
   signal IR4DestReg          : std_logic_vector(REG_BITS-1 downto 0);
   signal IR4DestRegALU       : std_logic_vector(REG_BITS-1 downto 0);
   
   signal IR3ALUInstr               : std_logic_vector(ALU_INSTR_WIDTH-1 downto 0);
   signal isIR3ALUInstrAndNoChange  : std_logic;
   
   signal IR4ALUInstr               : std_logic_vector(ALU_INSTR_WIDTH-1 downto 0);
   signal isIR4ALUInstrAndNoChange  : std_logic;
   
begin
   store_Read_Reg <= IR2(STORE_WOFR_OFFSET downto STORE_WOFR_OFFSET-REG_BITS+1);
   ALU_Read_Reg <= IR2(ALU_SRC_REG_OFFSET downto ALU_SRC_REG_OFFSET-REG_BITS+1);
   load_Read_Reg <= IR2(LOAD_WRO_OFFSET downto LOAD_WRO_OFFSET-REG_BITS+1);
   
   IR2OP <= IR2(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   
   IR3OP <= IR3(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   IR3DestReg <= IR3(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1);
   IR3DestRegALU <= IR3(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
   
   IR4OP <= IR4(REG_WIDTH*2-1 downto REG_WIDTH*2-OP_WIDTH);
   IR4DestReg <= IR4(REG_DEST_OFFSET downto REG_DEST_OFFSET-REG_BITS+1);
   IR4DestRegALU <= IR4(ALU_DEST_REG_OFFSET downto ALU_DEST_REG_OFFSET-REG_BITS+1);
   
   IR3ALUInstr <= IR3(ALU_INSTR_OFFSET downto ALU_INSTR_OFFSET-ALU_INSTR_WIDTH+1);
   IR4ALUInstr <= IR4(ALU_INSTR_OFFSET downto ALU_INSTR_OFFSET-ALU_INSTR_WIDTH+1);
   
   --Kolla IR2 om OP
   --STORE.wofr, ALUINST.r eller LOAD.wor
   --Detta eftersom i alla dessa görs läsning från ett register innehållande ett värde som kan ligga någonstans i pipelinen, det vi gör här är generellt att kolla om src registret modifierats och ligger i pipelinen
   --och måste då givetvis forwardas
   
   --kolla om det rör sig om Do nothing, CMP unsigned, CMP signed eller BITTEST vid ALU INSTRUKTIONER
   isIR3ALUInstrAndNoChange   <= '1' when IR3OP = "00101" and (IR3ALUInstr = "00000" or IR3ALUInstr = "01100" or IR3ALUInstr = "01101" or IR3ALUInstr = "01111") else
                                 '1' when IR3OP = "00110" and (IR3ALUInstr = "00000" or IR3ALUInstr = "01100" or IR3ALUInstr = "01101" or IR3ALUInstr = "01111") else
                                 '0';
                                 
   isIR4ALUInstrAndNoChange   <= '1' when IR4OP = "00101" and (IR4ALUInstr = "00000" or IR4ALUInstr = "01100" or IR4ALUInstr = "01101" or IR4ALUInstr = "01111") else
                                 '1' when IR4OP = "00110" and (IR4ALUInstr = "00000" or IR4ALUInstr = "01100" or IR4ALUInstr = "01101" or IR4ALUInstr = "01111") else
                                 '0';
                        
   --Kolla IR3 om det är möjligt om det är en instruktion som kan förändra register, givetvis måste även possibleForward vara 1 kollar också om det finns registerberoende
   --Intsruktioner som skall kollas:
   --LOAD.a, LOAD.c, LOAD.wo, LOAD.wro, MOVE, ALUINST.r eller ALUINST.c
   --eftersom en del ALU instr. inte ändrar i registren och ALUn skickar ut tidigare utvärdet i dessa fall så ska dessa inte muxas ut alltså: ALU instruktioner som inte ändrar i register:
   --Do nothing, CMP(unsigned och signed), BITTEST
   changeInIR3             <= '1' when IR3OP = "11100" and IR3DestReg = store_Read_Reg and IR2OP = "11011" else
                              '1' when IR3OP = "11101" and IR3DestReg = store_Read_Reg and IR2OP = "11011" else 
                              '1' when IR3OP = "11110" and IR3DestReg = store_Read_Reg and IR2OP = "11011" else
                              '1' when IR3OP = "11111" and IR3DestReg = store_Read_Reg and IR2OP = "11011" else
                              '1' when IR3OP = "00100" and IR3DestReg = store_Read_Reg and IR2OP = "11011" else
                              '1' when IR3OP = "00101" and IR3DestRegALU = store_Read_Reg and IR2OP = "11011" and isIR3ALUInstrAndNoChange = '0' else
                              '1' when IR3OP = "00110" and IR3DestRegALU = store_Read_Reg and IR2OP = "11011" and isIR3ALUInstrAndNoChange = '0' else
                           
                              '1' when IR3OP = "11100" and IR3DestReg = ALU_Read_Reg and IR2OP = "00101" else
                              '1' when IR3OP = "11101" and IR3DestReg = ALU_Read_Reg and IR2OP = "00101" else 
                              '1' when IR3OP = "11110" and IR3DestReg = ALU_Read_Reg and IR2OP = "00101" else
                              '1' when IR3OP = "11111" and IR3DestReg = ALU_Read_Reg and IR2OP = "00101" else
                              '1' when IR3OP = "00100" and IR3DestReg = ALU_Read_Reg and IR2OP = "00101" else
                              '1' when IR3OP = "00101" and IR3DestRegALU = ALU_Read_Reg and IR2OP = "00101" and isIR3ALUInstrAndNoChange = '0' else
                              '1' when IR3OP = "00110" and IR3DestRegALU = ALU_Read_Reg and IR2OP = "00101" and isIR3ALUInstrAndNoChange = '0' else
                           
                              '1' when IR3OP = "11100"  and IR3DestReg = load_Read_Reg and IR2OP = "11111" else
                              '1' when IR3OP = "11101"  and IR3DestReg = load_Read_Reg and IR2OP = "11111" else 
                              '1' when IR3OP = "11110"  and IR3DestReg = load_Read_Reg and IR2OP = "11111" else
                              '1' when IR3OP = "11111"  and IR3DestReg = load_Read_Reg and IR2OP = "11111" else
                              '1' when IR3OP = "00100"  and IR3DestReg = load_Read_Reg and IR2OP = "11111" else
                              '1' when IR3OP = "00101"  and IR3DestRegALU = load_Read_Reg and IR2OP = "11111" and isIR3ALUInstrAndNoChange = '0' else
                              '1' when IR3OP = "00110"  and IR3DestRegALU = load_Read_Reg and IR2OP = "11111" and isIR3ALUInstrAndNoChange = '0' else
                              '0';
                           
   --kollar även IR4 och återigen behöver inte hämta det som finns i steg 4 om det finns beroende mellan steg 2 och 4
   
   changeInIR4             <= '1' when IR4OP = "11100" and IR4DestReg = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" else
                              '1' when IR4OP = "11101" and IR4DestReg = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" else 
                              '1' when IR4OP = "11110" and IR4DestReg = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" else
                              '1' when IR4OP = "11111" and IR4DestReg = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" else
                              '1' when IR4OP = "00100" and IR4DestReg = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" else
                              '1' when IR4OP = "00101" and IR4DestRegALU = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" and isIR4ALUInstrAndNoChange = '0' else
                              '1' when IR4OP = "00110" and IR4DestRegALU = store_Read_Reg and changeInIR3 = '0' and IR2OP = "11011" and isIR4ALUInstrAndNoChange = '0' else
                           
                              '1' when IR4OP = "11100" and IR4DestReg = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" else
                              '1' when IR4OP = "11101" and IR4DestReg = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" else 
                              '1' when IR4OP = "11110" and IR4DestReg = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" else
                              '1' when IR4OP = "11111" and IR4DestReg = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" else
                              '1' when IR4OP = "00100" and IR4DestReg = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" else
                              '1' when IR4OP = "00101" and IR4DestRegALU = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" and isIR4ALUInstrAndNoChange = '0' else
                              '1' when IR4OP = "00110" and IR4DestRegALU = ALU_Read_Reg and changeInIR3 = '0' and IR2OP = "00101" and isIR4ALUInstrAndNoChange = '0' else
                           
                              '1' when IR4OP = "11100"  and IR4DestReg = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" else
                              '1' when IR4OP = "11101"  and IR4DestReg = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" else 
                              '1' when IR4OP = "11110"  and IR4DestReg = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" else
                              '1' when IR4OP = "11111"  and IR4DestReg = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" else
                              '1' when IR4OP = "00100"  and IR4DestReg = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" else
                              '1' when IR4OP = "00101"  and IR4DestRegALU = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" and isIR4ALUInstrAndNoChange = '0' else
                              '1' when IR4OP = "00110"  and IR4DestRegALU = load_Read_Reg and changeInIR3 = '0' and IR2OP = "11111" and isIR4ALUInstrAndNoChange = '0' else
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
