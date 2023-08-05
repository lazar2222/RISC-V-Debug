`ifndef CONTROL_SIGNALS_IF__SVH
`define CONTROL_SIGNALS_IF__SVH

interface control_signals_if;
    wire invalid_inst, ialign, mem_fc, mem_malign;
    wire opcode_load, opcode_miscmem, opcode_opimm, opcode_auipc, opcode_store, opcode_op;
    wire opcode_lui, opcode_branch, opcode_jalr, opcode_jal, opcode_system;
    wire [4:0] aluop_in;
    reg write_pc, write_ir, write_rd;
    reg mem_read, mem_write;
    reg [4:0] alu_op;
    reg addr_sel, rd_sel;
    reg [1:0] alu_insel1, alu_insel2;
endinterface

`endif
