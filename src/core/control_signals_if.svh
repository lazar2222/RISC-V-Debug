`ifndef CONTROL_SIGNALS_IF__SVH
`define CONTROL_SIGNALS_IF__SVH

interface control_signals_if;
    wire mem_complete_read, mem_complete_write, mem_malign, invalid_inst, ialign;
    wire [4:0] opcode;
    reg write_pc, write_ir, write_rd;
    reg mem_read, mem_write;
    reg addr_sel, rd_sel;
    reg [1:0] alu_insel1, alu_insel2;
endinterface

`endif
