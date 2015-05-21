onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /synth_tb/synt/sout/sound_output/sample
add wave -noupdate -format Literal /synth_tb/synt/sout/sound_output/samplebuffer
add wave -noupdate -format Literal /synth_tb/synt/cpu/main/mem/mem/mem
add wave -noupdate -format Logic /synth_tb/synt/cpu/main/regs/st1t/finished
add wave -noupdate -format Literal /synth_tb/synt/cpu/main/regs/ir2
add wave -noupdate -format Literal -label ir3 /synth_tb/synt/cpu/main/ir3/reg
add wave -noupdate -format Literal -label R_NOTE /synth_tb/synt/cpu/main/regs/gregs__0/genreg/reg
add wave -noupdate -format Literal -label NOTE_MUL -radix unsigned /synth_tb/synt/cpu/main/regs/gregs__6/genreg/reg
add wave -noupdate -format Literal -label STEP -radix unsigned /synth_tb/synt/cpu/main/regs/gregs__7/genreg/reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {1 us}
