onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/available
add wave -noupdate /testbench/bus_interface/data_ctp
add wave -noupdate /testbench/bus_interface/data_ptc
add wave -noupdate /testbench/bus_interface/address
add wave -noupdate /testbench/bus_interface/byte_enable
add wave -noupdate /testbench/bus_interface/read
add wave -noupdate /testbench/bus_interface/write
add wave -noupdate /testbench/bus_interface/available
add wave -noupdate /testbench/bus_interface/intercept
add wave -noupdate /testbench/bus_interface/hit
add wave -noupdate /testbench/rv_core/pc
add wave -noupdate /testbench/rv_core/alu_pc
add wave -noupdate /testbench/rv_core/next_pc
add wave -noupdate /testbench/rv_core/shadow_pc
add wave -noupdate /testbench/rv_core/ivec
add wave -noupdate /testbench/rv_core/ir
add wave -noupdate /testbench/rv_core/rs1
add wave -noupdate /testbench/rv_core/rs2
add wave -noupdate /testbench/rv_core/rd
add wave -noupdate /testbench/rv_core/mem_out
add wave -noupdate /testbench/rv_core/mem_addr
add wave -noupdate /testbench/rv_core/imm
add wave -noupdate /testbench/rv_core/csri
add wave -noupdate /testbench/rv_core/alu_in1
add wave -noupdate /testbench/rv_core/alu_in2
add wave -noupdate /testbench/rv_core/alu_out
add wave -noupdate /testbench/rv_core/alum_out
add wave -noupdate /testbench/rv_core/csr_out
add wave -noupdate /testbench/rv_core/rs1_a
add wave -noupdate /testbench/rv_core/rs2_a
add wave -noupdate /testbench/rv_core/rd_a
add wave -noupdate /testbench/rv_core/op
add wave -noupdate /testbench/rv_core/f3
add wave -noupdate /testbench/rv_core/mem_size
add wave -noupdate /testbench/rv_core/mod
add wave -noupdate /testbench/rv_core/mul
add wave -noupdate /testbench/rv_core/ecall
add wave -noupdate /testbench/rv_core/ebreak
add wave -noupdate /testbench/rv_core/trap
add wave -noupdate /testbench/rv_core/malign
add wave -noupdate /testbench/rv_core/ialign
add wave -noupdate /testbench/rv_core/invalid_inst
add wave -noupdate /testbench/rv_core/invalid_csr
add wave -noupdate /testbench/rv_core/hit
add wave -noupdate /testbench/rv_core/control_signals/mem_complete_read
add wave -noupdate /testbench/rv_core/control_signals/mem_complete_write
add wave -noupdate /testbench/rv_core/control_signals/opcode
add wave -noupdate /testbench/rv_core/control_signals/f3
add wave -noupdate /testbench/rv_core/control_signals/write_pc
add wave -noupdate /testbench/rv_core/control_signals/write_ir
add wave -noupdate /testbench/rv_core/control_signals/write_rd
add wave -noupdate /testbench/rv_core/control_signals/write_csr
add wave -noupdate /testbench/rv_core/control_signals/mem_read
add wave -noupdate /testbench/rv_core/control_signals/mem_write
add wave -noupdate /testbench/rv_core/control_signals/addr_sel
add wave -noupdate /testbench/rv_core/control_signals/rd_sel
add wave -noupdate /testbench/rv_core/control_signals/alu_insel1
add wave -noupdate /testbench/rv_core/control_signals/alu_insel2
add wave -noupdate /testbench/rv_core/control/mcp_reg
add wave -noupdate /testbench/rv_core/control/mcp_next
add wave -noupdate /testbench/rv_core/control/mcp_addr
add wave -noupdate /testbench/rv_core/int_ctl/breakpoint
add wave -noupdate /testbench/rv_core/int_ctl/hit
add wave -noupdate /testbench/rv_core/int_ctl/illegal
add wave -noupdate /testbench/rv_core/int_ctl/ialign
add wave -noupdate /testbench/rv_core/int_ctl/ecall
add wave -noupdate /testbench/rv_core/int_ctl/ebreak
add wave -noupdate /testbench/rv_core/int_ctl/malign
add wave -noupdate /testbench/rv_core/int_ctl/ivec
add wave -noupdate /testbench/rv_core/int_ctl/trap
add wave -noupdate /testbench/rv_core/int_ctl/write_ir
add wave -noupdate /testbench/rv_core/int_ctl/write_pc
add wave -noupdate /testbench/rv_core/int_ctl/load_store
add wave -noupdate /testbench/rv_core/int_ctl/load
add wave -noupdate /testbench/rv_core/int_ctl/store
add wave -noupdate /testbench/rv_core/int_ctl/inst
add wave -noupdate /testbench/rv_core/int_ctl/inst_invalid
add wave -noupdate /testbench/rv_core/int_ctl/inst_align
add wave -noupdate /testbench/rv_core/int_ctl/env_call
add wave -noupdate /testbench/rv_core/int_ctl/env_break
add wave -noupdate /testbench/rv_core/int_ctl/ls_breakpoint
add wave -noupdate /testbench/rv_core/int_ctl/l_align
add wave -noupdate /testbench/rv_core/int_ctl/l_fault
add wave -noupdate /testbench/rv_core/int_ctl/s_align
add wave -noupdate /testbench/rv_core/int_ctl/s_fault
add wave -noupdate /testbench/rv_core/int_ctl/inst_breakpoint
add wave -noupdate /testbench/rv_core/int_ctl/inst_fault
add wave -noupdate /testbench/rv_core/int_ctl/sync_ex
add wave -noupdate /testbench/rv_core/int_ctl/mcause
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10785 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 420
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {455 ps} {1769 ps}
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
