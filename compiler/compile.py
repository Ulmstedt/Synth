from __future__ import print_function
import xml.etree.ElementTree as ET

# Constants dict
constants = {} 

# Parses and argument and returns its correct form (hex, dec, bin)
def parse_arg(arg):
   # Hex
   if arg[0] == '$':
      return bin(int(arg[1:],16))[2:]
   # Bin
   elif arg[0] == '%':
      return arg[1:]
   elif arg[0] == '#':
      return parse_arg(constants[arg[1:]])
   # Dec
   else:
      return bin(int(arg,10))[2:]

# Compiles the given files to binary format
def comp_file(*filenames):
   outfile = open("binary_out", "wb+")
   for curfile in filenames:
      f = open(curfile,'r')
      code = f.readlines()

      rules = ET.parse('rules.xml')
      root = rules.getroot()

      # for finding errors
      instr_counter = 0
      instr_found = True     

      for instruction in code:
         if instruction == '\n':
            continue
         if instr_found == False:
            print("Bad instruction found on line", instr_counter)
         instr_found = False
         instr_counter += 1
         instruction = instruction.split(';',1)[0] # Remove eventual comments
         instr_list = instruction.upper().replace(',',' ').split() # split string, instr_list[1] = arg1 and so on

         # Constants
         if instr_list[0].upper() == 'CONSTANT':
            constants[instr_list[1].upper()] = instr_list[2].upper()
            instr_found = True
            continue
         for instr in root.findall('instr'):
            if instr.get('name') == instr_list[0]: # instr is now the needed element
               instr_found = True
               OP = instr.find('OP').text
               # 0 arguments
               if len(instr_list) == 1:
                  tempstring = OP + (32-len(OP))*'0'
                  print(tempstring)
                  outfile.write(tempstring)
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
                  print(tempstring)
                  outfile.write(tempstring)

               break # Correct instruction has been found
         


