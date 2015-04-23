onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider generic
add wave -noupdate -format Logic /cpu_tb/cpu/main/clk
add wave -noupdate -format Logic /cpu_tb/cpu/main/rst
add wave -noupdate -divider ir2
add wave -noupdate -format Literal /cpu_tb/cpu/main/ir2
add wave -noupdate -divider ir3
add wave -noupdate -format Literal /cpu_tb/cpu/main/ir3out
add wave -noupdate -divider ir4
add wave -noupdate -format Literal /cpu_tb/cpu/main/ir4out
add wave -noupdate -divider {reg 1 & 2}
add wave -noupdate -format Literal -label {reg 1} /cpu_tb/cpu/main/regs/genreg1/reg
add wave -noupdate -format Literal -label {reg 2} /cpu_tb/cpu/main/regs/genreg2/reg
add wave -noupdate -divider mem
add wave -noupdate -format Literal /cpu_tb/cpu/main/mem/mem/addr
add wave -noupdate -format Literal -radix decimal /cpu_tb/cpu/main/mem/mem/mem
add wave -noupdate -format Logic /cpu_tb/cpu/main/mem/mem/dowrite
add wave -noupdate -format Literal /cpu_tb/cpu/main/mem/mem/newvalue
add wave -noupdate -divider alu
add wave -noupdate -format Literal /cpu_tb/cpu/main/alu/aluout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {540 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {509 ns} {573 ns}
