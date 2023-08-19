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
    -default hex
}
quietly WaveActivateNextPane {} 0
add wave -group {testbench} /testbench/*
add wave -group {bus_interface} /testbench/bus_interface/*
add wave -group {rv_core} /testbench/rv_core/*
add wave /testbench/rv_core/reg_file/registers
add wave -group {control_signals} /testbench/rv_core/control_signals/*
add wave -group {control} -radix MCP /testbench/rv_core/control/*
add wave -group {mem_interface} /testbench/rv_core/mem_interface/*
add wave -group {csr_interface} /testbench/rv_core/csr_interface/*
add wave -group {csr} /testbench/rv_core/csr/*
add wave -group {int_ctl} /testbench/rv_core/int_ctl/*
add wave -group {memory} /testbench/memory/*
