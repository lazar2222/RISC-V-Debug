`include "../system/arilla_bus_if.svh"
`include "control_signals_if.svh"
`include "isa.svh"

module rv_core (
    input clk,
    input rst_n,

    arilla_bus_if bus_interface
);
    control_signals_if control_signals ();

    wire [`ISA__XLEN-1:0] pc, next_pc, shadow_pc;
    wire [`ISA__XLEN-1:0] ir;
    wire [`ISA__XLEN-1:0] rs1, rs2, rd;
    wire [`ISA__XLEN-1:0] mem_in, mem_addr;
    wire [`ISA__XLEN-1:0] imm;
    wire [`ISA__XLEN-1:0] alu_in1;
    wire [`ISA__XLEN-1:0] alu_in2;
    wire [`ISA__XLEN-1:0] alui_out;
    wire [`ISA__XLEN-1:0] alum_out;
    wire [`ISA__XLEN-1:0] alu_out;

    wire [`ISA__RFLEN-1:0] rs1_a, rs2_a, rd_a;
    wire [1:0] mem_size;
    wire [3:0] alui_op;

    wire mem_signed, branch_take;

    shadow_reg #(
        .Width(`ISA__XLEN),
        .ResetValue(`ISA__RVEC)
    ) pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .in(next_pc),
        .write(control_signals.write_pc),
        .out(pc),
        .shadow_out(shadow_pc)
    );

    shadow_reg #(
        .Width(`ISA__XLEN),
        .ResetValue(`ISA__RVEC)
    ) ir_reg (
        .clk(clk),
        .rst_n(rst_n),
        .in(mem_in),
        .write(control_signals.write_ir),
        .shadow_out(ir)
    );

    reg_file #(
        .Width(`ISA__XLEN),
        .Depth(`ISA__RNUM)
    ) reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .rd_addr1(rs1_a),
        .rd_addr2(rs2_a),
        .wr_addr(rd_a),
        .wr_data(rd),
        .wr_en(control_signals.write_rd),
        .rd_data1(rs1),
        .rd_data2(rs2)
    );

    mem_interface #(
        .DataWidth(`ISA__XLEN),
        .AddressWidth(`ISA__XLEN)
    ) mem_interface (
        .clk(clk),
        .rst_n(rst_n),
        .bus_interface(bus_interface),
        .data_in(rs2),
        .data_out(mem_in),
        .address(mem_addr),
        .size(mem_size),
        .rd(control_signals.mem_read),
        .wr(control_signals.mem_write),
        .singed(mem_signed),
        .malign(control_signals.mem_malign),
        .complete(control_signals.mem_fc)
    );

    inst_decode inst_decode (
        .inst(ir),
        .invalid_inst(control_signals.invalid_inst),
        .opcode_load(control_signals.opcode_load),
        .opcode_miscmem(control_signals.opcode_miscmem),
        .opcode_opimm(control_signals.opcode_opimm),
        .opcode_auipc(control_signals.opcode_auipc),
        .opcode_store(control_signals.opcode_store),
        .opcode_op(control_signals.opcode_op),
        .opcode_lui(control_signals.opcode_lui),
        .opcode_branch(control_signals.opcode_branch),
        .opcode_jalr(control_signals.opcode_jalr),
        .opcode_jal(control_signals.opcode_jal),
        .opcode_system(control_signals.opcode_system),
        .alu_op(control_signals.aluop_in),
        .rd(rd_a),
        .rs1(rs1_a),
        .rs2(rs2_a),
        .imm(imm)
    );

    alu #(
        .Width(`ISA__XLEN)
    ) alu (
        .a (alu_in1),
        .b (alu_in2),
        .op(control_signals.alu_op[3:0]),
        .c (alui_out)
    );

    alu_m #(
        .Width(`ISA__XLEN)
    ) alu_m (
        .a (rs1),
        .b (rs2),
        .op(control_signals.alu_op[2:0]),
        .c (alum_out)
    );

    branch_compare #(
        .Width(`ISA__XLEN)
    ) branch_compare (
        .a(rs1),
        .b(rs2),
        .op(control_signals.alu_op[2:0]),
        .take(branch_take)
    );

    alu_pc #(
        .Width(`ISA__XLEN)
    ) alu_pc (
        .pc(pc),
        .rs(rs1),
        .imm(imm),
        .branch(control_signals.opcode_branch),
        .jal(control_signals.opcode_jal),
        .jalr(control_signals.opcode_jalr),
        .take(branch_take),
        .next_pc(next_pc),
        .ialign(control_signals.ialign)
    );

    assign mem_addr = control_signals.addr_sel ? shadow_pc : alu_out;
    assign rd = control_signals.rd_sel ? mem_in : alu_out;
    assign alu_out = control_signals.alu_op[4] ? alum_out : alui_out;
    assign alu_in1 = control_signals.alu_insel1[0] ? (control_signals.alu_insel1[1] ? 32'd0 : pc) : rs1;
    assign alu_in2 = control_signals.alu_insel2[0] ? (control_signals.alu_insel2[1] ? 32'd4 : imm) : rs2;
    assign mem_size = control_signals.addr_sel ? `ISA__INST_SIZE : control_signals.aluop_in[1:0];
    assign mem_signed = !control_signals.aluop_in[2];

    control control (
        .clk(clk),
        .rst_n(rst_n),
        .control_signals(control_signals)
    );
endmodule
