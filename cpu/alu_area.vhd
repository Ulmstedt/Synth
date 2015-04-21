library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity ALUArea is
   port(
      ALUOut  :  out std_logic_vector(REG_WIDTH - 1 downto 0);
      Z3in    :  out std_logic_vector(REG_WIDTH - 1 downto 0);
      sRZ     :  out std_logic;
      sRN     :  out std_logic;
      sRO     :  out std_logic;
      sRC     :  out std_logic;
      D2Out   :  in std_logic_vector(REG_WIDTH - 1 downto 0);
      B2Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
      A2Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
      D3Out   :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
      Z4D4Out :  in std_logic_vector(REG_WIDTH  - 1 downto 0);
      rst     :  in std_logic;
      clk     :  in std_logic;
      IR2     :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR3     :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR4     :  in std_logic_vector(REG_WIDTH*2-1 downto 0)
   );
end ALUArea;

architecture Behaviorial of ALUArea is

   component leftForwardMUXALU is
      port(
         in1       :        in std_logic_vector(REG_WIDTH-1 downto 0);
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3       :        in std_logic_vector(REG_WIDTH  - 1 downto 0);
         selectSig :        in std_logic_vector(1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0)
      );
   end component;
   
   component rightForwardMUXALU is
      port(
         in1       :        in std_logic_vector(REG_WIDTH-1 downto 0);
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         in3       :        in std_logic_vector(REG_WIDTH  - 1 downto 0);
         selectSig :        in std_logic_vector(1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0)
      );
   end component;  
   
   component MUXbeforeALU is
      port(
         in1       :        in std_logic_vector(REG_WIDTH-1 downto 0);
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
         IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
      );
   end component;

   component storeMUXBeforeZ3 is
      port(
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
         IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
      );
   end component;
   
   --this mux is placed as the innermost MUX to the right inport of the ALU (not in the schematic as of yet)
   component withOffSetMUX is
      port(
         in2       :        in std_logic_vector(REG_WIDTH - 1 downto 0);
         out1      :        out std_logic_vector(REG_WIDTH - 1 downto 0);
         IR2       :        in std_logic_vector(REG_WIDTH*2-1 downto 0)
      );
   end component;
   
   component ALU is
      port(
         leftIn  : in std_logic_vector(REG_WIDTH-1 downto 0);
         rightIn : in std_logic_vector(REG_WIDTH-1 downto 0);
         ALUOut  : out std_logic_vector(REG_WIDTH-1 downto 0);
         ALUInstr: in std_logic_vector(4 downto 0);
         
         clk     : in std_logic;
         
         sRZ     : out std_logic;
         sRN     : out std_logic;
         sRO     : out std_logic;
         sRC     : out std_logic
      );
   end component;
   
   component forwardLogicLeft is
   port(
      IR2             :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR3             :  in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR4             :  in std_logic_vector(REG_WIDTH*2-1 downto 0);     
      selectSignal    :  out std_logic_vector(1 downto 0)
   );
   end component;
   
   component forwardLogicRight is
   port(
      IR2          :     in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR3          :     in std_logic_vector(REG_WIDTH*2-1 downto 0);
      IR4          :     in std_logic_vector(REG_WIDTH*2-1 downto 0);     
      selectSignal :     out std_logic_vector(1 downto 0)
   );
   end component;
    
   --interna signaler
   signal MUX5Out             :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal MUX4Out             :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal MUX3Out             :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal MUX2Out             :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal MUX1Out             :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal MUX1Select          :     std_logic_vector(1 downto 0);
   signal MUX2Select          :     std_logic_vector(1 downto 0);
   
   signal ALUOutSignal        :     std_logic_vector(REG_WIDTH-1 downto 0);
   signal ALUInstrInternal    :     std_logic_vector(ALU_INSTR_WIDTH-1 downto 0);
   
begin
   MUX1 : leftForwardMUXALU port map (
      in1               => B2Out,
      in2               => Z4D4Out,
      in3               => D3Out,
      selectSig         => MUX1Select,
      out1              => MUX1Out   
   );
   
   FLL : forwardLogicLeft port map(
      IR2               => IR2,
      IR3               => IR3,
      IR4               => IR4,
      selectSignal      => MUX1Select
   );

   MUX2 : rightForwardMUXALU port map (
      in1               => A2Out,
      in2               => Z4D4Out,
      in3               => D3Out,
      selectSig         => MUX2Select,
      out1              => MUX2Out   
   );
   
   FLR : forwardLogicRight port map(
      IR2               => IR2,
      IR3               => IR3,
      IR4               => IR4,
      selectSignal      => MUX2Select
   );
   
   MUX3 : MUXbeforeALU port map (
      in1               => D2Out,
      in2               => MUX1Out,
      out1              => MUX3Out,   
      IR2               => IR2
   );
   
   MUX4 : storeMUXBeforeZ3 port map (
      in2               => MUX1Out,
      out1              => MUX4Out,   
      IR2               => IR2
   );

   MUX5 : withOffSetMUX port map (
      in2               => MUX2Out,
      out1              => MUX5Out,   
      IR2               => IR2
   );
   
   
   ALUi : ALU port map (
      leftIn            => MUX3Out,
      rightIn           => MUX5Out,

      ALUOut            => ALUOutSignal,
      ALUInstr          => ALUInstrInternal,
      
      clk               => clk,
      
      sRZ               => sRZ,
      sRN               => sRN,
      sRO               => sRO,
      sRC               => sRC
   
   
   );
   
   --Om det rör sig om en ALUINSTRUKTION så ska den givna instruktionen läsas, alla andra fall kan ses som specialfall
   --för att fixa med att ge en konstant offset i både store och load fallen samt då man storar en konstant så krävs en extra mux/extra register
   --lade till en mux för stora med konstant och ännu en till mux för att kunna utföra instruktioner "with offset" dvs store och load.
   with IR2(PMEM_WIDTH-1 downto PMEM_WIDTH-OP_WIDTH) select
                          -- ALUINST
      ALUInstrInternal <=  IR2(ALU_INSTR_OFFSET downto ALU_INSTR_OFFSET - ALU_INSTR_WIDTH + 1) when "00101",
                           IR2(ALU_INSTR_OFFSET downto ALU_INSTR_OFFSET - ALU_INSTR_WIDTH + 1) when "00110",
                           --STORE.c
                           "11111" when "11000",
                           --STORE.r , 11111 is reserved to let what comes in through leftIn go straight to ALUout after clk
                           "11111" when "11001",
                           --STORE.wo
                           "10000" when "11010",
                           --STORE.wofr
                           --10000 to ALU does addition without affecting flags
                           "10000" when "11011",
                           --LOAD.a
                           "11111" when "11100",
                           --LOAD.c
                           "11111" when "11101",
                           --LOAD.wo
                           "10000" when "11110",
                           --LOAD.wro
                           "10000" when "11111",
                           --MOVE
                           "11111" when "00100",
                           --do nothing
                           "00000" when others;   
   
   --Muxade innan denna så att vi kan lagra konstanter direkt i minnet
   Z3in <= MUX4Out;
   
   --set actual out signal from ALUAREA
   ALUOut <= ALUOutSignal;
   
end Behaviorial;
