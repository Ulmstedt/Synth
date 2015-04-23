onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/pc/clk
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/jmpc/rst
add wave -noupdate -divider PC
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/pc/curpc
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/pc/nextpc
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/pc/nextpctype
add wave -noupdate -divider PC1
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/pc1out
add wave -noupdate -divider IR1
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/ir1out
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/ir1c/ir1stallcausing
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/ir1c/stalling
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/ir1c/isjmp
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/ir1c/ir2isload
add wave -noupdate -divider IR2
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/sr
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/ir2out
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/stall
add wave -noupdate -divider Mem
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/memout
add wave -noupdate -divider JMP
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/jmpc/pcout
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/jmpc/regsel
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/jmpc/regin
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/jmpc/pc2
add wave -noupdate -format Literal /cpu_tb/cpu/pmem/jmpc/pc1
add wave -noupdate -format Logic /cpu_tb/cpu/pmem/jmpc/isjmp
add wave -noupdate -divider {Reg 1}
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/regasel
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/regbsel
add wave -noupdate -format Logic /cpu_tb/cpu/main/regs/regwrite
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/genreg1/reg
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/regwriteval
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/regwritesel
add wave -noupdate -divider ALU
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/b2out
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/a2out
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/d2out
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/d3out
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/z3in
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/leftin
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/rightin
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/alui/aluinstr
add wave -noupdate -format Logic /cpu_tb/cpu/main/alu/srz
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/z4d4out
add wave -noupdate -divider SR
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/srout
add wave -noupdate -format Literal /cpu_tb/cpu/main/regs/srin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {648 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 215
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
WaveRestoreZoom {602 ns} {707 ns}
