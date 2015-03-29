
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
# VIKTIG NOTERING: Om du �ndrar vilka filer som finns med i projektet s� m�ste du k�ra
#                  make proj1.clean
#
# Syntesrapporten ligger i proj1-synthdir/xst/synth/design.syr
# Maprapporten (bra att kolla i f�r arearapportens skull) ligger i proj1-synthdir/layoutdefault/design_map.mrp
# Timingrapporten (skapas av make proj1.timing) ligger i proj1-synthdir/layoutdefault/design.trw

# (Or proj2.simc, proj2.sim, etc, depending on the name of the
# project)

XILINX_INIT = source /sw/xilinx/ise_12.4i/ISE_DS/settings32.sh;
PART=xc6slx16-3-csg324



midi_input.%: S=midiinput/midi_area.vhd midiinput/midi_check_msg.vhd midiinput/midi_mux_counter.vhd midiinput/midi_uart_input.vhd midiinput/midi_constants.vhd
midi_input.%: T=midi_tb.vhd
midi_input.%: U=midi.ucf

pmem.%: S=pmemArea.vhd ir1.vhd ir2.vhd jmp.vhd pcreg.vhd pmem.vhd reg.vhd records.vhd const.vhd
pmem.%: T=pmem_tb.vhd
pmem.%: U=pmem.ucf



# Det h�r �r ett exempel p� hur man kan skriva en testb�nk som �r
# relevant, �ven om man k�r en simulering i batchl�ge (make batchlab.simc)
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
