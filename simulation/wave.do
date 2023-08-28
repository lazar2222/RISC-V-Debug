onerror {resume}
radix define MCP {
    "5'b10000" "PROLOGUE"
    "5'b10001" "DISPATCH"
    "5'b01101" "LUI"
	"5'b00101" "AUIPC"
	"5'b11011" "JAL"
	"5'b11001" "JALR"
	"5'b11000" "BRANCH"
	"5'b00000" "LOAD"
	"5'b00001" "LOAD_W"
	"5'b00010" "LOAD_1"
	"5'b01000" "STORE"
	"5'b01001" "STORE_W"
	"5'b01010" "STORE_1"
	"5'b00100" "OPIMM"
	"5'b01100" "OP"
	"5'b00011" "MISCMEM"
	"5'b11100" "SYSTEM"
    "5'b01110" "HALTED"
    "5'b01111" "RESUMING"
    "5'b10010" "ABS_REG"
    "5'b10011" "ABS_EXEC"
    "5'b10100" "ABS_RMEM"
    "5'b10101" "ABS_RMEM_1"
    "5'b10110" "ABS_WMEM"
    "5'b10111" "ABS_WMEM_1"
    -default hex
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {testbench} /testbench/top/*
add wave -noupdate -expand -group {bus_interface} /testbench/top/bus_interface/*
add wave -noupdate -expand -group {dmi_interface} /testbench/top/dmi_interface/*
add wave -noupdate -expand -group {debug_interface} /testbench/top/debug_interface/*
add wave -noupdate -expand -group {dm} /testbench/top/dm/*
add wave -noupdate -expand -group {d_ctl} /testbench/top/rv_core/d_ctl/*
add wave -noupdate -expand -group {control} -radix MCP /testbench/top/rv_core/control/*
add wave -noupdate -expand -group {rv_core} /testbench/top/rv_core/*
add wave -noupdate -expand -group {control_signals} /testbench/top/rv_core/control_signals/*
add wave -noupdate -expand /testbench/top/rv_core/reg_file/registers
add wave -noupdate -expand -group {mem_interface} /testbench/top/rv_core/mem_interface/*
add wave -noupdate -expand -group {csr_interface} /testbench/top/rv_core/csr_interface/*
add wave -noupdate -expand -group {csr} /testbench/top/rv_core/csr/*
add wave -noupdate -expand -group {int_ctl} /testbench/top/rv_core/int_ctl/*
add wave -noupdate -expand -group {memory} /testbench/top/memory/*
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 173
configure wave -valuecolwidth 122
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod {100 ps}
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3904 ps}
