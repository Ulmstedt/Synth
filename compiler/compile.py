from __future__ import print_function
import xml.etree.ElementTree as ET

# Constants dict
constants = {  
               # Status flags
               "SR_Z":     "0",
               "SR_N":     "1",
               "SR_C":     "2",
               "SR_O":     "3",
               "SR_LT1":   "4",
               "SR_ST1":   "5",
               "SR_ST2":   "6",
               "SR_MIDI":  "7",

               # General registers
               "R_G1":     "0",
               "R_G2":     "1",
               "R_G3":     "2",
               "R_G4":     "3",
               "R_G5":     "4",
               "R_G6":     "5",
               "R_G7":     "6",
               "R_G8":     "7",

               "R_SR":     "8",
               "R_LT1_L":  "16",
               "R_LT1_H":  "17",
               "R_ST1":    "18",
               "R_ST2":    "19",
               "R_TOUCHX"  "20",
               "R_TOUCHY"  "21",
               "SVF_IN":   "22",
               "SVF_D1":   "23",
               "SVF_D2":   "24",
               "SVF_OUT":  "25",
               "SVF_F":    "26",
               "SVF_Q":    "27",
               "R_MREG12": "29",
               "R_MREG3":  "30",
               "R_AUDIO":  "31"
            }

# Parses and argument and returns its correct form (hex, dec, bin)
def parse_arg(arg):
   # Hex
   if arg[0] == '$':
      return bin(int(arg[1:],16))[2:]
   # Bin
   elif arg[0] == '%':
      return arg[1:]
   elif arg[0] == '#':
      return parse_arg(constants[arg[1:].upper()])
   # Dec
   else:
      return bin(int(arg,10))[2:]

# Compiles the given files to binary format
def comp_file(*filenames):
   outfile = open("binary_out.mem", "w+")
   outfile.write("@00\n")
   rules = ET.parse('rules.xml')
   root = rules.getroot()

   for i in range(0,2):

      # instruction counter
      instr_counter = 0
      # for finding errors
      line_counter = 0

      for curfile in filenames:
         f = open(curfile,'r')
         code = f.readlines()
      
         instr_found = True

         for instruction in code:
            if instruction == '\n':
               continue
            if instr_found == False:
               print("Bad instruction found on line", line_counter)
            instr_found = False
            line_counter += 1
            instruction = instruction.split(';',1)[0] # Remove eventual comments
            instr_list = instruction.upper().replace(',',' ').split() # split string, instr_list[1] = arg1 and so on

            # Check for only constants the first iteration
            if instr_list[0][0] == '&':
               if i == 0:
                  constants[instr_list[0][1:].upper()] = str(instr_counter)
               instr_found = True
               continue
            
            if instr_list[0].upper() == 'CONSTANT':
               if i == 0:
                  constants[instr_list[1].upper()] = instr_list[2].upper()
               instr_found = True
               continue

            for instr in root.findall('instr'):
               if instr.get('name') == instr_list[0]: # instr is now the needed element
                  instr_counter += 1
                  instr_found = True

                  # Only go further if its the second iteration
                  if i == 0:
                     continue

                  OP = instr.find('OP').text
                  # 0 arguments
                  if len(instr_list) == 1:
                     tempstring = OP + (32-len(OP))*'0'
                     tempstring2 = "(\"" + tempstring + "\"),"
                     print(tempstring2)
                     tempstring3 = hex(int(tempstring,2))[2:]
                     tempstring4 = (8 - len(tempstring3)) * "0" + tempstring3
                     outfile.write(tempstring4 + " ")
                  # 1 argument
                  elif len(instr_list) == 2:
                     DEST_LENGTH = instr.find('DEST').find('LENGTH').text
                     ARG1 = parse_arg(instr_list[1]).rjust(int(DEST_LENGTH),'0')[-int(DEST_LENGTH):]
                     tempstring = OP + (32-len(OP)-int(DEST_LENGTH))*'0' + ARG1
                     tempstring2 = "(\"" + tempstring + "\"),"
                     print(tempstring2)
                     tempstring3 = hex(int(tempstring,2))[2:]
                     tempstring4 = (8 - len(tempstring3)) * "0" + tempstring3
                     outfile.write(tempstring4 + " ")
                  # 2 arguments
                  elif len(instr_list) >= 3:
                     DEST_LENGTH = instr.find('DEST').find('LENGTH').text
                     SRC_LENGTH = instr.find('SRC').find('LENGTH').text
                     OFF_LENGTH = '0'

                     # Parse args and make sure that the length is correct
                     ARG1 = parse_arg(instr_list[1]).rjust(int(DEST_LENGTH),'0')[-int(DEST_LENGTH):]
                     ARG2 = parse_arg(instr_list[2]).rjust(int(SRC_LENGTH),'0')[-int(SRC_LENGTH):]
                     ARG3 = ''

                     # 3 arguments
                     if len(instr_list) == 4:
                        OFF_LENGTH = instr.find('OFFSET').find('LENGTH').text               
                        ARG3 = parse_arg(instr_list[3]).rjust(int(OFF_LENGTH),'0')[-int(OFF_LENGTH):]

                     # Make sure the length of instruction is 32
                     tempstring = OP + ARG1 + (32-len(OP)-int(DEST_LENGTH)-int(SRC_LENGTH)-int(OFF_LENGTH))*'0' + ARG3 + ARG2
                     tempstring2 = "(\"" + tempstring + "\"),"
                     print(tempstring2)
                     tempstring3 = hex(int(tempstring,2))[2:]
                     tempstring4 = (8 - len(tempstring3)) * "0" + tempstring3
                     outfile.write(tempstring4 + " ")

                  break # Correct instruction has been found



