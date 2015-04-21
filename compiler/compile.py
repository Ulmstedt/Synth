from __future__ import print_function
import xml.etree.ElementTree as ET

f = open("test.txt",'r')
code = f.readlines()

rules = ET.parse('rules.xml')
root = rules.getroot()

# for finding errors
instr_counter = 0
instr_found = True


def parse_arg(arg):
   if arg[0] == '$':
      return bin(int(arg[1:],16))[2:]
   elif arg[0] == '%':
      return arg[1:]
   else:
      return bin(int(arg,10))[2:]


for instruction in code:
   if instruction == '\n':
      continue
   if instr_found == False:
      print("Bad instruction found on line", instr_counter)
   instr_found = False
   instr_counter += 1
   instruction = instruction.split('#',1)[0] # Remove eventual comments
   instr_list = instruction.upper().replace(',',' ').split() # split string, instr_list[1] = arg1 and so on
   for instr in root.findall('instr'):
      if instr.get('name') == instr_list[0]: # instr is now the needed element
         instr_found = True
         # 0 arguments (TRAP, NOP)
         if len(instr_list) == 1:
            OP = instr.find('OP').text
            tempstring = OP + (32-len(OP))*'0'
            print(tempstring)
         # 2 arguments (MOVE)
         if len(instr_list) == 3:
            DEST_LENGTH = instr.find('DEST').find('LENGTH').text
            SRC_LENGTH = instr.find('SRC').find('LENGTH').text
            
            OP = instr.find('OP').text

            # Parse args and make sure that the length is correct
            ARG1 = parse_arg(instr_list[1]).rjust(int(DEST_LENGTH),'0')[-int(DEST_LENGTH):]
            ARG2 = parse_arg(instr_list[2]).rjust(int(SRC_LENGTH),'0')[-int(SRC_LENGTH):]
            
            # Make sure the length of instruction is 32
            tempstring = OP +" "+ ARG1 +" "+ (32-len(OP)-int(DEST_LENGTH)-int(SRC_LENGTH))*'0' +" "+ ARG2
            print(tempstring)

         break # Correct instruction has been found
         



# len(list) returns length of list

# if instr.find('LOL') != None:

# print(instr.find('OP').text)

# len(bin(int(instr_list[2],16))[2:]) -- ger antal digits

# string.rjust(x, 'c') -- hogerjusterar strang till langd x, lagger in c pa vanstersidan




            #ARG1 = (bin(int(instr_list[1][1:],16))[2:] if instr_list[1][0] == '$' else instr_list[1]).rjust(int(DEST_LENGTH),'0')[-int(DEST_LENGTH):] # Make sure that the length is correct
            #ARG2 = (bin(int(instr_list[2][1:],16))[2:] if instr_list[2][0] == '$' else instr_list[2]).rjust(int(SRC_LENGTH),'0')[-int(SRC_LENGTH):] # Make sure that the length is correct
