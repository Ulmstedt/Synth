onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /midi_tb/midi/clk
add wave -noupdate -format Logic /midi_tb/midi/rst
add wave -noupdate -divider MREGS
add wave -noupdate -format Literal /midi_tb/midi/mreg1
add wave -noupdate -format Literal /midi_tb/midi/mreg2
add wave -noupdate -format Literal /midi_tb/midi/mreg3
add wave -noupdate -divider VARIOUS
add wave -noupdate -format Logic /midi_tb/midi/readrdy
add wave -noupdate -format Logic /midi_tb/midi/msgready
add wave -noupdate -divider INPUT_STEP_1
add wave -noupdate -format Logic /midi_tb/midi/uart
add wave -noupdate -format Logic /midi_tb/midi/midiuartinput/inputactive
add wave -noupdate -format Logic /midi_tb/midi/midiuartinput/msgready
add wave -noupdate -format Literal /midi_tb/midi/midiuartinput/clkcounter
add wave -noupdate -format Literal /midi_tb/midi/midiuartinput/bitsreceived
add wave -noupdate -format Literal /midi_tb/midi/midiuartinput/m1
add wave -noupdate -format Literal /midi_tb/midi/midiuartinput/tmpreg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1962 ns} 0}
configure wave -namecolwidth 123
configure wave -valuecolwidth 73
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {4196 ns}
