onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /synth_tb/synt/sout/sound_output/sample
add wave -noupdate -format Literal /synth_tb/synt/sout/sound_output/samplebuffer
add wave -noupdate -format Literal /synth_tb/synt/cpu/main/mem/mem/mem
add wave -noupdate -format Logic /synth_tb/synt/cpu/main/regs/st1t/finished
add wave -noupdate -format Literal /synth_tb/synt/cpu/sr
add wave -noupdate -format Literal /synth_tb/synt/cpu/main/regs/ir2
add wave -noupdate -format Literal -label ir3 /synth_tb/synt/cpu/main/ir3/reg
add wave -noupdate -format Literal -label R_NOTE /synth_tb/synt/cpu/main/regs/gregs__0/genreg/reg
add wave -noupdate -format Literal -label NOTE_MUL -radix unsigned /synth_tb/synt/cpu/main/regs/gregs__6/genreg/reg
add wave -noupdate -format Literal -label STEP -radix unsigned /synth_tb/synt/cpu/main/regs/gregs__7/genreg/reg
add wave -noupdate -format Literal /synth_tb/synt/svfc/f
add wave -noupdate -format Literal /synth_tb/synt/svfc/q
add wave -noupdate -format Literal -label {filter input} /synth_tb/synt/svfc/sample
add wave -noupdate -format Literal /synth_tb/synt/svfc/output
add wave -noupdate -format Logic /synth_tb/synt/halveddelay
add wave -noupdate -format Logic /synth_tb/synt/savedelays
add wave -noupdate -format Logic /synth_tb/synt/svfc/loadfilter
add wave -noupdate -divider phase0
add wave -noupdate -format Literal /synth_tb/synt/svfc/qmult
add wave -noupdate -format Literal /synth_tb/synt/svfc/subint
add wave -noupdate -format Literal /synth_tb/synt/svfc/sub
add wave -noupdate -divider phase1
add wave -noupdate -format Literal /synth_tb/synt/svfc/p1/input
add wave -noupdate -format Literal /synth_tb/synt/svfc/p1/f
add wave -noupdate -format Literal /synth_tb/synt/svfc/p1/o
add wave -noupdate -format Literal /synth_tb/synt/svfc/p1/output
add wave -noupdate -divider phase2
add wave -noupdate -format Literal /synth_tb/synt/svfc/p2/input
add wave -noupdate -format Literal /synth_tb/synt/svfc/p2/delay_in
add wave -noupdate -format Literal /synth_tb/synt/svfc/p2/delay_out
add wave -noupdate -format Literal /synth_tb/synt/svfc/p2/addition
add wave -noupdate -format Literal /synth_tb/synt/svfc/p2/output
add wave -noupdate -divider phase3
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/input
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/f
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/multiplication
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/addition
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/delay_in
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/delay_out
add wave -noupdate -format Literal /synth_tb/synt/svfc/p3/lp_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6339993 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 174
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
WaveRestoreZoom {6339947 ns} {6340063 ns}
