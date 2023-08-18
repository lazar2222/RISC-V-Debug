`include "../system/arilla_bus_if.svh"
`include "control_signals_if.svh"
`include "csr_if.svh"
`include "isa.svh"

module rv_core (
    input clk,
    input rst_n,

    input nmi,
    input exti,

    arilla_bus_if bus_interface
);
    control_signals_if control_signals ();
    csr_if             csr_interface   ();

    wire [`ISA__XLEN-1:0] pc, alu_pc, next_pc, shadow_pc, ivec;
    wire [`ISA__XLEN-1:0] ir;
    wire [`ISA__XLEN-1:0] rs1, rs2, rd;
    wire [`ISA__XLEN-1:0] mem_out, mem_addr;
    wire [`ISA__XLEN-1:0] imm;
    wire [`ISA__XLEN-1:0] csri;
    wire [`ISA__XLEN-1:0] alu_in1;
    wire [`ISA__XLEN-1:0] alu_in2;
    wire [`ISA__XLEN-1:0] alu_out;
    wire [`ISA__XLEN-1:0] alum_out;
    wire [`ISA__XLEN-1:0] csr_out;

    wire [       `ISA__RFLEN-1:0] rs1_a, rs2_a, rd_a;
    wire [`ISA__FUNCT3_WIDTH-1:0] op;
    wire [`ISA__FUNCT3_WIDTH-1:0] f3;
    wire [`ISA__FUNCT3_WIDTH-1:0] mem_size;

    wire mod, mul, ecall, ebreak, trap;
    wire malign, ialign, invalid_inst, invalid_csr;
    wire hit;

    assign mem_addr = control_signals.addr_sel      ? shadow_pc                                       : alu_out;
    assign rd       = control_signals.rd_sel[1]     ? (control_signals.rd_sel[0] ? csr_out : mem_out) : (mul                           ? alum_out : alu_out);
    assign alu_in1  = control_signals.alu_insel1[1] ? `ISA__ZERO                                      : (control_signals.alu_insel1[0] ? pc       : rs1);
    assign alu_in2  = control_signals.alu_insel2[1] ? `ISA__INST_SIZE                                 : (control_signals.alu_insel2[0] ? imm      : rs2);
    assign mem_size = control_signals.addr_sel      ? `ISA__INST_LOAD_SIZE                            : f3;
    assign next_pc  = trap                          ? ivec                                            : alu_pc;

    assign control_signals.f3 = f3;

    shadow_reg #(
        .Width     (`ISA__XLEN),
        .ResetValue(`ISA__RVEC)
    ) pc_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .in        (next_pc),
        .write     (control_signals.write_pc),
        .out       (pc),
        .shadow_out(shadow_pc)
    );

    shadow_reg #(
        .Width     (`ISA__XLEN),
        .ResetValue(`ISA__ZERO)
    ) ir_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .in        (mem_out),
        .write     (control_signals.write_ir),
        .shadow_out(ir)
    );

    reg_file #(
        .Width(`ISA__XLEN),
        .Depth(`ISA__RNUM)
    ) reg_file (
        .clk     (clk),
        .rst_n   (rst_n),
        .rd_addr1(rs1_a),
        .rd_addr2(rs2_a),
        .wr_addr (rd_a),
        .wr_data (rd),
        .wr_en   (control_signals.write_rd),
        .rd_data1(rs1),
        .rd_data2(rs2)
    );

    mem_interface mem_interface (
        .clk           (clk),
        .rst_n         (rst_n),
        .bus_interface (bus_interface),
        .address       (mem_addr),
        .sign_size     (mem_size),
        .rd            (control_signals.mem_read),
        .wr            (control_signals.mem_write),
        .data_in       (rs2),
        .data_out      (mem_out),
        .malign_r      (malign),
        .complete_read (control_signals.mem_complete_read),
        .complete_write(control_signals.mem_complete_write),
        .hit_r         (hit)
    );

    inst_decode inst_decode (
        .inst        (ir),
        .invalid_inst(invalid_inst),
        .opcode      (control_signals.opcode),
        .f3          (f3),
        .rd          (rd_a),
        .rs1         (rs1_a),
        .rs2         (rs2_a),
        .imm         (imm),
        .csri        (csri),
        .op          (op),
        .mod         (mod),
        .mul         (mul),
        .ecall       (ecall),
        .ebreak      (ebreak)
    );

    alu #(
        .Width(`ISA__XLEN)
    ) alu (
        .a  (alu_in1),
        .b  (alu_in2),
        .op (op),
        .mod(mod),
        .c  (alu_out)
    );

    generate
        if (`ISA__MEXT) begin : g_alu_m
            alu_m #(
                .Width(`ISA__XLEN)
            ) alu_m (
                .a (rs1),
                .b (rs2),
                .f3(f3),
                .c (alum_out)
            );
        end else begin : g_alu_m
            assign alum_out = `ISA__ZERO;
        end
    endgenerate

    alu_pc #(
        .Width(`ISA__XLEN)
    ) alu_pc_i (
        .pc     (pc),
        .a      (rs1),
        .b      (rs2),
        .imm    (imm),
        .opcode (control_signals.opcode),
        .f3     (f3),
        .next_pc(alu_pc),
        .ialign (ialign)
    );

    control control (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals)
    );

    csr csr (
        .clk          (clk),
        .rst_n        (rst_n),
        .reg_in       (rs1),
        .imm_in       (csri),
        .addr         (imm),
        .rs           (rs1_a),
        .f3           (f3),
        .write        (control_signals.write_csr),
        .debug        (1'b0),
        .reg_out      (csr_out),
        .illegal      (invalid_csr),
        .bus_interface(bus_interface),
        .csr_interface(csr_interface)
    );

    int_ctl int_ctl (
        .ctrl      (control_signals),
        .breakpoint(1'b0),
        .hit       (hit),
        .illegal   (invalid_inst || (invalid_csr && control_signals.write_csr)),
        .ialign    (ialign),
        .ecall     (ecall),
        .ebreak    (ebreak),
        .malign    (malign),
        .csrs      (csr_interface),
        .ivec      (ivec),
        .trap      (trap)
    );

endmodule
