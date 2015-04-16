
# Makefile for hardware implementation on Xilinx FPGAs and ASICs
# Author: Andreas Ehliar <ehliar@isy.liu.se>
# 
# T is the testbench file for this project
# S is the synthesizable sources for this project
# U is the UCF file
# PART is the part

# Important makefile targets:
# make proj1.sim	GUI simulation
# make proj1.simc	batch simulation
# make proj1.synth	Synthesize
# make proj1.route	Route the design
# make proj1.bitgen	Generate bit file
# make proj1.timing	Generate timing report
# make proj1.clean	Use whenever you change settings in the Makefile!
# make proj1.prog	Downloads the bitfile to the FPGA. NOTE: Does not
#                       rebuild bitfile if source files have changed!
# make clean            Removes all generated files for all projects. Also
#                       backup files (*~) are removed.
# 
# VIKTIG NOTERING: Om du ändrar vilka filer som finns med i projektet så måste du köra
#                  make proj1.clean
#
# Syntesrapporten ligger i proj1-synthdir/xst/synth/design.syr
# Maprapporten (bra att kolla i för arearapportens skull) ligger i proj1-synthdir/layoutdefault/design_map.mrp
# Timingrapporten (skapas av make proj1.timing) ligger i proj1-synthdir/layoutdefault/design.trw

# (Or proj2.simc, proj2.sim, etc, depending on the name of the
# project)

XILINX_INIT = source /sw/xilinx/ise_12.4i/ISE_DS/settings64.sh;
PART=xc6slx16-3-csg324



midi_input.%: S=midiinput/midi_area.vhd midiinput/midi_check_msg.vhd midiinput/midi_mux_counter.vhd midiinput/midi_uart_input.vhd midiinput/midi_constants.vhd
midi_input.%: T=midiinput/midi_tb.vhd
midi_input.%: U=main.ucf

s_out.%: S=soundoutput/sout_area.vhd soundoutput/sout.vhd soundoutput/sout_clkgen.vhd soundoutput/soundwave.vhd soundoutput/sout_constants.vhd
s_out.%: T=soundoutput/sout_tb.vhd
s_out.%: U=main.ucf

alu.%: S=cpu/alu_area.vhd cpu/alu.vhd cpu/alu_muxes.vhd cpu/rightforwardinglogic.vhd cpu/leftforwardinglogic.vhd cpu/const.vhd
alu.%: T=cpu/alu_tb.vhd
alu.%: U=main.ucf

pmem.%: S=cpu/pmem_area.vhd cpu/ir1.vhd cpu/ir2.vhd cpu/jmp.vhd cpu/pcreg.vhd cpu/pmem.vhd cpu/reg.vhd cpu/pmem_content.vhd cpu/records.vhd cpu/const.vhd
pmem.%: T=cpu/pmem_tb.vhd
pmem.%: U=main.ucf

#To test the whole cpu, atm, needs to add the appropriate files below, as they're not yet present
cpu.%: S=cpu/cpu_area.vhd cpu/main_area.vhd cpu/pmem_area.vhd cpu/ir1.vhd cpu/ir2.vhd cpu/jmp.vhd cpu/pcreg.vhd cpu/pmem.vhd cpu/reg_area.vhd cpu/reg.vhd cpu/mem_area.vhd cpu/mem.vhd cpu/z4d4mux.vhd cpu/d_reg.vhd cpu/alu_area.vhd cpu/alu.vhd cpu/alu_muxes.vhd cpu/rightforwardinglogic.vhd cpu/leftforwardinglogic.vhd cpu/mem_content.vhd cpu/pmem_content.vhd cpu/records.vhd cpu/const.vhd
cpu.%: T=cpu/cpu_tb.vhd
cpu.%: U=main.ucf


# Det här är ett exempel på hur man kan skriva en testbänk som är
# relevant, även om man kör en simulering i batchläge (make batchlab.simc)
# batchlab.%: S=inputarea.vhd kbmux.vhd kbreg.vhd constants.vhd bytecounter.vhd midibuffer.vhd sync.vhd valid_midi.vhd
# batchlab.%: T=lab_tb.vhd
# batchlab.%: U=lab.ucf


# Misc functions that are good to have
include build/util.mk
# Setup simulation environment
include build/vsim.mk
# Setup synthesis environment
include build/xst.mk
# Setup backend flow environment
include build/xilinx-par.mk
# Setup tools for programming the FPGA
include build/digilentprog.mk



# Alternative synthesis methods
# The following is for ASIC synthesis
#include design_compiler.mk
# The following is for synthesis to a Xilinx target using Precision.
#include precision-xilinx.mk
