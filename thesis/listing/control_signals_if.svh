`define CONTROL_SIGNALS__ADDR_ALU 1'b0
`define CONTROL_SIGNALS__ADDR_PC  1'b1
`define CONTROL_SIGNALS__RD_ALU   2'b00
`define CONTROL_SIGNALS__RD_MEM   2'b01
`define CONTROL_SIGNALS__ALU1_RS  2'b00
`define CONTROL_SIGNALS__ALU1_PC  2'b01
`define CONTROL_SIGNALS__ALU1_ZR  2'b10
`define CONTROL_SIGNALS__ALU2_RS  2'b00
`define CONTROL_SIGNALS__ALU2_IM  2'b01
`define CONTROL_SIGNALS__ALU2_IS  2'b10

`define CONTROL_SIGNALS__PROLOGUE   5'b10_000
`define CONTROL_SIGNALS__DISPATCH   5'b10_001
`define CONTROL_SIGNALS__LUI        `ISA__OPCODE_LUI
`define CONTROL_SIGNALS__AUIPC      `ISA__OPCODE_AUIPC
`define CONTROL_SIGNALS__JAL        `ISA__OPCODE_JAL
`define CONTROL_SIGNALS__JALR       `ISA__OPCODE_JALR
`define CONTROL_SIGNALS__BRANCH     `ISA__OPCODE_BRANCH
`define CONTROL_SIGNALS__LOAD       `ISA__OPCODE_LOAD
`define CONTROL_SIGNALS__LOAD_W     (`ISA__OPCODE_LOAD  + 5'd1)
`define CONTROL_SIGNALS__LOAD_1     (`ISA__OPCODE_LOAD  + 5'd2)
`define CONTROL_SIGNALS__STORE      `ISA__OPCODE_STORE
`define CONTROL_SIGNALS__STORE_W    (`ISA__OPCODE_STORE + 5'd1)
`define CONTROL_SIGNALS__STORE_1    (`ISA__OPCODE_STORE + 5'd2)
`define CONTROL_SIGNALS__OPIMM      `ISA__OPCODE_OPIMM
`define CONTROL_SIGNALS__OP         `ISA__OPCODE_OP
`define CONTROL_SIGNALS__MISCMEM    `ISA__OPCODE_MISCMEM
`define CONTROL_SIGNALS__SYSTEM     `ISA__OPCODE_SYSTEM

interface control_signals_if;
    wire                          mem_complete;
    wire [`ISA__OPCODE_WIDTH-1:0] opcode;
    reg                           write_pc, write_ir, write_rd;
    reg                           mem_read, mem_write;
    reg                           addr_sel;
    reg  [                   1:0] rd_sel;
    reg  [                   1:0] alu_insel1, alu_insel2;
endinterface