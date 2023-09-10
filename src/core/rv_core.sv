`include "../system/arilla_bus_if.svh"
`include "../debug/debug_if.svh"
`include "control_signals_if.svh"
`include "csr_if.svh"
`include "isa.svh"

module rv_core (
    input clk,
    input rst_n,

    input nmi,
    input exti,

    output csr_hit,

    arilla_bus_if bus_interface,
    debug_if      debug_interface
);
    control_signals_if control_signals ();
    csr_if             csr_interface   ();

    wire [`ISA__XLEN-1:0] pc, shadow_pc, next_pc, mid_pc, alu_pc, trap_pc, d_pc;
    wire [`ISA__XLEN-1:0] ir, ir_in;
    wire [`ISA__XLEN-1:0] rs1, rs2;
    reg  [`ISA__XLEN-1:0] rd;
    wire [`ISA__XLEN-1:0] mem_in, mem_out, mem_addr, mem_addr_reg;
    wire [`ISA__XLEN-1:0] csri, imm;
    reg  [`ISA__XLEN-1:0] alu_in1, alu_in2;
    wire [`ISA__XLEN-1:0] alu_out;
    wire [`ISA__XLEN-1:0] csr_out;

    wire [       `ISA__RFLEN-1:0] rs1_a, rs2_a, rd_a;
    wire [`ISA__FUNCT3_WIDTH-1:0] mem_size;
    wire [`ISA__FUNCT3_WIDTH-1:0] op;

    wire exception, interrupt;
    wire mret;
    wire trap;
    wire ialign;
    wire malign, fault;
    wire invalid_inst, invalid_csr;
    wire mod;
    wire ecall, ebreak;
    wire retire;
    wire conflict;
    wire timer;
    wire interrupt_pending;
    wire debug, halted, halted_ctrl, abstract, step, resuming, reg_error;
    wire trigger;

    assign retire = control_signals.write_pc_ne && !(exception || ecall || ebreak);
    assign trap   = exception || interrupt || mret;

    assign ir_in  = mem_out;

    assign mid_pc   =                                       resuming                 ? d_pc                 : alu_pc;
    assign next_pc  = abstract ? 32'hFFFFFF80             : trap                     ? trap_pc              : mid_pc;
    assign mem_addr = abstract ? debug_interface.data1_in : control_signals.addr_sel ? shadow_pc            : alu_out;
    assign mem_size = abstract ? control_signals.f3       : control_signals.addr_sel ? `ISA__INST_LOAD_SIZE : control_signals.f3;
    assign mem_in   = abstract ? debug_interface.data0_in                                                   : rs2;

    assign debug_interface.data0_out = rd;

    always_comb begin
        case (control_signals.rd_sel)
            `CONTROL_SIGNALS__RD_ALU: rd = alu_out;
            `CONTROL_SIGNALS__RD_MEM: rd = mem_out;
            `CONTROL_SIGNALS__RD_CSR: rd = csr_out;
            default:                  rd = alu_out;
        endcase
    end

    always_comb begin
        case (control_signals.alu_insel1)
            `CONTROL_SIGNALS__ALU1_RS: alu_in1 = rs1;
            `CONTROL_SIGNALS__ALU1_PC: alu_in1 = pc;
            `CONTROL_SIGNALS__ALU1_ZR: alu_in1 = `ISA__ZERO;
            default:                   alu_in1 = rs1;
        endcase
    end

    always_comb begin
        case (control_signals.alu_insel2)
            `CONTROL_SIGNALS__ALU2_RS: alu_in2 = rs2;
            `CONTROL_SIGNALS__ALU2_IM: alu_in2 = imm;
            `CONTROL_SIGNALS__ALU2_IS: alu_in2 = `ISA__INST_SIZE;
            default:                   alu_in2 = rs2;
        endcase
    end

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
        .in        (ir_in),
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

    mem_interface #(
        .InhibitPolarity(1'b0)
    ) mem_interface (
        .clk           (clk),
        .rst_n         (rst_n),
        .bus_interface (bus_interface),
        .address       (mem_addr),
        .sign_size     (mem_size),
        .rd            (control_signals.mem_read),
        .wr            (control_signals.mem_write),
        .data_in       (mem_in),
        .data_out      (mem_out),
        .complete      (control_signals.mem_complete),
        .malign        (malign),
        .fault         (fault),
        .address_reg   (mem_addr_reg)
    );

    inst_decode inst_decode (
        .inst        (ir),
        .abstract    (abstract),
        .cmd         (debug_interface.command),
        .data0       (debug_interface.data0_in),
        .invalid_inst(invalid_inst),
        .opcode      (control_signals.opcode),
        .f3          (control_signals.f3),
        .rd          (rd_a),
        .rs1         (rs1_a),
        .rs2         (rs2_a),
        .csri        (csri),
        .imm         (imm),
        .op          (op),
        .mod         (mod),
        .ecall       (ecall),
        .ebreak      (ebreak),
        .mret        (mret)
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

    pc_calc #(
        .Width(`ISA__XLEN)
    ) pc_calc (
        .pc     (pc),
        .a      (rs1),
        .b      (rs2),
        .imm    (imm),
        .opcode (control_signals.opcode),
        .f3     (control_signals.f3),
        .next_pc(alu_pc),
        .ialign (ialign)
    );

    control control (
        .clk              (clk),
        .rst_n            (rst_n),
        .exception        (exception),
        .interrupt_pending(interrupt_pending),
        .debug            (debug),
        .halted           (halted_ctrl),
        .abstract         (abstract),
        .step             (step),
        .reg_error        (reg_error),
        .trigger          (trigger),
        .control_signals  (control_signals)
    );

    csr #(
        .BaseAddress(`ISA__TIME_BASE)
    ) csr (
        .clk          (clk),
        .rst_n        (rst_n),
        .csr_interface(csr_interface),
        .bus_interface(bus_interface),
        .mem_hit      (csr_hit),
        .reg_in       (rs1),
        .imm_in       (csri),
        .addr         (imm),
        .rs           (rs1_a),
        .f3           (op),
        .write        (control_signals.write_csr),
        .debug        (halted),
        .retire       (retire),
        .csr_out      (csr_out),
        .invalid      (invalid_csr),
        .conflict     (conflict),
        .timeint      (timer)
    );

    int_ctl int_ctl (
        .clk              (clk),
        .rst_n            (rst_n),
        .ctrl             (control_signals),
        .csrs             (csr_interface),
        .nmi              (nmi),
        .exti             (exti),
        .timer            (timer),
        .debug            (halted),
        .step             (step),
        .breakp           (1'b0),
        .fault            (fault),
        .invalid_inst     (invalid_inst),
        .invalid_csr      (invalid_csr),
        .ialign           (ialign),
        .ecall            (ecall),
        .ebreak           (ebreak),
        .malign           (malign),
        .mret             (mret),
        .conflict         (conflict),
        .pc               (pc),
        .next_pc          (mid_pc),
        .mem_addr         (mem_addr_reg),
        .ir               (ir),
        .tvec             (trap_pc),
        .exception        (exception),
        .interrupt        (interrupt),
        .interrupt_pending(interrupt_pending)
    );

    d_ctl d_ctl (
        .clk        (clk),
        .rst_n      (rst_n),
        .nmi        (nmi),
        .interrupt  (interrupt),
        .exception  (exception),
        .eb         (ebreak),
        .trig       (trigger),
        .malign     (malign),
        .fault      (fault),
        .invalid_csr(invalid_csr),
        .pc_reg     (pc),
        .pc_next    (next_pc),
        .debug      (debug),
        .halted     (halted),
        .halted_ctrl(halted_ctrl),
        .step_en    (step),
        .resuming   (resuming),
        .abstract   (abstract),
        .reg_error  (reg_error),
        .dpc_out    (d_pc),
        .csrs       (csr_interface),
        .ctrl       (control_signals),
        .debug_if   (debug_interface)
    );

    t_ctl t_ctl (
        .clk          (clk),
        .rst_n        (rst_n),
        .pc           (pc),
        .ir           (ir),
        .addr         (alu_out),
        .mem_out      (mem_out),
        .mem_in       (mem_in),
        .mem_size     (mem_size[1:0]),
        .debug        (halted),
        .ctrl         (control_signals),
        .trigger      (trigger),
        .csr_interface(csr_interface)
    );

endmodule
