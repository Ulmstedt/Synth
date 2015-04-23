onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider PC
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/pc/curpc
add wave -noupdate -divider Reg0
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg0/reg
add wave -noupdate -divider Reg1
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg1/reg
add wave -noupdate -divider Reg2
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg2/reg
add wave -noupdate -divider Reg3
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg3/reg
add wave -noupdate -divider Reg4
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg4/reg
add wave -noupdate -divider SR
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/sr/reg
add wave -noupdate -divider IR1
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/ir1out
add wave -noupdate -divider IR2
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/ir2c/ir2/reg
add wave -noupdate -divider IR4
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/ir4
add wave -noupdate -divider ALU
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/leftin
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/rightin
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/aluinstr
add wave -noupdate -format Logic /cpu_tb/cpu/main/alu/alui/clk
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/temp
add wave -noupdate -divider lfmux
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/mux1/out1
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/mux1/selectsig
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/mux1/in3
add wave -noupdate -divider d3
add wave -noupdate -format Literal /cpu_tb/cpu/main/d3reg/reg
add wave -noupdate -divider mem
add wave -noupdate -format Literal /cpu_tb/cpu/main/mem/mem/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {580 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 246
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {485 ns} {631 ns}
