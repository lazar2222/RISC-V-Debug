`ifndef CONTROL_SIGNALS_IF__SVH
`define CONTROL_SIGNALS_IF__SVH

`include "isa.svh"

`define CONTROL_SIGNALS__ADDR_ALU 1'b0
`define CONTROL_SIGNALS__ADDR_PC  1'b1
`define CONTROL_SIGNALS__RD_ALU   2'b00
`define CONTROL_SIGNALS__RD_MEM   2'b01
`define CONTROL_SIGNALS__RD_CSR   2'b10
`define CONTROL_SIGNALS__ALU1_RS  2'b00
`define CONTROL_SIGNALS__ALU1_PC  2'b01
`define CONTROL_SIGNALS__ALU1_ZR  2'b10
`define CONTROL_SIGNALS__ALU2_RS  2'b00
`define CONTROL_SIGNALS__ALU2_IM  2'b01
`define CONTROL_SIGNALS__ALU2_IS  2'b10

interface control_signals_if;
    wire                          mem_complete;
    wire [`ISA__OPCODE_WIDTH-1:0] opcode;
    wire [`ISA__FUNCT3_WIDTH-1:0] f3;
    reg                           halted;
    reg                           write_pc_ne, write_pc_ex;
    reg                           write_pc, write_ir, write_rd, write_csr;
    reg                           mem_read, mem_write;
    reg                           addr_sel;
    reg  [                   1:0] rd_sel;
    reg  [                   1:0] alu_insel1, alu_insel2;
endinterface

`endif  //CONTROL_SIGNALS_IF__SVH
